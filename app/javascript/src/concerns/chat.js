// app/javascript/src/concerns/chat.js

import { createConsumer } from '@rails/actioncable';

// Configuration constants
export const CONFIG = {
  MIN_MESSAGE_UPDATE_INTERVAL: 100,
  MAX_MESSAGE_UPDATE_INTERVAL: 300,
  MESSAGE_TIMEOUT_MS: 30000,
};

// Storage handler for chat persistence
export class ChatStorage {
  constructor(context) {
    this.messagesKey = context.key;
    this.userInputKey = `${context.key}/input`;
  }

  loadMessages() {
    return JSON.parse(localStorage.getItem(this.messagesKey)) || [];
  }

  saveMessages(messages) {
    localStorage.setItem(this.messagesKey, JSON.stringify(messages));
  }

  loadUserInput() {
    return localStorage.getItem(this.userInputKey) || '';
  }

  saveUserInput(input) {
    localStorage.setItem(this.userInputKey, input);
  }

  clearUserInput() {
    localStorage.removeItem(this.userInputKey);
  }

  loadScrollPosition() {
    const scrollY = localStorage.getItem('scrollY');
    return scrollY ? parseInt(scrollY, 10) : null;
  }

  saveScrollPosition() {
    localStorage.setItem('scrollY', window.scrollY);
  }

  clearMessages() {
    localStorage.removeItem(this.messagesKey);
    localStorage.setItem('scrollY', '0');
  }
}

// UI handler for DOM manipulation
export class ChatUI {
  constructor(name) {
    this.name = name;
    this._cacheElements();
    this._setupMetaKey();
  }

  _cacheElements() {
    this.elements = {
      h1: document.querySelector('h1'),
      copyAllButton: document.getElementById('copy-all-button'),
      loadingMessage: document.getElementById('loading-message'),
      chatContainer: document.getElementById('chat'),
      startSuggestions: document.getElementById('start-suggestions'),
      chatLog: document.getElementById('chat-log'),
      userInputArea: document.getElementById('text-input'),
      userInput: document.querySelector('#text-input textarea'),
      submitButton: document.querySelector('#text-input button'),
      instructions: document.getElementById('instructions'),
      tools: document.getElementById('tools'),
      footer: document.getElementsByTagName('footer')[0],
      responseSuggestions: document.getElementById('response-suggestions'),
      startOverButton: document.getElementById('start-over-button'),
      chatCanvas: document.getElementById('chat-canvas'),
    };
  }

  _setupMetaKey() {
    const metaKey = navigator.userAgent.match('Mac') ? '⌘' : 'ctrl';
    this.elements.userInputArea.dataset.submitTip = `Press ${metaKey}+enter to send`;
    this.metaKeyName = metaKey;
  }

  showChat() {
    this.elements.chatContainer.classList.remove('hidden');
    this.elements.loadingMessage.remove();
  }

  hideStartSuggestions() {
    this.elements.startSuggestions.classList.add('hidden');
  }

  showChatLog() {
    this.elements.chatLog.classList.remove('hidden');
  }

  addMessage(role, text) {
    this.elements.h1.textContent = this.name;
    this.showChatLog();

    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role);
    messageElement.textContent = text;
    this.elements.chatLog.appendChild(messageElement);

