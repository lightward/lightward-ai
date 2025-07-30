import { ChatSession } from '../../../../app/javascript/src/concerns/chat';
import { createConsumer } from '@rails/actioncable';
import userEvent from '@testing-library/user-event';
import { waitFor } from '@testing-library/dom';

// Mock fetch
global.fetch = jest.fn();

describe('ChatSession Integration', () => {
  let session;
  let mockSubscription;
  let mockConsumer;

  beforeEach(() => {
    // Mock console.error to keep test output clean
    jest.spyOn(console, 'error').mockImplementation(() => {});
    
    // Set up DOM
    document.body.innerHTML = `
      <div id="chat-context-data">{"key": "test", "name": "TestBot"}</div>
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
      <prompt-button>Suggested prompt</prompt-button>
    `;

    // Set up ActionCable mock
    mockSubscription = {
      perform: jest.fn(),
      unsubscribe: jest.fn(),
      _trigger: jest.fn()
    };

    mockConsumer = {
      subscriptions: {
        create: jest.fn((channel, handlers) => {
          mockSubscription._handlers = handlers;
          mockSubscription._trigger = (event, data) => {
            if (handlers[event]) {
              handlers[event](data);
            }
          };
          return mockSubscription;
        })
      }
    };

    createConsumer.mockReturnValue(mockConsumer);

    // Create session
    const context = { key: 'test', name: 'TestBot' };
    session = new ChatSession(context);
  });

  afterEach(() => {
    jest.clearAllMocks();
    console.error.mockRestore();
  });

  describe('initialization', () => {
    it('should initialize and show chat', () => {
      session.init();

      expect(document.getElementById('chat')).not.toHaveClass('hidden');
      expect(document.getElementById('loading-message')).toBeNull();
    });

    it('should restore previous messages', () => {
      const previousMessages = [
        { role: 'user', content: [{ type: 'text', text: 'Hello' }] },
        { role: 'assistant', content: [{ type: 'text', text: 'Hi there!' }] }
      ];
      localStorage.setItem('test', JSON.stringify(previousMessages));

      session = new ChatSession({ key: 'test', name: 'TestBot' });
      session.init();

      const messages = document.querySelectorAll('.chat-message');
      expect(messages).toHaveLength(2);
      expect(messages[0].textContent).toBe('Hello');
      expect(messages[0]).toHaveClass('user');
      expect(messages[1].textContent).toBe('Hi there!');
      expect(messages[1]).toHaveClass('assistant');
    });
  });

  describe('user message submission', () => {
    beforeEach(() => {
      session.init();
      fetch.mockResolvedValue({
        status: 200,
        json: () => Promise.resolve({ stream_id: 'test-stream-123' })
      });
    });

    it('should handle text input submission', async () => {
      const user = userEvent.setup();
      const textarea = document.querySelector('textarea');
      const submitButton = document.querySelector('#text-input button');

      await user.type(textarea, 'Hello bot');
      await user.click(submitButton);

      // Check user message was added
      const userMessage = document.querySelector('.chat-message.user');
      expect(userMessage.textContent).toBe('Hello bot');

      // Check fetch was called
      expect(fetch).toHaveBeenCalledWith('/chats/message', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_log: [{ role: 'user', content: [{ type: 'text', text: 'Hello bot' }] }]
        })
      });

      // Check subscription was created
      expect(mockConsumer.subscriptions.create).toHaveBeenCalledWith(
        { channel: 'StreamChannel', stream_id: 'test-stream-123' },
        expect.any(Object)
      );
    });

    it('should handle keyboard shortcut submission', async () => {
      const user = userEvent.setup();
      const textarea = document.querySelector('textarea');

      await user.type(textarea, 'Test message');
      await user.keyboard('{Meta>}{Enter}{/Meta}');

      const userMessage = document.querySelector('.chat-message.user');
      expect(userMessage.textContent).toBe('Test message');
    });
  });

  describe('message streaming', () => {
    beforeEach(() => {
      session.init();
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should handle streamed response chunks', async () => {
      // Submit a message
      fetch.mockResolvedValueOnce({
        status: 200,
        json: () => Promise.resolve({ stream_id: 'stream-1' })
      });

      const textarea = document.querySelector('textarea');
      textarea.value = 'Hello';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        expect(mockConsumer.subscriptions.create).toHaveBeenCalled();
      });

      // Trigger connected callback which should call perform
      mockSubscription._trigger('connected');
      expect(mockSubscription.perform).toHaveBeenCalledWith('ready');

      // Simulate message start
      mockSubscription._trigger('received', {
        event: 'message_start',
        sequence_number: 0
      });

      // Simulate content chunks
      mockSubscription._trigger('received', {
        event: 'content_block_delta',
        data: { delta: { type: 'text_delta', text: 'Hello ' } },
        sequence_number: 1
      });

      mockSubscription._trigger('received', {
        event: 'content_block_delta',
        data: { delta: { type: 'text_delta', text: 'there!' } },
        sequence_number: 2
      });

      // Process first chunk immediately
      const assistantMessage = document.querySelector('.chat-message.assistant');
      expect(assistantMessage.textContent).toBe('Hello ');

      // Advance time for rate limiting
      jest.advanceTimersByTime(150);
      expect(assistantMessage.textContent).toBe('Hello there!');

      // Complete message
      mockSubscription._trigger('received', {
        event: 'message_stop',
        sequence_number: 3
      });

      // Wait for all chunks to be processed and message to be saved
      jest.runAllTimers();

      // Ensure message is saved with assistant content
      const calls = localStorage.setItem.mock.calls;
      const lastCallWithTestKey = calls.filter(call => call[0] === 'test').pop();
      expect(lastCallWithTestKey).toBeDefined();
      expect(lastCallWithTestKey[1]).toContain('Hello there!');
      expect(lastCallWithTestKey[1]).toContain('assistant');
    });
  });

  describe('error handling', () => {
    beforeEach(() => {
      session.init();
      jest.useFakeTimers();
    });

    afterEach(() => {
      jest.useRealTimers();
    });

    it('should handle fetch errors', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'));

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        const errorMessage = document.querySelector('.chat-message.assistant');
        expect(errorMessage.textContent).toBe(' ⚠️ Lightward AI system error: Network error');
      });

      expect(console.error).toHaveBeenCalledWith('Error:', expect.any(Error));
    });

    it('should handle streaming errors', async () => {
      fetch.mockResolvedValueOnce({
        status: 200,
        json: () => Promise.resolve({ stream_id: 'stream-1' })
      });

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        expect(mockConsumer.subscriptions.create).toHaveBeenCalled();
      });

      // Trigger error
      mockSubscription._trigger('received', {
        event: 'error',
        data: { error: { message: 'Streaming failed' } },
        sequence_number: 0
      });

      // Error should be queued and displayed
      const assistantMessage = document.querySelector('.chat-message.assistant');
      expect(assistantMessage.textContent).toBe(' ⚠️ Lightward AI system error: Streaming failed');
    });

    it('should handle connection timeout', async () => {
      fetch.mockResolvedValueOnce({
        status: 200,
        json: () => Promise.resolve({ stream_id: 'stream-1' })
      });

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        expect(mockConsumer.subscriptions.create).toHaveBeenCalled();
      });

      // Trigger connection
      mockSubscription._trigger('connected');

      // Advance time past timeout
      jest.advanceTimersByTime(31000);

      const errorMessage = document.querySelector('.chat-message.assistant');
      expect(errorMessage.textContent).toBe(' ⚠️ Lightward AI system error: Your connection was lost during the reply. Please try again.');
    });
  });

  describe('copy functionality', () => {
    it('should copy chat to clipboard', async () => {
      session.init();
      
      // Add some messages
      session.messages = [
        { role: 'user', content: [{ type: 'text', text: 'Hello' }] },
        { role: 'assistant', content: [{ type: 'text', text: 'Hi there!' }] }
      ];

      // Mock clipboard API
      const mockWrite = jest.fn().mockResolvedValue();
      Object.defineProperty(navigator, 'clipboard', {
        value: { write: mockWrite },
        configurable: true
      });
      
      // Track ClipboardItem constructor calls
      const clipboardItems = [];
      global.ClipboardItem = jest.fn((data) => {
        clipboardItems.push(data);
        return data;
      });

      const copyButton = document.getElementById('copy-all-button');
      copyButton.click();

      await waitFor(() => {
        expect(mockWrite).toHaveBeenCalled();
      });

      expect(clipboardItems).toHaveLength(1);
      expect(clipboardItems[0]).toHaveProperty('text/plain');
      expect(clipboardItems[0]).toHaveProperty('text/html');
      
      // Verify the blobs contain expected content
      expect(clipboardItems[0]['text/plain']).toBeInstanceOf(Blob);
      expect(clipboardItems[0]['text/html']).toBeInstanceOf(Blob);
    });
  });

  describe('start over functionality', () => {
    it('should clear chat with confirmation', () => {
      session.init();
      
      // Mock confirm
      global.confirm = jest.fn().mockReturnValue(true);
      global.location = { reload: jest.fn() };

      const startOverButton = document.getElementById('start-over-button');
      startOverButton.click();

      expect(confirm).toHaveBeenCalledWith(
        'Are you sure you want to start over? This will clear the chat log. There is no undo. :)'
      );
      expect(localStorage.removeItem).toHaveBeenCalledWith('test');
      expect(localStorage.setItem).toHaveBeenCalledWith('scrollY', '0');
    });

    it('should not clear if user cancels', () => {
      session.init();
      
      global.confirm = jest.fn().mockReturnValue(false);

      const startOverButton = document.getElementById('start-over-button');
      startOverButton.click();

      expect(localStorage.removeItem).not.toHaveBeenCalledWith('test');
    });
  });
});