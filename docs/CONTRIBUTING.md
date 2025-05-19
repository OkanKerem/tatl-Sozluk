# Contributing to Tatlı Sözlük

Thank you for considering contributing to Tatlı Sözlük! This document provides guidelines and instructions for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/tatl-Sozluk.git`
3. Create a branch for your changes: `git checkout -b feature/your-feature-name`

## Development Setup

1. Install Flutter SDK following the [official documentation](https://flutter.dev/docs/get-started/install)
2. Install dependencies: `flutter pub get`
3. Create a `.env` file with Firebase configuration (see `.env.example`)
4. Run the project: `flutter run`

## Coding Standards

### Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use linting rules defined in `analysis_options.yaml`
- Run `flutter format .` before committing

### Commit Messages

Follow conventional commits format:

```
feat: Add new feature
fix: Fix an issue
docs: Update documentation
style: Format code
refactor: Code change that neither fixes a bug nor adds a feature
test: Add or update tests
```

### Pull Request Process

1. Update documentation as needed
2. Write tests for new functionality
3. Ensure all tests pass: `flutter test`
4. Create a pull request with a clear description
5. Request review from at least one maintainer

## Feature Requests

If you have ideas for new features, please open an issue with the label "enhancement" and use the feature request template.

## Bug Reports

When reporting bugs:

1. Use the bug report template
2. Include detailed steps to reproduce
3. Describe expected vs. actual behavior
4. Include screenshots if applicable
5. Provide device/environment information

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the issue, not the person
- Welcome newcomers and help them get started

## License

By contributing, you agree that your contributions will be licensed under the project's license.

Thank you for contributing to Tatlı Sözlük! 