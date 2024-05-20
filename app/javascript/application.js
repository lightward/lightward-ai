import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer();

document.addEventListener('DOMContentLoaded', () => {
  const startSuggestions = document.getElementById('start-suggestions');
  const chatLog = document.getElementById('chat-log');
  const userInputArea = document.getElementById('user-input');
  const userInput = userInputArea.querySelector('input');
  const instructions = document.getElementById('instructions');
  const footer = document.getElementById('footer');
  const responseSuggestions = document.getElementById('response-suggestions');
  const startOverButton = document.getElementById('start-over-button');

  let subscription;
  let chatLogData = JSON.parse(localStorage.getItem('chatLogData')) || [];
  let currentAssistantMessageElement = null;
  let sequenceQueue;
  let currentSequenceNumber;
  const TIMEOUT_MS = 10000;

  // Prevent scroll jumping
  const previousScrollY = localStorage.getItem('scrollY');
  if (previousScrollY !== null) {
    window.scrollTo(0, parseInt(previousScrollY, 10));
  }

  // Load chat log from localStorage
  if (chatLogData.length) {
    startSuggestions.classList.add('hidden');
    startOverButton.classList.remove('hidden');
    enableUserInput();

    chatLogData.forEach(message => {
      addMessage(message.role, message.content[0].text);
    });

    // if the last message was from the user, send it to the assistant
    if (chatLogData[chatLogData.length - 1].role === 'user') {
      currentAssistantMessageElement = addPulsingMessage('assistant');
      submitUserInput(chatLogData[chatLogData.length - 1].content[0].text);
    }

    // Restore scroll position after messages have been loaded
    if (previousScrollY !== null) {
      window.scrollTo(0, parseInt(previousScrollY, 10));
    }
  }

  function addMessage(role, text) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element');
    messageElement.innerText = text;
    chatLog.appendChild(messageElement);
    saveScrollPosition();
    return messageElement;
  }

  function addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element', 'pulsing');
    chatLog.appendChild(messageElement);
    saveScrollPosition();
    return messageElement;
  }

  function saveScrollPosition() {
    localStorage.setItem('scrollY', window.scrollY);
  }

  function showUserInput() {
    userInputArea.classList.remove('hidden');
    userInputArea.classList.add('disabled');
    userInput.disabled = true;
  }

  function enableUserInput(autofocusIsAppropriate = false) {
    currentAssistantMessageElement?.classList.remove('pulsing');
    userInputArea.classList.remove('hidden', 'disabled');
    userInput.disabled = false;
    startOverButton.classList.remove('hidden');
    responseSuggestions.classList.add('hidden');

    // autofocus if we're not on a touch screen
    if (autofocusIsAppropriate && !('ontouchstart' in window)) {
      userInput.focus();
    }
  }

  function showResponseSuggestions() {
    responseSuggestions.classList.remove('hidden');
  }

  function hideResponseSuggestions() {
    startSuggestions.classList.add('hidden');
    responseSuggestions.classList.add('hidden');
    instructions.remove();
    footer.remove();
  }

  function handleUserInput() {
    userInputArea.addEventListener('keypress', function(event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        submitUserInput(userInput.value);
      }
    });

    userInputArea.querySelector('button').addEventListener('click', function(event) {
      event.preventDefault();
      submitUserInput(userInput.value);
    });
  }

  function handleResponseClick(event) {
    event.preventDefault();
    const message = event.target.innerText;
    addMessage('user', message);
    chatLogData.push({ role: 'user', content: [{ type: 'text', text: message }] });
    userInputArea.classList.add('hidden');
    currentAssistantMessageElement = addPulsingMessage('assistant');
    fetchAssistantResponse();
  }

  document.querySelectorAll('.response-link').forEach(link => {
    link.addEventListener('click', handleResponseClick);
  });

  function submitUserInput(userMessage) {
    // ignore blanks submissions
    if (!userMessage.trim()) return;

    addMessage('user', userMessage);
    chatLogData.push({ role: 'user', content: [{ type: 'text', text: userMessage }] });
    userInput.value = '';
    userInput.blur();
    userInputArea.classList.add('hidden');
    currentAssistantMessageElement = addPulsingMessage('assistant');
    fetchAssistantResponse();
  }

  function fetchAssistantResponse() {
    hideResponseSuggestions();

    fetch('/chats/message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ chat_log: chatLogData })
    })
    .then(response => response.json())
    .then(data => {
      const streamId = data.stream_id;
      initializeConsumer(streamId);
    })
    .catch(error => {
      console.error('Error:', error);
      addMessage('error', `Error: ${error.message}`);
      enableUserInput();
      showResponseSuggestions();
    });
  }

  function initializeConsumer(streamId) {
    sequenceQueue = [];
    currentSequenceNumber = 0;

    subscription = consumer.subscriptions.create(
      { channel: "StreamChannel", stream_id: streamId },
      {
        connected() {
          // Send a "ready" message to the server
          this.perform('ready');
        },
        received(data) {
          if (data && typeof data.sequence_number === 'number') {
            sequenceQueue.push(data);
            sequenceQueue.sort((a, b) => a.sequence_number - b.sequence_number);

            while (sequenceQueue.length && sequenceQueue[0].sequence_number === currentSequenceNumber) {
              const message = sequenceQueue.shift();
              processMessage(message);
              currentSequenceNumber++;
            }
          } else {
            console.error('Invalid data format or missing sequence_number:', data);
          }
        }
      }
    );

    setTimeout(() => {
      if (currentSequenceNumber < sequenceQueue[0]?.sequence_number) {
        handleTimeoutError();
      }
    }, TIMEOUT_MS);
  }

  function handleTimeoutError() {
    const errorMessage = `Error: Response timeout. Please try again.`;
    currentAssistantMessageElement.innerText += ` ${errorMessage}`;
    chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: currentAssistantMessageElement.innerText }] });
    enableUserInput();
    showResponseSuggestions();
  }

  function processMessage(data) {
    if (data.event === 'message_start') {
      if (currentAssistantMessageElement) {
        currentAssistantMessageElement.classList.remove('pulsing');
      }
      showUserInput();
    } else if (data.event === 'content_block_start') {
      // Initialize a new content block
    } else if (data.event === 'content_block_delta') {
      const delta = data.data.delta;
      if (delta.type === 'text_delta' && currentAssistantMessageElement) {
        let text = delta.text;

        // if there's a space at the end, make sure the `innerText` assignment magic doesn't lose it
        text = text.replace(/ $/, `\u00a0`);

        currentAssistantMessageElement.innerText += text;
      }
    } else if (data.event === 'content_block_stop') {
      // Content block is complete
    } else if (data.event === 'message_delta') {
      // Handle message delta if needed
    } else if (data.event === 'message_stop') {
      const assistantMessage = currentAssistantMessageElement.innerText;
      chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: assistantMessage }] });
      userInputArea.classList.remove('disabled');
      userInputArea.classList.add('hidden');
      enableUserInput(true);
    } else if (data.event === 'end') {
      subscription.unsubscribe();
      enableUserInput();
    } else if (data.event === 'ping') {
      // Handle ping if needed
    } else if (data.event === 'error') {
      const errorMessage = `Error: ${data.data.error.message}`;
      currentAssistantMessageElement.innerText += ` ${errorMessage}`;
      chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: currentAssistantMessageElement.innerText }] });
      subscription.unsubscribe();
      enableUserInput();
      showResponseSuggestions();
    }

    // Persist chat log data to localStorage
    localStorage.setItem('chatLogData', JSON.stringify(chatLogData));
  }

  // Handle start over button click
  startOverButton.addEventListener('click', (event) => {
    event.preventDefault();

    if (confirm('Are you sure you want to start over? This will clear the chat log.')) {
      localStorage.removeItem('chatLogData');
      localStorage.removeItem('scrollY');
      location.reload();
    }
  });

  handleUserInput();
});