    return messageElement;
  }

  addPulsingMessage(role) {
    const messageElement = document.createElement('div');
    messageElement.classList.add('chat-message', role, 'pulsing');

    setTimeout(() => {
      if (messageElement.classList.contains('pulsing')) {
        messageElement.classList.remove('pulsing');
        messageElement.classList.add('loading');
      }
    }, 5000);

    this.elements.chatLog.appendChild(messageElement);
    return messageElement;
  }

  showUserInput() {
    this.elements.userInputArea.classList.remove('hidden');
    this.elements.userInputArea.classList.add('disabled');
    this.elements.userInput.disabled = true;
    this.elements.userInput.placeholder = '';
  }

  enableUserInput(autofocus = false) {
    this.elements.userInputArea.classList.remove('hidden', 'disabled');
    this.elements.userInput.disabled = false;
    this.elements.userInput.placeholder = '(describe anything)';
    this.elements.tools.classList.remove('hidden');

    if (this._shouldAutofocus(autofocus)) {
      this.elements.userInput.focus();
    }
  }

  _shouldAutofocus(autofocusRequested) {
    return (
      autofocusRequested &&
      !('ontouchstart' in window) &&
      this.elements.userInputArea.getBoundingClientRect().top <
        window.innerHeight &&
      !window.getSelection().toString() &&
      !document.activeElement?.matches('textarea, input')
    );
  }

  hideUserInput() {
    this.elements.userInputArea.classList.add('hidden');
  }

  clearUserInput() {
    this.elements.userInput.value = '';
    this.elements.userInput.style.height = 'auto';
    this.elements.userInputArea.classList.remove('multiline');
    this.elements.userInput.blur();
  }

  setUserInput(value) {
    this.elements.userInput.value = value;
    this.elements.userInput.dispatchEvent(new Event('input'));
  }

  showResponseSuggestions() {
    this.elements.responseSuggestions.classList.remove('hidden');
  }

  hideResponseSuggestions() {
    this.elements.startSuggestions.classList.add('hidden');
    this.elements.responseSuggestions.classList.add('hidden');
    this.elements.instructions.remove();
  }

  updateFooterVisibility(messageCount) {
    if (messageCount === 1) {
      this.elements.footer.classList.add('hidden');
    } else {
      this.elements.footer.classList.remove('hidden');
    }
  }

  startVanishAnimation() {
    this.elements.chatCanvas.classList.add('vanishing');
    document.body.classList.add('transitioning');
  }

  updateCopyButton(text, duration = 2000) {
    const originalText = this.elements.copyAllButton.textContent;
    const width = this.elements.copyAllButton.offsetWidth;
    this.elements.copyAllButton.style.width = `${width}px`;
    this.elements.copyAllButton.textContent = text;

    setTimeout(() => {
      this.elements.copyAllButton.textContent = originalText;
      this.elements.copyAllButton.style.width = '';
    }, duration);
  }

  stopPulsingLoading(element) {
    element?.classList.remove('pulsing', 'loading');
  }
}

// Message stream controller for handling chunked responses
export class MessageStreamController {
  constructor(minInterval, maxInterval) {
    this.minInterval = minInterval;
    this.maxInterval = maxInterval;
    this.reset();
  }

  reset() {
    this.queue = [];
    this.isProcessing = false;
    this.isComplete = false;
    this.lastUpdateTime = 0;
    this.currentElement = null;
    this.onComplete = null;
  }

  setElement(element) {
    this.currentElement = element;
  }

  addChunk(text) {
    this.queue.push(text);
    this._processQueue();
  }

  complete(callback) {
    this.isComplete = true;
    this.onComplete = callback;
    this._checkCompletion();
  }

  flush() {
    // Immediately process all queued chunks without delays
    while (this.queue.length > 0) {
      const chunk = this.queue.shift();
      if (this.currentElement) {
        const textNode = document.createTextNode(chunk);
        this.currentElement.appendChild(textNode);
      }
    }
    this.lastUpdateTime = Date.now();
  }

  _processQueue() {
    if (this.isProcessing || this.queue.length === 0) {
      this._checkCompletion();
      return;
    }

    this.isProcessing = true;
    const chunk = this.queue.shift();

    if (this.currentElement) {
      const textNode = document.createTextNode(chunk);
      this.currentElement.appendChild(textNode);
    }

    const now = Date.now();
    const timeSinceLastUpdate = now - this.lastUpdateTime;
    this.lastUpdateTime = now;

    const randomDelay =
      this.minInterval + Math.random() * (this.maxInterval - this.minInterval);
    const actualDelay = Math.max(0, randomDelay - timeSinceLastUpdate);

    setTimeout(() => {
      this.isProcessing = false;
      this._processQueue();
    }, actualDelay);
  }

