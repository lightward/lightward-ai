import { ChatUI } from '../../../../app/javascript/src/concerns/chat';

describe('ChatUI', () => {
  let ui;

  beforeEach(() => {
    // Create mock DOM structure
    document.body.innerHTML = `
      <h1>Test</h1>
      <button id="copy-all-button">Copy All</button>
      <div id="loading-message">Loading...</div>
      <div id="chat" class="hidden"></div>
      <div id="start-suggestions">Start suggestions</div>
      <div id="chat-log" class="hidden"></div>
      <div id="text-input" class="hidden">
        <textarea placeholder=""></textarea>
        <button>Send</button>
      </div>
      <div id="instructions">Instructions</div>
      <div id="tools" class="hidden"></div>
      <footer>Footer</footer>
      <div id="response-suggestions" class="hidden"></div>
      <button id="start-over-button">Start Over</button>
      <div id="chat-canvas"></div>
    `;

    ui = new ChatUI('Test Bot');
  });

  describe('initialization', () => {
    it('should cache all required elements', () => {
      expect(ui.elements.h1).toBeTruthy();
      expect(ui.elements.chatLog).toBeTruthy();
      expect(ui.elements.userInput).toBeTruthy();
      expect(ui.elements.submitButton).toBeTruthy();
    });

    it('should set up meta key for platform', () => {
      const expectedKey = navigator.userAgent.match('Mac') ? '⌘' : 'ctrl';
      expect(ui.elements.userInputArea.dataset.submitTip).toContain(
        expectedKey
      );
    });

    it('should set the bot name', () => {
      expect(ui.name).toBe('Test Bot');
    });
  });

  describe('showChat', () => {
    it('should reveal chat container and remove loading', () => {
      ui.showChat();

      expect(ui.elements.chatContainer).not.toHaveClass('hidden');
      expect(document.getElementById('loading-message')).toBeNull();
    });
  });

  describe('addMessage', () => {
    it('should create message element with correct classes', () => {
      const element = ui.addMessage('user', 'Hello world');

      expect(element).toHaveClass('chat-message', 'user');
      expect(element.textContent).toBe('Hello world');
      expect(ui.elements.chatLog).toContainElement(element);
    });

    it('should update h1 with bot name', () => {
      ui.addMessage('assistant', 'Response');
      expect(ui.elements.h1.textContent).toBe('Test Bot');
    });

    it('should show chat log', () => {
      ui.addMessage('user', 'Test');
      expect(ui.elements.chatLog).not.toHaveClass('hidden');
    });
  });

  describe('addPulsingMessage', () => {
    it('should create pulsing message that transitions to loading', () => {
      jest.useFakeTimers();

      const element = ui.addPulsingMessage('assistant');

      expect(element).toHaveClass('chat-message', 'assistant', 'pulsing');

      jest.advanceTimersByTime(5000);

      expect(element).not.toHaveClass('pulsing');
      expect(element).toHaveClass('loading');

      jest.useRealTimers();
    });
  });

  describe('user input controls', () => {
    it('should show disabled input area', () => {
      ui.showUserInput();

      expect(ui.elements.userInputArea).not.toHaveClass('hidden');
      expect(ui.elements.userInputArea).toHaveClass('disabled');
      expect(ui.elements.userInput).toBeDisabled();
    });

    it('should enable user input', () => {
      ui.enableUserInput();

      expect(ui.elements.userInputArea).not.toHaveClass('hidden', 'disabled');
      expect(ui.elements.userInput).not.toBeDisabled();
      expect(ui.elements.userInput.placeholder).toBe('(describe anything)');
      expect(ui.elements.tools).not.toHaveClass('hidden');
    });

    it('should clear user input', () => {
      ui.elements.userInput.value = 'test';
      ui.elements.userInputArea.classList.add('multiline');

      ui.clearUserInput();

      expect(ui.elements.userInput.value).toBe('');
      expect(ui.elements.userInputArea).not.toHaveClass('multiline');
    });

    it('should set user input and trigger event', () => {
      const inputEvent = jest.fn();
      ui.elements.userInput.addEventListener('input', inputEvent);

      ui.setUserInput('New value');

      expect(ui.elements.userInput.value).toBe('New value');
      expect(inputEvent).toHaveBeenCalled();
    });
  });

  describe('autofocus behavior', () => {
    it('should not autofocus on touch devices', () => {
      window.ontouchstart = () => {};
      ui.elements.userInput.focus = jest.fn();

      ui.enableUserInput(true);

      expect(ui.elements.userInput.focus).not.toHaveBeenCalled();

      delete window.ontouchstart;
    });

    it('should autofocus when appropriate', () => {
      ui.elements.userInput.focus = jest.fn();
      ui.elements.userInputArea.getBoundingClientRect = () => ({ top: 100 });

      ui.enableUserInput(true);

      expect(ui.elements.userInput.focus).toHaveBeenCalled();
    });
  });

  describe('footer visibility', () => {
    it('should hide footer for single message', () => {
      ui.updateFooterVisibility(1);
      expect(ui.elements.footer).toHaveClass('hidden');
    });

    it('should show footer for multiple messages', () => {
      ui.updateFooterVisibility(2);
      expect(ui.elements.footer).not.toHaveClass('hidden');
    });
  });

  describe('animations', () => {
    it('should start vanish animation', () => {
      ui.startVanishAnimation();

      expect(ui.elements.chatCanvas).toHaveClass('vanishing');
      expect(document.body).toHaveClass('transitioning');
    });
  });

  describe('copy button', () => {
    it('should update button text temporarily', () => {
      jest.useFakeTimers();

      ui.updateCopyButton('Copied!', 1000);

      expect(ui.elements.copyAllButton.textContent).toBe('Copied!');
      expect(ui.elements.copyAllButton.style.width).toBeTruthy();

      jest.advanceTimersByTime(1000);

      expect(ui.elements.copyAllButton.textContent).toBe('Copy All');
      expect(ui.elements.copyAllButton.style.width).toBe('');

      jest.useRealTimers();
    });
  });
});
