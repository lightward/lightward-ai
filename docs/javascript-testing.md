# JavaScript Testing & CI

## Local Development

### Running Tests

```bash
# Run all tests once
npm test

# Run tests in watch mode (auto-reruns on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage

# Run tests as CI does (with coverage in CI format)
npm run test:ci
```

### First Time Setup

```bash
# Install dependencies
npm install
```

## Continuous Integration

JavaScript tests are automatically run on:
- Every pull request
- Every push to main branch
- Daily scheduled runs

The CI workflow (`jest` job in `.github/workflows/test.yml`):
1. Sets up Node.js 20
2. Installs dependencies with `npm ci`
3. Runs all JavaScript tests with coverage reporting

## Test Coverage

- Coverage reports are generated during CI runs
- Local coverage reports: `npm run test:coverage` then open `coverage/lcov-report/index.html`
- Minimum coverage targets can be configured in `package.json` under `jest.coverageThreshold`

## Adding New Tests

1. Create test files next to the code they test, or in `spec/javascript/`
2. Name test files with `.test.js` suffix
3. Follow existing patterns for test structure
4. Run tests locally before pushing

## Troubleshooting

### Tests pass locally but fail in CI
- Ensure all dependencies are in package.json (not installed globally)
- Check Node.js version matches CI (v20)
- Verify no hardcoded paths or environment-specific code

### Module not found errors
- Run `npm install` to ensure all dependencies are installed
- Check import paths are correct and relative

### Coverage is lower than expected
- Ensure all source files are imported in at least one test
- Check jest configuration includes all source directories