import { initChat } from 'src/chat';
import { initTextarea } from 'src/textarea';
import 'src/components/button-toggle';
import 'src/components/crypto-manager';
import 'src/components/crypto-decrypt';
import 'src/components/crypto-field';
import 'src/components/prompt-button';

const initOnReady = () => {
  initTextarea();

  const chatContainer = document.getElementById('chat-container');

  if (chatContainer) {
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

      chatContainer.innerHTML = '';
      chatContainer.appendChild(errorMessage);

      chatContainer.classList.remove('hidden');

      // rethrow for error reporting via newrelic and console debugging
      throw error;
    }
  }
};

// initialize the chat when the DOM is ready
if (document.readyState !== 'loading') {
  // it's already ready!
  initOnReady();
} else {
  // or else it's GONNA be!
  document.addEventListener('DOMContentLoaded', initOnReady, { once: true });
}