  _checkCompletion() {
    if (
      this.queue.length === 0 &&
      this.isComplete &&
      this.onComplete &&
      !this.isProcessing
    ) {
      const callback = this.onComplete;
      this.onComplete = null;
      callback();
    }
  }
}

// WebSocket subscription handler
export class ChatSubscription {
  constructor(consumer, onMessage, onError, onTimeout) {
    this.consumer = consumer;
    this.onMessage = onMessage;
    this.onError = onError;
    this.onTimeout = onTimeout;
    this.subscription = null;
    this.sequenceQueue = [];
    this.currentSequenceNumber = 0;
    this.timeoutId = null;
  }

  subscribe(streamId) {
    this.unsubscribe();
    this.sequenceQueue = [];
    this.currentSequenceNumber = 0;

    this.subscription = this.consumer.subscriptions.create(
      { channel: 'StreamChannel', stream_id: streamId },
      {
        connected: () => {
          this.subscription.perform('ready');
          this._startTimeout();
        },

        disconnected: () => {
          this.onError('The connection was interrupted. Please try again.');
        },

        received: (data) => {
          this._resetTimeout();

          if (data && typeof data.sequence_number === 'number') {
            this.sequenceQueue.push(data);
            this.sequenceQueue.sort(
              (a, b) => a.sequence_number - b.sequence_number
            );

            while (
              this.sequenceQueue.length &&
              this.sequenceQueue[0].sequence_number ===
                this.currentSequenceNumber
            ) {
              const message = this.sequenceQueue.shift();
              this.onMessage(message);
              this.currentSequenceNumber++;
            }
          }
        },

        rejected: () => {
          this.onError('Connection was rejected. Please try again later.');
        },
      }
    );
  }

  unsubscribe() {
    this._clearTimeout();
    if (this.subscription) {
      this.subscription.unsubscribe();
      this.subscription = null;
    }
  }

  _startTimeout() {
    this._clearTimeout();
    this.timeoutId = setTimeout(() => {
      this.onTimeout();
    }, CONFIG.MESSAGE_TIMEOUT_MS);
  }

  _resetTimeout() {
    this._startTimeout();
  }

  _clearTimeout() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    }
  }
}

// Main chat session orchestrator
export class ChatSession {
  constructor(context) {
    this.context = context;
    this.name = context.name || 'Lightward';

    // Initialize components
    this.storage = new ChatStorage(context);
    this.ui = new ChatUI(this.name);
    this.streamController = new MessageStreamController(
      CONFIG.MIN_MESSAGE_UPDATE_INTERVAL,
      CONFIG.MAX_MESSAGE_UPDATE_INTERVAL
    );
    this.subscription = new ChatSubscription(
      createConsumer(),
      this._handleMessage.bind(this),
      this._handleError.bind(this),
      this._handleTimeout.bind(this)
    );

    // State
    this.messages = this.storage.loadMessages();
    this.currentAssistantElement = null;

    // Bind event handlers
    this._boundHandlers = {
      handleUserSubmit: this._handleUserSubmit.bind(this),
      handleUserInput: this._handleUserInput.bind(this),
      handleResponseClick: this._handleResponseClick.bind(this),
      handleStartOver: this._handleStartOver.bind(this),
      handleCopyAll: this._handleCopyAll.bind(this),
      handleKeyDown: this._handleKeyDown.bind(this),
      saveScrollPosition: () => this.storage.saveScrollPosition(),
    };
  }

  init() {
    // Restore scroll position
    const scrollY = this.storage.loadScrollPosition();
    if (scrollY !== null) {
      window.scrollTo(0, scrollY);
    }

    // Load existing messages
    this._loadExistingMessages();

    // Show UI
    this.ui.showChat();

    // Restore scroll after messages loaded
    if (scrollY !== null) {
      window.scrollTo(0, scrollY);
    }

    // Setup event listeners
    this._setupEventListeners();

    // Restore user input
    const savedInput = this.storage.loadUserInput();
    if (savedInput) {
      this.ui.setUserInput(savedInput);
    }
  }

