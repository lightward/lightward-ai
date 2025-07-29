import { ChatSubscription } from '../../../../app/javascript/src/concerns/chat';

describe('ChatSubscription', () => {
  let subscription;
  let mockConsumer;
  let mockSubscription;
  let onMessage;
  let onError;
  let onTimeout;

  beforeEach(() => {
    jest.useFakeTimers();
    
    onMessage = jest.fn();
    onError = jest.fn();
    onTimeout = jest.fn();
    
    mockSubscription = {
      perform: jest.fn(),
      unsubscribe: jest.fn()
    };
    
    mockConsumer = {
      subscriptions: {
        create: jest.fn().mockReturnValue(mockSubscription)
      }
    };
    
    subscription = new ChatSubscription(mockConsumer, onMessage, onError, onTimeout);
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe('subscribe', () => {
    it('should create subscription with correct channel', () => {
      subscription.subscribe('test-stream-123');
      
      expect(mockConsumer.subscriptions.create).toHaveBeenCalledWith(
        { channel: 'StreamChannel', stream_id: 'test-stream-123' },
        expect.objectContaining({
          connected: expect.any(Function),
          disconnected: expect.any(Function),
          received: expect.any(Function),
          rejected: expect.any(Function)
        })
      );
    });

    it('should unsubscribe existing subscription before creating new one', () => {
      subscription.subscribe('stream-1');
      subscription.subscribe('stream-2');
      
      expect(mockSubscription.unsubscribe).toHaveBeenCalledTimes(1);
      expect(mockConsumer.subscriptions.create).toHaveBeenCalledTimes(2);
    });
  });

  describe('connection handling', () => {
    let handlers;
    
    beforeEach(() => {
      subscription.subscribe('test-stream');
      handlers = mockConsumer.subscriptions.create.mock.calls[0][1];
    });

    it('should send ready and start timeout on connection', () => {
      handlers.connected();
      
      expect(mockSubscription.perform).toHaveBeenCalledWith('ready');
      
      // Should not timeout immediately
      expect(onTimeout).not.toHaveBeenCalled();
      
      // Advance past timeout
      jest.advanceTimersByTime(30001);
      expect(onTimeout).toHaveBeenCalled();
    });

    it('should handle disconnection', () => {
      handlers.disconnected();
      
      expect(onError).toHaveBeenCalledWith('The connection was interrupted. Please try again.');
    });

    it('should handle rejection', () => {
      handlers.rejected();
      
      expect(onError).toHaveBeenCalledWith('Connection was rejected. Please try again later.');
    });
  });

  describe('message sequencing', () => {
    let handlers;
    
    beforeEach(() => {
      subscription.subscribe('test-stream');
      handlers = mockConsumer.subscriptions.create.mock.calls[0][1];
    });

    it('should process messages in sequence order', () => {
      // Receive messages out of order
      handlers.received({ sequence_number: 2, event: 'third' });
      handlers.received({ sequence_number: 0, event: 'first' });
      handlers.received({ sequence_number: 1, event: 'second' });
      
      // Should be called in correct order
      expect(onMessage).toHaveBeenCalledTimes(3);
      expect(onMessage.mock.calls[0][0]).toEqual({ sequence_number: 0, event: 'first' });
      expect(onMessage.mock.calls[1][0]).toEqual({ sequence_number: 1, event: 'second' });
      expect(onMessage.mock.calls[2][0]).toEqual({ sequence_number: 2, event: 'third' });
    });

    it('should queue messages until sequence is complete', () => {
      handlers.received({ sequence_number: 2, event: 'third' });
      handlers.received({ sequence_number: 1, event: 'second' });
      
      // Should not process yet - waiting for 0
      expect(onMessage).not.toHaveBeenCalled();
      
      handlers.received({ sequence_number: 0, event: 'first' });
      
      // Should process all three in order
      expect(onMessage).toHaveBeenCalledTimes(3);
    });

    it('should reset timeout on each message', () => {
      handlers.connected();
      
      jest.advanceTimersByTime(25000);
      handlers.received({ sequence_number: 0, event: 'test' });
      
      // Should not timeout after original 30s
      jest.advanceTimersByTime(10000);
      expect(onTimeout).not.toHaveBeenCalled();
      
      // Should timeout 30s after last message
      jest.advanceTimersByTime(21000);
      expect(onTimeout).toHaveBeenCalled();
    });
  });

  describe('unsubscribe', () => {
    it('should clear timeout and unsubscribe', () => {
      subscription.subscribe('test-stream');
      const handlers = mockConsumer.subscriptions.create.mock.calls[0][1];
      
      handlers.connected();
      subscription.unsubscribe();
      
      expect(mockSubscription.unsubscribe).toHaveBeenCalled();
      
      // Should not trigger timeout after unsubscribe
      jest.advanceTimersByTime(31000);
      expect(onTimeout).not.toHaveBeenCalled();
    });

    it('should handle unsubscribe when no active subscription', () => {
      expect(() => subscription.unsubscribe()).not.toThrow();
    });
  });
});