// app/javascript/src/concerns/chat.js

import { createConsumer } from '@rails/actioncable';

function getCSRFToken() {
  return document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content');
}

const consumer = createConsumer();

export const initChat = () => {
  const context = JSON.parse(
    document.getElementById('chat-context-data').textContent
  );

  // Define the old and new storage keys
  const OLD_STORAGE_KEY = 'chatLogData';
  const messagesKey = context.key;
  const userInputKey = `${context.key}/input`;

  // Migration logic for reader mode
  let messages;
  if (messagesKey === 'reader') {
    // Check for data under the old key first
    const oldData = localStorage.getItem(OLD_STORAGE_KEY);
    if (oldData) {
      // Migrate data from old key to new key
      localStorage.setItem(messagesKey, oldData);
      // Clean up old data
      localStorage.removeItem(OLD_STORAGE_KEY);
      messages = JSON.parse(oldData);
    } else {
      // If no old data exists, check for data under the new key
      messages = JSON.parse(localStorage.getItem(messagesKey)) || [];
    }
  } else {
    // For other modes (e.g., writer), just use the specified key
    messages = JSON.parse(localStorage.getItem(messagesKey)) || [];
  }

  const name = context.name || 'Lightward';

  const h1 = document.querySelector('h1');
  const copyAllButton = document.getElementById('copy-all-button');
  const loadingMessage = document.getElementById('loading-message');
  const chatContainer = document.getElementById('chat-container');
  const startSuggestions = document.getElementById('start-suggestions');
  const chatLog = document.getElementById('chat-log');
  const userInputArea = document.getElementById('text-input');
  const userInput = userInputArea.querySelector('textarea');
  const instructions = document.getElementById('instructions');
  const footer = document.getElementsByTagName('footer')[0];
  const responseSuggestions = document.getElementById('response-suggestions');
  const startOverButton = document.getElementById('start-over-button');

  const metaKey = navigator.userAgent.match('Mac') ? '⌘' : 'ctrl';
  userInputArea.dataset.submitTip = `Press ${metaKey}+enter to send`;

  let currentAssistantMessageElement = null;
  let subscription;
  let sequenceQueue;
  let currentSequenceNumber;
  let messageTimeout;

  // this matches the pulsing-moving-into-loading-dots animation sequence we've got going on
  const TIMEOUT_MS = 30000;

  // Prevent scroll jumping
  const previousScrollY = localStorage.getItem('scrollY');
  if (previousScrollY !== null) {
    window.scrollTo(0, parseInt(previousScrollY, 10));
  }

  // Load chat log from localStorage
  if (messages.length) {
    startSuggestions.classList.add('hidden');
    startOverButton.classList.remove('hidden');
    enableUserInput();

    messages.forEach((message) => {
      addMessage(message.role, message.content[0].text);
    });

    // Restore scroll position after messages have been loaded
    if (previousScrollY !== null) {
      window.scrollTo(0, parseInt(previousScrollY, 10));
    }
  }

  chatContainer.classList.remove('hidden');
  loadingMessage.remove();

  function addMessage(role, text) {
    // reset our usually-chaotic heading to something chill
    h1.innerText = h1.title || name;

    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role);
    messageElement.innerText = text;
    chatLog.appendChild(messageElement);
    saveScrollPosition();
    return messageElement;
  }

  function addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'pulsing');

    setTimeout(() => {
      if (messageElement.classList.contains('pulsing')) {
        messageElement.classList.remove('pulsing');
        messageElement.classList.add('loading');
      }
    }, 5000);

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
    copyAllButton.classList.remove('hidden');

    currentAssistantMessageElement?.classList.remove('pulsing', 'loading');
    userInputArea.classList.remove('hidden', 'disabled');
    userInput.disabled = false;
    userInput.placeholder = '(write what you’re feeling or thinking)';
    startOverButton.classList.remove('hidden');
    responseSuggestions.classList.add('hidden');

    // Autofocus if appropriate
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
  }

  function handleUserInput() {
    userInput.addEventListener('keydown', function (event) {
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

    userInput.addEventListener('input', function () {
      // Save input value to localStorage
      localStorage.setItem(userInputKey, userInput.value);
    });

    // Load saved input value from localStorage, if the textarea's empty
    const savedInputValue = localStorage.getItem(userInputKey);
    if (savedInputValue && userInput.value === '') {
      userInput.value = savedInputValue;

      // Trigger input event to resize textarea
      userInput.dispatchEvent(new Event('input'));
    }

    userInputArea
      .querySelector('button')
      .addEventListener('click', function (event) {
        event.preventDefault();
        submitUserInput(userInput.value);
      });
  }

  function handleResponseClick(event) {
    event.preventDefault();
    const message = event.target.innerHTML.trim();

    addMessage('user', message);

    messages.push({
      role: 'user',
      content: [{ type: 'text', text: message }],
    });

    userInputArea.classList.add('hidden');
    currentAssistantMessageElement = addPulsingMessage('assistant');
    fetchAssistantResponse();
  }

  document.querySelectorAll('prompt-button').forEach((promptButton) => {
    promptButton.addEventListener('prompt-button-click', handleResponseClick);
  });

  function submitUserInput(userMessage) {
    userMessage = userMessage.trim();

    // Ignore blank submissions
    if (!userMessage) return;

    addMessage('user', userMessage);
    messages.push({
      role: 'user',
      content: [{ type: 'text', text: userMessage }],
    });
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

    // Hide or show the footer based on message count
    if (messages.length === 1) {
      footer.classList.add('hidden');
    } else {
      footer.classList.remove('hidden');
    }

    const conversationData = {
      chat_log: messages,
    };

    fetch('/chats/message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': getCSRFToken(),
      },
      body: JSON.stringify(conversationData),
    })
      .then((response) => {
        if (response.status === 200) {
          return response.json();
        } else {
          return response.text().then((text) => {
            console.error(response.status, text);
            throw new Error(text);
          });
        }
      })
      .then((data) => {
        const streamId = data.stream_id;
        initializeConsumer(streamId);
      })
      .catch((error) => {
        console.error('Error:', error);
        appendSystemError(error.message);
        enableUserInput();
        showResponseSuggestions();
      });
  }

  function initializeConsumer(streamId) {
    sequenceQueue = [];
    currentSequenceNumber = 0;

    subscription = consumer.subscriptions.create(
      { channel: 'StreamChannel', stream_id: streamId },
      {
        connected() {
          // Send a "ready" message to the server
          this.perform('ready');
          // Start the message timeout
          startMessageTimeout();
        },
        disconnected() {
          // Handle disconnection during streaming
          handleDisconnection();
        },
        received(data) {
          // Reset the message timeout on receiving data
          resetMessageTimeout();

          if (data && typeof data.sequence_number === 'number') {
            sequenceQueue.push(data);
            sequenceQueue.sort((a, b) => a.sequence_number - b.sequence_number);

            while (
              sequenceQueue.length &&
              sequenceQueue[0].sequence_number === currentSequenceNumber
            ) {
              const message = sequenceQueue.shift();
              processMessage(message);
              currentSequenceNumber++;
            }
          } else {
            console.error(
              'Invalid data format or missing sequence_number:',
              data
            );
          }
        },
        rejected() {
          // Handle subscription rejection
          handleRejection();
        },
      }
    );
  }

  function startMessageTimeout() {
    clearMessageTimeout();
    messageTimeout = setTimeout(() => {
      handleTimeoutError();
    }, TIMEOUT_MS);
  }

  function resetMessageTimeout() {
    clearMessageTimeout();
    messageTimeout = setTimeout(() => {
      handleTimeoutError();
    }, TIMEOUT_MS);
  }

  function clearMessageTimeout() {
    if (messageTimeout) {
      clearTimeout(messageTimeout);
      messageTimeout = null;
    }
  }

  function appendSystemError(errorMessage) {
    const formattedErrorMessage = ` ⚠️\u00A0Lightward AI system error: ${errorMessage}`;
    if (currentAssistantMessageElement) {
      currentAssistantMessageElement.innerText += formattedErrorMessage;
    } else {
      // If there's no current assistant message, create one
      currentAssistantMessageElement = addMessage(
        'assistant',
        formattedErrorMessage
      );
    }

    // Update or add assistant message in messages
    if (
      messages.length > 0 &&
      messages[messages.length - 1].role === 'assistant'
    ) {
      messages[messages.length - 1].content[0].text =
        currentAssistantMessageElement.innerText;
    } else {
      messages.push({
        role: 'assistant',
        content: [
          { type: 'text', text: currentAssistantMessageElement.innerText },
        ],
      });
    }

    // Persist chat log data to localStorage
    localStorage.setItem(messagesKey, JSON.stringify(messages));
  }

  function handleTimeoutError() {
    appendSystemError(
      'Your connection was lost during the reply. Please try again.'
    );

    subscription.unsubscribe();
    enableUserInput();
    showResponseSuggestions();
  }

  function handleDisconnection() {
    appendSystemError('The connection was interrupted. Please try again.');

    enableUserInput();
    showResponseSuggestions();
  }

  function handleRejection() {
    appendSystemError('Connection was rejected. Please try again later.');

    enableUserInput();
    showResponseSuggestions();
  }

  function processMessage(data) {
    // Reset the message timeout every time we process a message
    resetMessageTimeout();

    if (data.event === 'message_start') {
      if (currentAssistantMessageElement) {
        currentAssistantMessageElement.classList.remove('pulsing', 'loading');
      }
      showUserInput();
    } else if (data.event === 'content_block_start') {
      // Initialize a new content block
    } else if (data.event === 'content_block_delta') {
      const delta = data.data.delta;
      if (delta.type === 'text_delta' && currentAssistantMessageElement) {
        // Create a new text node for the delta
        const textNode = document.createTextNode(delta.text);
        currentAssistantMessageElement.appendChild(textNode);
      }
    } else if (data.event === 'content_block_stop') {
      // Content block is complete
    } else if (data.event === 'message_delta') {
      // Handle message delta if needed
    } else if (data.event === 'message_stop') {
      const assistantMessage = currentAssistantMessageElement.innerText;

      // Update or add assistant message in messages
      if (
        messages.length > 0 &&
        messages[messages.length - 1].role === 'assistant'
      ) {
        messages[messages.length - 1].content[0].text = assistantMessage;
      } else {
        messages.push({
          role: 'assistant',
          content: [{ type: 'text', text: assistantMessage }],
        });
      }

      userInputArea.classList.remove('disabled');
      userInputArea.classList.add('hidden');
      enableUserInput(true);

      // Clear the message timeout as the message has completed
      clearMessageTimeout();
    } else if (data.event === 'end') {
      subscription.unsubscribe();
      enableUserInput();

      // Clear the message timeout as the stream has ended
      clearMessageTimeout();
    } else if (data.event === 'ping') {
      // Handle ping if needed
    } else if (data.event === 'error') {
      appendSystemError(data.data.error.message);

      subscription.unsubscribe();
      enableUserInput();
      showResponseSuggestions();

      // Clear the message timeout as an error occurred
      clearMessageTimeout();
    }

    // Persist chat log data to localStorage
    localStorage.setItem(messagesKey, JSON.stringify(messages));

    // Clear userInputKey, since the user has submitted their message
    localStorage.removeItem(userInputKey);
  }

  // Handle start over button click
  startOverButton.addEventListener('click', (event) => {
    event.preventDefault();

    if (
      confirm(
        'Are you sure you want to start over? This will clear the chat log.'
      )
    ) {
      localStorage.removeItem(messagesKey);
      localStorage.removeItem('scrollY');
      location.reload();
    }
  });

  copyAllButton.addEventListener('click', (event) => {
    event.preventDefault();

    const originalText = copyAllButton.innerText;

    const chatLogPlaintext = messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : name;
        const content = message.content
          .map((content) => content.text)
          .join('\n');

        return `# ${role}\n\n${content}`;
      })
      .join('\n\n');

    const chatLogRichtext = messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : name;
        const content = message.content
          .map((content) => content.text)
          .join('\n\n');
        const blockquote = `<blockquote>${content
          .split('\n')
          .join('<br>')}</blockquote>`;

        return `<b>${role}</b><br>${blockquote}`;
      })
      .join('<br><br>');

    const plaintextBlob = new Blob([chatLogPlaintext], { type: 'text/plain' });
    const richtextBlob = new Blob([chatLogRichtext], { type: 'text/html' });

    const data = [
      new ClipboardItem({
        'text/plain': plaintextBlob,
        'text/html': richtextBlob,
      }),
    ];

    navigator.clipboard.write(data).then(() => {
      copyAllButton.innerText = 'Copied!';
      setTimeout(() => {
        copyAllButton.innerText = originalText;
      }, 2000);
    });
  });

  // Clear message timeout when the window is unloaded
  window.addEventListener('beforeunload', () => {
    clearMessageTimeout();
  });

  handleUserInput();
};
