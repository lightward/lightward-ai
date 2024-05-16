// app/javascript/application.js
import "@hotwired/turbo-rails"
import "controllers"
import consumer from "./channels/consumer"

document.addEventListener('DOMContentLoaded', () => {
  const startChatButton = document.getElementById('start-chat');
  const chatLog = document.getElementById('chat-log');
  const userInput = document.getElementById('user-input');

  let chatLogData = [];
  let currentAssistantMessageElement = null;

  function addMessage(role, text) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element');
    messageElement.innerText = text;
    chatLog.appendChild(messageElement);
    chatLog.scrollTop = chatLog.scrollHeight;
    return messageElement;
  }

  function addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'element', 'pulsing');
    messageElement.innerHTML = '&nbsp;'; // Prefill with a non-breaking space
    chatLog.appendChild(messageElement);
    chatLog.scrollTop = chatLog.scrollHeight;
    return messageElement;
  }

  function revealUserInput() {
    userInput.classList.remove('hidden');
  }

  function enableUserInput() {
    revealUserInput();
    userInput.disabled = false;
    userInput.focus();
    userInput.classList.remove('disabled');
    userInput.addEventListener('keypress', function(event) {
      if (event.key === 'Enter') {
        event.preventDefault();
        const userMessage = userInput.value;
        if (userMessage.trim()) {
          addMessage('user', userMessage);
          chatLogData.push({ role: 'user', content: [{ type: 'text', text: userMessage }] });
          userInput.value = '';
          userInput.disabled = true;
          userInput.classList.add('disabled');
          currentAssistantMessageElement = addPulsingMessage('assistant');
          fetchAssistantResponse();
        }
      }
    });
  }

  function fetchAssistantResponse() {
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
    });
  }

  function initializeConsumer(streamId) {
    const subscription = consumer.subscriptions.create(
      { channel: "StreamChannel", stream_id: streamId },
      {
        received(data) {
          if (data.event === 'message_start') {
            // Remove pulsing effect from the current assistant message element
            if (currentAssistantMessageElement) {
              currentAssistantMessageElement.classList.remove('pulsing');
              currentAssistantMessageElement.innerText = ''; // Clear the space character
            }
          } else if (data.event === 'content_block_start') {
            // Initialize a new content block
          } else if (data.event === 'content_block_delta') {
            const delta = data.data.delta;
            if (delta.type === 'text_delta' && currentAssistantMessageElement) {
              currentAssistantMessageElement.innerText += delta.text;
              chatLog.scrollTop = chatLog.scrollHeight; // Auto-scroll
            }
          } else if (data.event === 'content_block_stop') {
            // Content block is complete
          } else if (data.event === 'message_delta') {
            // Handle message delta if needed
          } else if (data.event === 'message_stop') {
            const assistantMessage = currentAssistantMessageElement.innerText;
            chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: assistantMessage }] });
          } else if (data.event === 'end') {
            subscription.unsubscribe();
            enableUserInput();
          } else if (data.event === 'ping') {
            // Handle ping if needed
          } else if (data.event === 'error') {
            const errorMessage = `Error: ${data.data.error.message}`;
            currentAssistantMessageElement.innerText += `\n${errorMessage}`;
            chatLogData.push({ role: 'assistant', content: [{ type: 'text', text: currentAssistantMessageElement.innerText }] });
            subscription.unsubscribe();
            enableUserInput();
          }
        }
      }
    );
  }

  startChatButton.addEventListener('click', () => {
    startChatButton.remove();
    addMessage('user', "I'm here");
    chatLogData.push({ role: 'user', content: [{ type: 'text', text: "I'm here" }] });
    currentAssistantMessageElement = addPulsingMessage('assistant');
    fetchAssistantResponse();
  });
});
