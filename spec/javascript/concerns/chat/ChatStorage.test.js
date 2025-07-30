import { ChatStorage } from '../../../../app/javascript/src/concerns/chat';

describe('ChatStorage', () => {
  let storage;
  const mockContext = { key: 'test-chat' };

  beforeEach(() => {
    storage = new ChatStorage(mockContext);
  });

  describe('constructor', () => {
    it('should set up storage keys', () => {
      expect(storage.messagesKey).toBe('test-chat');
      expect(storage.userInputKey).toBe('test-chat/input');
    });
  });

  describe('loadMessages', () => {
    it('should return empty array when no messages exist', () => {
      expect(storage.loadMessages()).toEqual([]);
    });

    it('should parse and return stored messages', () => {
      const messages = [{ role: 'user', content: [{ text: 'test' }] }];
      localStorage.setItem('test-chat', JSON.stringify(messages));

      expect(storage.loadMessages()).toEqual(messages);
    });
  });

  describe('saveMessages', () => {
    it('should stringify and save messages', () => {
      const messages = [{ role: 'assistant', content: [{ text: 'response' }] }];

      storage.saveMessages(messages);

      expect(localStorage.setItem).toHaveBeenCalledWith(
        'test-chat',
        JSON.stringify(messages)
      );
    });
  });

  describe('user input methods', () => {
    it('should save and load user input', () => {
      storage.saveUserInput('test input');
      expect(localStorage.setItem).toHaveBeenCalledWith(
        'test-chat/input',
        'test input'
      );
    });

    it('should clear user input', () => {
      storage.clearUserInput();
      expect(localStorage.removeItem).toHaveBeenCalledWith('test-chat/input');
    });

    it('should return empty string when no input saved', () => {
      expect(storage.loadUserInput()).toBe('');
    });
  });

  describe('scroll position', () => {
    it('should save scroll position', () => {
      global.scrollY = 500;
      storage.saveScrollPosition();
      expect(localStorage.setItem).toHaveBeenCalledWith('scrollY', 500);
    });

    it('should load scroll position as number', () => {
      localStorage.setItem('scrollY', '250');
      expect(storage.loadScrollPosition()).toBe(250);
    });

    it('should return null when no scroll position saved', () => {
      expect(storage.loadScrollPosition()).toBeNull();
    });
  });

  describe('clearMessages', () => {
    it('should remove messages and reset scroll', () => {
      storage.clearMessages();

      expect(localStorage.removeItem).toHaveBeenCalledWith('test-chat');
      expect(localStorage.setItem).toHaveBeenCalledWith('scrollY', '0');
    });
  });
});
