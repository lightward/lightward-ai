// app/javascript/application.js
import { createConsumer } from "@rails/actioncable"

const consumer = createConsumer();

document.addEventListener('DOMContentLoaded', () => {
  const startSuggestions = document.getElementById('start-suggestions');
  const chatLog = document.getElementById('chat-log');
  const userInput = document.getElementById('user-input');
  const instructions = document.getElementById('instructions');
  const footer = document.getElementById('footer');
  const responseSuggestions = document.getElementById('response-suggestions');

  let subscription;
  let currentAssistantMessageElement = null;
  let sequenceQueue;
  let currentSequenceNumber;
  const TIMEOUT_MS = 10000;

  function getChatId() {
    return window.location.pathname.split('/').pop();
  }

  function hide(node) {
    node.classList.add('hidden');
  }

  function show(node) {
    node.classList.remove('hidden');
  }

  function addMessage(role, contentText) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element');
    messageElement.innerText = contentText;
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
    show(userInput);
    userInput.disabled = true;
  }

  function enableUserInput() {
    currentAssistantMessageElement?.classList.remove('pulsing');
    show(userInput);
    userInput.disabled = false;
    userInput.focus();
    hide(responseSuggestions);
  }

  function showResponseSuggestions() {
    show(responseSuggestions);
  }

  function hideResponseSuggestions() {
    hide(startSuggestions);
    hide(responseSuggestions);
    instructions.remove();
    footer.remove();
  }

  function handleUserInput() {
    userInput.addEventListener('keypress', function(event) {
      if (event.key !== 'Enter') return;
      event.preventDefault();

      const text = userInput.value;
      if (!text.trim()) return;

      // ui updates
      addMessage('user', text);
      userInput.value = '';
      userInput.blur();
      hide(userInput);
      currentAssistantMessageElement = addPulsingMessage('assistant');

      // fire the request
      fetchAssistantResponse(text);
    });
  }

  function handleResponseClick(event) {
    event.preventDefault();

    const text = event.target.innerText;
    addMessage('user', text);
    hide(userInput);
    currentAssistantMessageElement = addPulsingMessage('assistant');

    fetchAssistantResponse(text);
  }

  document.querySelectorAll('.response-link').forEach(link => {
    link.addEventListener('click', handleResponseClick);
  });

  function fetchAssistantResponse(text) {
    hideResponseSuggestions();

    fetch('/chats/message', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ chat_id: getChatId(), message: { role: 'user', text } })
    })
    .then(response => response.json())
    .then(data => {
      const messageId = data.message_id;
      initializeConsumer(messageId);

      const chatId = data.chat_id;
      adjustPathname(`/${chatId}`);
    })
    .catch(error => {
      console.error('Error:', error);
      addMessage('error', `Error: ${error.message}`);
      enableUserInput();
      showResponseSuggestions();
    });
  }

  function adjustPathname(pathname) {
    if (window.location.pathname !== pathname) {
      window.history.pushState({}, '', pathname);
    }
  }

  function initializeConsumer(messageId) {
    sequenceQueue = [];
    currentSequenceNumber = 0;

    subscription = consumer.subscriptions.create(
      { channel: "StreamChannel", message_id: messageId },
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
      userInput.classList.remove('disabled-input');
      hide(userInput);
      enableUserInput();
    } else if (data.event === 'end') {
      subscription.unsubscribe();
      enableUserInput();
    } else if (data.event === 'ping') {
      // Handle ping if needed
    } else if (data.event === 'error') {
      const errorMessage = `Error: ${data.data.error.message}`;
      currentAssistantMessageElement.innerText += ` ${errorMessage}`;
      subscription.unsubscribe();
      enableUserInput();
      showResponseSuggestions();
    }
  }

  handleUserInput();
});