  _loadExistingMessages() {
    if (this.messages.length) {
      this.messages.forEach((message) => {
        this.ui.addMessage(message.role, message.content[0].text);
      });

      this.ui.hideStartSuggestions();
      this.ui.showChatLog();
      this.ui.enableUserInput();
    }
  }

  _setupEventListeners() {
    // User input handling
    this.ui.elements.userInput.addEventListener(
      'keydown',
      this._boundHandlers.handleKeyDown
    );
    this.ui.elements.userInput.addEventListener(
      'input',
      this._boundHandlers.handleUserInput
    );
    this.ui.elements.submitButton.addEventListener(
      'click',
      this._boundHandlers.handleUserSubmit
    );

    // Response suggestions
    document.querySelectorAll('prompt-button').forEach((button) => {
      button.addEventListener(
        'prompt-button-click',
        this._boundHandlers.handleResponseClick
      );
    });

    // Tools
    this.ui.elements.startOverButton.addEventListener(
      'click',
      this._boundHandlers.handleStartOver
    );
    this.ui.elements.copyAllButton.addEventListener(
      'click',
      this._boundHandlers.handleCopyAll
    );

    // Window events
    window.addEventListener('beforeunload', () =>
      this.subscription.unsubscribe()
    );

    // Scroll position tracking
    ['scroll', 'resize'].forEach((event) => {
      window.addEventListener(event, this._boundHandlers.saveScrollPosition);
    });
  }

  _handleKeyDown(event) {
    if (event.key === 'Enter') {
      if (event.metaKey || event.ctrlKey) {
        event.preventDefault();
        this._submitUserMessage(this.ui.elements.userInput.value);
      } else {
        this.ui.elements.userInputArea.classList.add('multiline');
      }
    }
  }

  _handleUserInput(event) {
    this.storage.saveUserInput(event.target.value);
  }

  _handleUserSubmit(event) {
    event.preventDefault();
    this._submitUserMessage(this.ui.elements.userInput.value);
  }

  _handleResponseClick(event) {
    event.preventDefault();
    const message = event.target.innerHTML.trim();
    this._addUserMessage(message);
    this._fetchAssistantResponse();
  }

  _submitUserMessage(text) {
    const message = text.trim();
    if (!message) return;

    this._addUserMessage(message);
    this.ui.clearUserInput();
    this._fetchAssistantResponse();
  }

  _addUserMessage(text) {
    this.ui.addMessage('user', text);
    this.messages.push({
      role: 'user',
      content: [{ type: 'text', text }],
    });
    this.storage.saveMessages(this.messages);
    this.storage.saveScrollPosition();
  }

