import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer();

document.addEventListener('DOMContentLoaded', () => {
  const startSuggestions = document.getElementById('start-suggestions');
  const chatLog = document.getElementById('chat-log');
  const userInput = document.getElementById('user-input');
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
  }

  function addMessage(role, text) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element');
    messageElement.innerText = text;
    chatLog.appendChild(messageElement);
    window.scrollTo(0, document.body.scrollHeight);
    return messageElement;
  }

  function addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element', 'pulsing');
    chatLog.appendChild(messageElement);
    window.scrollTo(0, document.body.scrollHeight);
    return messageElement;
  }

  function showUserInput() {
    userInput.classList.remove('hidden');
    userInput.classList.add('disabled-input');
    userInput.disabled = true;
  }

  function enableUserInput() {
    currentAssistantMessageElement?.classList.remove('pulsing');
    userInput.classList.remove('hidden', 'disabled-input');
    userInput.disabled = false;
    userInput.focus();
    responseSuggestions.classList.add('hidden');
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
    userInput.addEventListener('keypress', function(event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        submitUserInput(userInput.value);
      }
    });
  }

  function handleResponseClick(event) {
    event.preventDefault();
    const message = event.target.innerText;
    addMessage('user', message);
    chatLogData.push({ role: 'user', content: [{ type: 'text', text: message }] });
    userInput.classList.add('hidden');
    currentAssistantMessageElement = addPulsingMessage('assistant');
    fetchAssistantResponse();
  }

  document.querySelectorAll('.response-link').forEach(link => {
    link.addEventListener('click', handleResponseClick);
  });

  function submitUserInput(userMessage) {
    addMessage('user', userMessage);
    chatLogData.push({ role: 'user', content: [{ type: 'text', text: userMessage }] });
    userInput.value = '';
    userInput.blur();
    userInput.classList.add('hidden');
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
        currentAssistantMessageElement.innerText += delta.text;
        window.scrollTo(0, document.body.scrollHeight);
      }
    } else if (data.event === 'content_block_stop') {
      // Content block is complete
    } else if (data.event === 'message_delta') {
      // Handle message delta if needed
    } else if (data.event === 'message_stop') {
      const assistantMessage = currentAssistantMessageElement.innerText;
      chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: assistantMessage }] });
      userInput.classList.remove('disabled-input');
      userInput.classList.add('hidden');
      enableUserInput();
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
  startOverButton.addEventListener('click', () => {
    if (confirm('Are you sure you want to start over? This will clear the chat log.')) {
      localStorage.removeItem('chatLogData');
      location.reload();
    }
  });

  handleUserInput();
});
