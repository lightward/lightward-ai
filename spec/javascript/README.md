# JavaScript Testing Guide

This directory contains JavaScript tests for the Lightward AI chat functionality.

## Setup

First, install the dependencies:

```bash
npm install
```

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode (reruns on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

## Test Structure

The tests are organized to mirror the source code structure:

```
spec/javascript/
├── concerns/
│   └── chat/
│       ├── ChatStorage.test.js      # Storage/persistence tests
│       ├── ChatUI.test.js           # UI manipulation tests
│       ├── MessageStreamController.test.js  # Message streaming tests
│       ├── ChatSubscription.test.js  # WebSocket subscription tests
│       └── ChatSession.integration.test.js  # Full integration tests
├── mocks/
│   └── actioncable.js               # Mock for Rails ActionCable
└── setup.js                         # Test environment setup
```

## Test Types

### Unit Tests
- **ChatStorage.test.js**: Tests localStorage operations, message persistence
- **ChatUI.test.js**: Tests DOM manipulation, UI state changes
- **MessageStreamController.test.js**: Tests message chunking and rate limiting
- **ChatSubscription.test.js**: Tests WebSocket handling and message sequencing

### Integration Tests
- **ChatSession.integration.test.js**: Tests the full chat flow including:
  - User message submission
  - WebSocket connection
  - Message streaming
  - Error handling
  - UI updates

## Writing New Tests

### Basic Test Structure

```javascript
import { ComponentName } from 'path/to/component';

describe('ComponentName', () => {
  let component;
  
  beforeEach(() => {
    // Setup before each test
    component = new ComponentName();
  });
  
  afterEach(() => {
    // Cleanup after each test
    jest.clearAllMocks();
  });
  
  describe('methodName', () => {
    it('should do something specific', () => {
      // Arrange
      const input = 'test';
      
      // Act
      const result = component.methodName(input);
      
      // Assert
      expect(result).toBe('expected');
    });
  });
});
```

### Testing DOM Interactions

```javascript
import { screen } from '@testing-library/dom';
import userEvent from '@testing-library/user-event';

it('should handle user input', async () => {
  const user = userEvent.setup();
  
  // Find element
  const button = screen.getByRole('button', { name: 'Submit' });
  
  // Interact
  await user.click(button);
  
  // Assert
  expect(something).toHaveHappened();
});
```

### Testing Async Operations

```javascript
import { waitFor } from '@testing-library/dom';

it('should handle async operation', async () => {
  // Trigger async operation
  component.fetchData();
  
  // Wait for condition
  await waitFor(() => {
    expect(screen.getByText('Data loaded')).toBeInTheDocument();
  });
});
```

### Mocking Dependencies

```javascript
// Mock fetch
global.fetch = jest.fn().mockResolvedValue({
  status: 200,
  json: () => Promise.resolve({ data: 'test' })
});

// Mock timers
jest.useFakeTimers();
// ... test code ...
jest.advanceTimersByTime(1000);
jest.useRealTimers();
```

## Coverage Goals

We aim for high test coverage on critical components:

- **ChatSession**: 90%+ (critical orchestration logic)
- **MessageStreamController**: 90%+ (user experience critical)
- **ChatStorage**: 100% (data integrity critical)
- **ChatUI**: 80%+ (focus on interaction logic)
- **ChatSubscription**: 90%+ (connection reliability critical)

## Debugging Tests

1. **Run single test file**:
   ```bash
   npx jest spec/javascript/concerns/chat/ChatUI.test.js
   ```

2. **Run tests matching pattern**:
   ```bash
   npx jest -t "should handle user input"
   ```

3. **Debug in VSCode**:
   Add breakpoints and use the JavaScript Debug Terminal

4. **Check coverage gaps**:
   ```bash
   npm run test:coverage
   open coverage/lcov-report/index.html
   ```

## Common Issues

### "Cannot find module" errors
- Ensure import paths match the actual file structure
- Check that mocks are properly configured in jest config

### Timeout errors
- Use `jest.useFakeTimers()` for time-dependent tests
- Increase timeout for integration tests: `jest.setTimeout(10000)`

### DOM not updating
- Use `waitFor` for async DOM changes
- Ensure events are properly dispatched

### ActionCable mock not working
- Check that the mock is imported before the component
- Verify the mock matches the expected API

## Best Practices

1. **Test behavior, not implementation**
   - Focus on what the user experiences
   - Don't test internal state directly

2. **Keep tests isolated**
   - Each test should be independent
   - Use beforeEach/afterEach for setup/cleanup

3. **Use descriptive test names**
   - "should [do something] when [condition]"
   - Make failures self-explanatory

4. **Test edge cases**
   - Empty states
   - Error conditions
   - Network failures
   - Race conditions

5. **Maintain test quality**
   - Refactor tests alongside code
   - Remove redundant tests
   - Keep tests simple and focused