import {initChat} from './chat';

const initOnReady = () => {
  try {
    initChat();
  } catch (error) {
    // hide the loading message, if found
    const loadingMessage = document.getElementById('loading-message');
    if (loadingMessage) loadingMessage.remove();

    // render error message and re-throw
    const errorMessage = document.createElement('div');
    errorMessage.classList.add('error');
    errorMessage.innerText =
      '🧑‍🚒 Ran into an error! Can you ping a Lightward human for help?';

    // clear out the chat container
    const chatContainer = document.getElementById('chat-container');
    chatContainer.innerHTML = '';
    chatContainer.appendChild(errorMessage);

    chatContainer.classList.remove('hidden');

    // rethrow for error reporting via newrelic and console debugging
    throw error;
  }
};

if (document.readyState !== "loading") {
  initOnReady()
} else {
  document.addEventListener('DOMContentLoaded', initOnReady, { once: true })
}
