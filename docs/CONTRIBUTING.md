# Contributing to Game Center

Thank you for your interest in contributing to Game Center! This document outlines our guidelines and process for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions with other contributors.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/your-username/game-center.git
   cd Game\ Center\ Project
   ```
3. **Install dependencies**:
   ```bash
   npm install
   ```
4. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Process

1. **Make your changes** following the code style guidelines
2. **Test your changes**:
   ```bash
   npm test
   ```
3. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add new chaos weapon effects"
   ```
4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create a Pull Request** with a clear description

## Code Style

- **JavaScript**: Use ES6+ syntax, 4-space indentation
- **HTML**: Use 2-space indentation
- **CSS**: Use 2-space indentation
- **Comments**: Use meaningful comments to explain complex logic
- **No commented code**: Remove debug code before submitting

### EditorConfig

This project uses EditorConfig. Please install the EditorConfig plugin for your editor to maintain consistent style.

## Commit Messages

Follow conventional commits format:

```
type(scope): subject

body (optional)
```

**Types**: feat, fix, docs, style, refactor, perf, test, chore
**Example**: `feat(weapons): add chaos bullet rendering`

## Testing

- Write tests for new features
- Ensure all tests pass: `npm test`
- Update tests when modifying existing functionality

## Documentation

- Update README.md if adding new features
- Add JSDoc comments for new functions
- Update API documentation if relevant

## Pull Request Guidelines

1. **Title**: Clear and descriptive
2. **Description**: Explain what changes were made and why
3. **Testing**: Describe how you tested the changes
4. **Screenshots**: Include screenshots for UI changes
5. **Issues**: Reference any related issues with `#issue-number`

## Reporting Bugs

When reporting bugs, include:

- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots/videos if applicable
- Browser/OS information

## Feature Requests

Feature requests are welcome! Include:

- Clear description of the feature
- Why you think it would be useful
- Possible implementation approach (optional)

## Performance Considerations

- Minimize memory usage
- Avoid blocking operations
- Cache expensive calculations
- Use efficient algorithms

## Security

If you find a security vulnerability, please email it to the maintainers instead of posting publicly.

## License

By contributing, you agree that your contributions will be licensed under the Apache License 2.0.

## Questions?

Feel free to open an issue with the label `question` if you have any questions.

Thank you for contributing!
