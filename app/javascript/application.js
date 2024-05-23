import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer();

document.addEventListener('DOMContentLoaded', () => {
  try {
    const chatContext = JSON.parse(document.getElementById('chat-context-data').textContent);
    const loadingMessage = document.getElementById('loading-message');
    const chatContainer = document.getElementById('chat-container');
    const startSuggestions = document.getElementById('start-suggestions');
    const chatLog = document.getElementById('chat-log');
    const userInputArea = document.getElementById('user-input');
    const userInput = userInputArea.querySelector('textarea');
    const instructions = document.getElementById('instructions');
    const footer = document.getElementById('footer');
    const responseSuggestions = document.getElementById('response-suggestions');
    const startOverButton = document.getElementById('start-over-button');

    const chatLogDataLocalstorageKey = chatContext.localstorage_chatlog_key;
    const chatLogData = JSON.parse(localStorage.getItem(chatLogDataLocalstorageKey)) || [];

    const metaKey = navigator.userAgent.match('Mac') ? '⌘' : 'ctrl';
    userInputArea.dataset.submitTip = `Press ${metaKey}+enter to send`;

    let currentAssistantMessageElement = null;
    let subscription;
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

    chatContainer.classList.remove('hidden');
    loadingMessage.remove();

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
      userInput.placeholder = '';
    }

    function enableUserInput(autofocusIsAppropriate = false) {
      currentAssistantMessageElement?.classList.remove('pulsing');
      userInputArea.classList.remove('hidden', 'disabled');
      userInput.disabled = false;
      userInput.placeholder = 'What would you like to say?';
      startOverButton.classList.remove('hidden');
      responseSuggestions.classList.add('hidden');

      // autofocus if we're not on a touch screen and if the input is in view
      if (autofocusIsAppropriate && !('ontouchstart' in window)) {
        if (userInputArea.getBoundingClientRect().top < window.innerHeight) {
          userInput.focus();
        }
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
      userInput.addEventListener('keydown', function(event) {
        // cmd+enter or ctrl+enter
        if (event.key === 'Enter') {
          if (event.metaKey || event.ctrlKey) {
            event.preventDefault();
            submitUserInput(userInput.value);
          } else {
            userInputArea.classList.add('multiline');
          }
        }
      });

      userInput.addEventListener('input', function() {
        // expand the textarea as needed. it'll be reset when the user submits their message. it
        // doesn't auto-shrink, and that actually feels appropriate? we keep whatever space the
        // user has hollowed out for themselves, and we only reset it when they've decided they're
        // complete. :)
        if (userInput.scrollHeight > userInput.clientHeight) {
          userInput.style.height = userInput.scrollHeight + 'px';
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
      userMessage = userMessage.trim();

      // ignore blank submissions
      if (!userMessage) return;

      addMessage('user', userMessage);
      chatLogData.push({role: 'user', content: [{ type: 'text', text: userMessage }] });
      userInput.style.height = 'auto';
      userInputArea.classList.remove('multiline');
      userInput.value = '';
      userInput.blur();
      userInputArea.classList.add('hidden');
      currentAssistantMessageElement = addPulsingMessage('assistant');
      fetchAssistantResponse();
    }

    function fetchAssistantResponse() {
      hideResponseSuggestions();

      const conversationData = {
        with_content_key: chatContext.with_content_key,
        chat_log: chatLogData,
      };

      fetch('/chats/message', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify(conversationData)
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
      localStorage.setItem(chatLogDataLocalstorageKey, JSON.stringify(chatLogData));
    }

    // Handle start over button click
    startOverButton.addEventListener('click', (event) => {
      event.preventDefault();

      if (confirm('Are you sure you want to start over? This will clear the chat log.')) {
        localStorage.removeItem(chatLogDataLocalstorageKey);
        localStorage.removeItem('scrollY');
        location.reload();
      }
    });

    handleUserInput();
  } catch (error) {
    // hide the loading message, if found
    const loadingMessage = document.getElementById('loading-message');
    if (loadingMessage) loadingMessage.remove();

    // render error message and re-throw
    const errorMessage = document.createElement('div');
    errorMessage.classList.add('error');
    errorMessage.innerText = '🧑‍🚒 Ran into an error! Can you ping a Lightward human for help?';

    // clear out the chat container
    const chatContainer = document.getElementById('chat-container');
    chatContainer.innerHTML = '';
    chatContainer.appendChild(errorMessage);

    chatContainer.classList.remove('hidden');

    // rethrow for error reporting via newrelic and console debugging
    throw error;
  }
});