  _fetchAssistantResponse() {
    this.ui.hideResponseSuggestions();
    this.ui.hideUserInput();
    this.ui.updateFooterVisibility(this.messages.length);

    // Create pulsing message
    this.currentAssistantElement = this.ui.addPulsingMessage('assistant');
    this.streamController.reset();
    this.streamController.setElement(this.currentAssistantElement);

    // Fetch response
    fetch('/chats/message', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_log: this.messages }),
    })
      .then((response) => {
        if (response.status === 200) {
          return response.json();
        } else {
          return response.text().then((text) => {
            throw new Error(text);
          });
        }
      })
      .then((data) => {
        this.subscription.subscribe(data.stream_id);
      })
      .catch((error) => {
        console.error('Error:', error);
        this._appendError(error.message);
        this._completeMessageWithError();
      });
  }

  _handleMessage(data) {
    switch (data.event) {
      case 'message_start':
        this.ui.stopPulsingLoading(this.currentAssistantElement);
        this.ui.showUserInput();
        break;

      case 'content_block_delta':
        if (
          data.data.delta.type === 'text_delta' &&
          this.currentAssistantElement
        ) {
          this.streamController.addChunk(data.data.delta.text);
        }
        break;

      case 'message_stop':
        this.streamController.complete(() => {
          this._saveAssistantMessage();
          this.ui.enableUserInput(true);
          this.storage.saveScrollPosition();
        });
        break;

      case 'end':
        this.subscription.unsubscribe();
        this.ui.enableUserInput();
        break;

      case 'error':
        this._appendError(data.data.error.message);
        this.subscription.unsubscribe();
        this._completeMessageWithError();
        break;
    }

    // Always persist after processing
    this.storage.saveMessages(this.messages);
    this.storage.clearUserInput();
  }

  _handleError(message) {
    this._appendError(message);
    this._completeMessageWithError();
  }

  _handleTimeout() {
    this._appendError(
      'Your connection was lost during the reply. Please try again.'
    );
    this.subscription.unsubscribe();
    this._completeMessageWithError();
  }

  _appendError(message) {
    const errorText = ` ⚠️ Lightward AI system error: ${message}`;

    if (this.currentAssistantElement) {
      this.streamController.addChunk(errorText);
    } else {
      this.currentAssistantElement = this.ui.addMessage('assistant', errorText);
    }
  }

  _saveAssistantMessage() {
    if (!this.currentAssistantElement) return;

    const text = this.currentAssistantElement.textContent;

    if (
      this.messages.length > 0 &&
      this.messages[this.messages.length - 1].role === 'assistant'
    ) {
      this.messages[this.messages.length - 1].content[0].text = text;
    } else {
      this.messages.push({
        role: 'assistant',
        content: [{ type: 'text', text }],
      });
    }

    this.storage.saveMessages(this.messages);
  }

  _completeMessageWithError() {
    // Flush any pending message chunks immediately
    this.streamController.flush();

    // Stop any loading animations
    this.ui.stopPulsingLoading(this.currentAssistantElement);

    // Save the error message
    this._saveAssistantMessage();

    this.ui.enableUserInput(true);
    this.ui.showResponseSuggestions();
    this.storage.saveScrollPosition();
  }

  _handleStartOver(event) {
    event.preventDefault();

    if (
      !confirm(
        'Are you sure you want to start over? This will clear the chat log. There is no undo. :)'
      )
    ) {
      return;
    }

    this.storage.clearMessages();

    if (event.metaKey || event.ctrlKey) {
      window.scrollTo({ top: 0, behavior: 'instant' });
      location.reload();
    } else {
      this.ui.startVanishAnimation();
      window.scrollTo({ top: 0, behavior: 'smooth' });
      setTimeout(() => location.reload(), 2000);
    }
  }

  _handleCopyAll(event) {
    event.preventDefault();

    const shouldEscapeMarkdown = event.metaKey || event.ctrlKey;
    const escapeMarkdown = (text) => {
      if (!shouldEscapeMarkdown) return text;
      return text.replace(/(?<!\\)\*/g, '\\*');
    };

    const plaintext = this.messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : this.name;
        const content = message.content
          .map((c) => escapeMarkdown(c.text))
          .join('\n');
        return `# ${role}\n\n${content}`;
      })
      .join('\n\n');

    const richtext = this.messages
      .map((message) => {
        const role = message.role === 'user' ? 'You' : this.name;
        const content = message.content.map((c) => c.text).join('\n\n');
        const blockquote = `<blockquote>${content.split('\n').join('<br>')}</blockquote>`;
        return `<b>${role}</b><br>${blockquote}`;
      })
      .join('<br><br>');

    const data = [
      new ClipboardItem({
        'text/plain': new Blob([plaintext], { type: 'text/plain' }),
        'text/html': new Blob([richtext], { type: 'text/html' }),
      }),
    ];

    navigator.clipboard.write(data).then(() => {
      this.ui.updateCopyButton('Copied!');
    });
  }
}

// Initialize chat on load
export const initChat = () => {
  const context = JSON.parse(
    document.getElementById('chat-context-data').textContent
  );

  const session = new ChatSession(context);
  session.init();
};
