import { MessageStreamController } from '../../../../app/javascript/src/concerns/chat';

describe('MessageStreamController', () => {
  let controller;
  let mockElement;

  beforeEach(() => {
    jest.useFakeTimers();
    controller = new MessageStreamController(100, 200);
    mockElement = {
      appendChild: jest.fn(),
    };
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  describe('reset', () => {
    it('should initialize with default state', () => {
      expect(controller.queue).toEqual([]);
      expect(controller.isProcessing).toBe(false);
      expect(controller.isComplete).toBe(false);
      expect(controller.currentElement).toBeNull();
    });
  });

  describe('addChunk', () => {
    it('should queue chunks and process them', () => {
      controller.setElement(mockElement);

      controller.addChunk('Hello');
      controller.addChunk(' World');

      expect(controller.queue).toContain(' World');

      // First chunk should be processed immediately
      expect(mockElement.appendChild).toHaveBeenCalledTimes(1);
      expect(mockElement.appendChild.mock.calls[0][0].textContent).toBe(
        'Hello'
      );
    });
  });

  describe('rate limiting', () => {
    it('should delay between chunks', () => {
      controller.setElement(mockElement);

      // Add and process first chunk
      controller.addChunk('First');
      expect(mockElement.appendChild).toHaveBeenCalledTimes(1);
      expect(controller.queue).toHaveLength(0);

      // Add second chunk while first is still "processing"
      controller.addChunk('Second');

      // Second should be queued
      expect(controller.queue).toHaveLength(1);
      expect(mockElement.appendChild).toHaveBeenCalledTimes(1);

      // Advance time to allow processing
      jest.runAllTimers();

      // All chunks should be processed
      expect(mockElement.appendChild).toHaveBeenCalledTimes(2);

      // Verify the chunks were appended in order
      const calls = mockElement.appendChild.mock.calls;
      expect(calls[0][0].textContent).toBe('First');
      expect(calls[1][0].textContent).toBe('Second');
    });
  });

  describe('complete', () => {
    it('should call completion callback when queue is empty', () => {
      const callback = jest.fn();
      controller.setElement(mockElement);

      controller.complete(callback);

      // Should call immediately if queue is empty
      expect(callback).toHaveBeenCalled();
    });

    it('should wait for queue to empty before calling callback', () => {
      const callback = jest.fn();
      controller.setElement(mockElement);

      controller.addChunk('Chunk 1');
      controller.addChunk('Chunk 2');
      controller.complete(callback);

      // Should not call yet
      expect(callback).not.toHaveBeenCalled();

      // Process all chunks
      jest.runAllTimers();

      // Now should be called
      expect(callback).toHaveBeenCalled();
    });
  });

  describe('_processQueue', () => {
    it('should append text nodes to element', () => {
      controller.setElement(mockElement);
      controller.addChunk('Test chunk');

      const textNode = mockElement.appendChild.mock.calls[0][0];
      expect(textNode).toBeInstanceOf(Text);
      expect(textNode.textContent).toBe('Test chunk');
    });

    it('should not process if no element set', () => {
      controller.addChunk('Test');

      expect(mockElement.appendChild).not.toHaveBeenCalled();
    });
  });
});
