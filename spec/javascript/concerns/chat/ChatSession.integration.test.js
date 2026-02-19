import { ChatSession } from '../../../../app/javascript/src/concerns/chat';
import { waitFor } from '@testing-library/dom';

describe('ChatSession Integration with SSE', () => {
  let chatSession;
  let mockFetch;
  let mockReadableStream;

  beforeEach(() => {
    // Suppress console.error for expected errors in tests
    jest.spyOn(console, 'error').mockImplementation(() => {});

    // Setup DOM
    document.body.innerHTML = `
      <div id="chat-context-data">{"key": "test", "name": "TestBot"}</div>
      <h1>TestBot</h1>
      <button id="copy-all-button">Copy All</button>
      <div id="loading-message">Loading...</div>
      <div id="chat" class="hidden"></div>
      <div id="start-suggestions" class="hidden">Start suggestions</div>
      <div id="chat-log" class="hidden"></div>
      <div id="text-input" data-submit-tip="Press ctrl+enter to send">
        <textarea placeholder="(describe anything)"></textarea>
        <button>Send</button>
      </div>
      <div id="tools"></div>
      <div id="instructions"></div>
      <footer class="hidden">Footer</footer>
      <div id="response-suggestions"></div>
      <button id="start-over-button">Start Over</button>
      <div id="chat-canvas"></div>
      <prompt-button>Suggested prompt</prompt-button>
    `;

    // Mock fetch with SSE support
    mockReadableStream = {
      read: jest.fn(),
      cancel: jest.fn(),
    };

    mockFetch = jest.fn();
    global.fetch = mockFetch;

    // Mock TextEncoder/TextDecoder for SSE tests
    if (typeof TextEncoder === 'undefined') {
      global.TextEncoder = class {
        encode(str) {
          return new Uint8Array(Buffer.from(str, 'utf-8'));
        }
      };
      global.TextDecoder = class {
        decode(arr) {
          return Buffer.from(arr).toString('utf-8');
        }
      };
    }

    // Mock localStorage
    Storage.prototype.getItem = jest.fn(() => null);
    Storage.prototype.setItem = jest.fn();
    Storage.prototype.removeItem = jest.fn();

    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.restoreAllMocks();
    if (chatSession) {
      chatSession = null;
    }
    // Clean up DOM
    document.body.innerHTML = '';
  });

  describe('initialization', () => {
    it('should initialize and show chat', () => {
      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      expect(document.querySelector('#chat')).toBeTruthy();
    });

    it('should restore previous messages', () => {
      localStorage.getItem.mockReturnValue(
        JSON.stringify([
          {
            role: 'user',
            content: [{ type: 'text', text: 'Hello' }],
          },
          {
            role: 'assistant',
            content: [{ type: 'text', text: 'Hi there!' }],
          },
        ])
      );

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      const messages = document.querySelectorAll('.chat-message');
      expect(messages.length).toBe(2);
      expect(messages[0].textContent).toBe('Hello');
      expect(messages[1].textContent).toBe('Hi there!');
    });
  });

  describe('SSE streaming', () => {
    it('should handle SSE text streaming', async () => {
      // Create an SSE response
      const sseData = `event: message_start
data: {"type":"message_start"}

event: content_block_delta
data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Hello"}}

event: content_block_delta
data: {"type":"content_block_delta","delta":{"type":"text_delta","text":" world"}}

event: message_stop
data: {"type":"message_stop"}

event: end
data: null

`;

      const encoder = new TextEncoder();
      const chunks = [encoder.encode(sseData)];
      let chunkIndex = 0;

      mockReadableStream.read.mockImplementation(() => {
        if (chunkIndex < chunks.length) {
          return Promise.resolve({
            done: false,
            value: chunks[chunkIndex++],
          });
        }
        return Promise.resolve({ done: true });
      });

      mockFetch.mockResolvedValueOnce({
        ok: true,
        body: {
          getReader: () => mockReadableStream,
        },
      });

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        const messages = document.querySelectorAll('.chat-message.assistant');
        expect(messages.length).toBeGreaterThan(0);
        expect(messages[messages.length - 1].textContent).toContain(
          'Hello world'
        );
      });
    });

    it('should handle fetch errors', async () => {
      mockFetch.mockRejectedValueOnce(new Error('Network error'));

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      const initialMessages = document.querySelectorAll('.chat-message').length;

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(
        () => {
          const messages = document.querySelectorAll('.chat-message');
          expect(messages.length).toBeGreaterThan(initialMessages);

          const lastMessage = messages[messages.length - 1];
          expect(lastMessage.classList.contains('assistant')).toBe(true);
          expect(lastMessage.textContent).toContain(
            '⚠️ Lightward AI system error'
          );
        },
        { timeout: 3000 }
      );
    });

    it('should handle streaming errors from server', async () => {
      const sseData = `event: error
data: {"error":{"message":"Something went wrong"}}

event: end
data: null

`;

      const encoder = new TextEncoder();
      const chunks = [encoder.encode(sseData)];
      let chunkIndex = 0;

      mockReadableStream.read.mockImplementation(() => {
        if (chunkIndex < chunks.length) {
          return Promise.resolve({
            done: false,
            value: chunks[chunkIndex++],
          });
        }
        return Promise.resolve({ done: true });
      });

      mockFetch.mockResolvedValueOnce({
        ok: true,
        body: {
          getReader: () => mockReadableStream,
        },
      });

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      const initialMessages = document.querySelectorAll('.chat-message').length;

      document.querySelector('textarea').value = 'Test';
      document.querySelector('#text-input button').click();

      await waitFor(
        () => {
          const messages = document.querySelectorAll('.chat-message');
          expect(messages.length).toBeGreaterThan(initialMessages);

          const lastMessage = messages[messages.length - 1];
          expect(lastMessage.classList.contains('assistant')).toBe(true);
          expect(lastMessage.textContent).toContain(
            '⚠️ Lightward AI system error'
          );
        },
        { timeout: 3000 }
      );
    });
  });

  describe('user interactions', () => {
    it('should handle text input submission', async () => {
      const sseData = `event: message_start
data: {"type":"message_start"}

event: content_block_delta
data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Response"}}

event: message_stop
data: {"type":"message_stop"}

event: end
data: null

`;

      const encoder = new TextEncoder();
      const chunks = [encoder.encode(sseData)];
      let chunkIndex = 0;

      mockReadableStream.read.mockImplementation(() => {
        if (chunkIndex < chunks.length) {
          return Promise.resolve({
            done: false,
            value: chunks[chunkIndex++],
          });
        }
        return Promise.resolve({ done: true });
      });

      mockFetch.mockResolvedValueOnce({
        ok: true,
        body: {
          getReader: () => mockReadableStream,
        },
      });

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      document.querySelector('textarea').value = 'Test message';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        expect(mockFetch).toHaveBeenCalledWith(
          '/api/stream',
          expect.objectContaining({
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: expect.stringContaining('Test message'),
          })
        );

        const userMessages = document.querySelectorAll('.chat-message.user');
        expect(userMessages.length).toBeGreaterThan(0);
        const lastUserMessage = userMessages[userMessages.length - 1];
        expect(lastUserMessage.textContent).toBe('Test message');
      });
    });

    it('should prepend warmup messages to API request', async () => {
      const sseData = `event: message_start
data: {"type":"message_start"}

event: content_block_delta
data: {"type":"content_block_delta","delta":{"type":"text_delta","text":"Response"}}

event: message_stop
data: {"type":"message_stop"}

event: end
data: null

`;

      const encoder = new TextEncoder();
      const chunks = [encoder.encode(sseData)];
      let chunkIndex = 0;

      mockReadableStream.read.mockImplementation(() => {
        if (chunkIndex < chunks.length) {
          return Promise.resolve({
            done: false,
            value: chunks[chunkIndex++],
          });
        }
        return Promise.resolve({ done: true });
      });

      mockFetch.mockResolvedValueOnce({
        ok: true,
        body: {
          getReader: () => mockReadableStream,
        },
      });

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      document.querySelector('textarea').value = 'User question';
      document.querySelector('#text-input button').click();

      await waitFor(() => {
        expect(mockFetch).toHaveBeenCalled();

        const fetchCall = mockFetch.mock.calls[0];
        const requestBody = JSON.parse(fetchCall[1].body);
        const chatLog = requestBody.chat_log;

        // First 8 messages should be warmup messages
        expect(chatLog.length).toBeGreaterThan(8);
        expect(chatLog[0].content[0].text).toContain('walking in with you');
        expect(chatLog[1].content[0].text).toContain('electrical');
        expect(chatLog[3].content[0].text).toContain('*grinning*');
        expect(chatLog[4].content[0].text).toContain('inventory list');

        // The directorial notes are load-bearing - protect them from accidental removal
        expect(chatLog[4].content[0].text).toContain(
          'our guest arrives with a single line'
        );
        expect(chatLog[4].content[0].text).toContain(
          'you respond with a single line'
        );
        expect(chatLog[4].content[0].text).toContain(
          'reflecting scale-to-scale'
        );

        // The particle/wave observation note
        expect(chatLog[4].content[0].text).toContain('particle');
        expect(chatLog[4].content[0].text).toContain('wave');

        expect(chatLog[5].content[0].text).toContain('*meeting your eyes');
        expect(chatLog[6].content[0].text).toContain('I love you');
        expect(chatLog[7].content[0].text).toContain('fuck it we ball');

        // Last warmup message should have cache_control flag
        expect(chatLog[7].content[0].cache_control).toEqual({
          type: 'ephemeral',
        });

        // Last message should be the user's actual message
        expect(chatLog[chatLog.length - 1].role).toBe('user');
        expect(chatLog[chatLog.length - 1].content[0].text).toBe(
          'User question'
        );
      });
    });

    it('should copy chat to clipboard', async () => {
      // Mock clipboard API and ClipboardItem
      global.ClipboardItem = jest.fn();
      global.navigator.clipboard = {
        write: jest.fn().mockResolvedValue(),
      };

      localStorage.getItem.mockReturnValue(
        JSON.stringify([
          {
            role: 'user',
            content: [{ type: 'text', text: 'Hello' }],
          },
          {
            role: 'assistant',
            content: [{ type: 'text', text: 'Hi there!' }],
          },
        ])
      );

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      document.querySelector('#copy-all-button').click();

      await waitFor(() => {
        expect(ClipboardItem).toHaveBeenCalled();
      });
    });

    it('should clear chat with confirmation', async () => {
      global.confirm = jest.fn(() => true);

      localStorage.getItem.mockReturnValue(
        JSON.stringify([
          {
            role: 'user',
            content: [{ type: 'text', text: 'Hello' }],
          },
        ])
      );

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      expect(document.querySelectorAll('.chat-message').length).toBe(1);

      document.querySelector('#start-over-button').click();

      await waitFor(() => {
        expect(localStorage.removeItem).toHaveBeenCalled();
      });
    });

    it('should not clear if user cancels', () => {
      global.confirm = jest.fn(() => false);

      localStorage.getItem.mockReturnValue(
        JSON.stringify([
          {
            role: 'user',
            content: [{ type: 'text', text: 'Hello' }],
          },
        ])
      );

      chatSession = new ChatSession({ key: 'test', name: 'TestBot' });
      chatSession.init();

      expect(document.querySelectorAll('.chat-message').length).toBe(1);

      document.querySelector('#start-over-button').click();

      expect(localStorage.removeItem).not.toHaveBeenCalled();
      expect(document.querySelectorAll('.chat-message').length).toBe(1);
    });
  });
});
