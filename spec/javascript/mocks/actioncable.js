// Mock for @rails/actioncable
export const createConsumer = jest.fn(() => {
  return {
    subscriptions: {
      create: jest.fn((channel, handlers) => {
        return {
          perform: jest.fn(),
          unsubscribe: jest.fn(),
          // Allow tests to trigger handlers
          _trigger: (event, data) => {
            if (handlers[event]) {
              handlers[event](data);
            }
          }
        };
      })
    }
  };
});