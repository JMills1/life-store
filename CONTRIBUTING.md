# Contributing to LifePlanner

Thank you for your interest in contributing to LifePlanner!

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/life-store.git`
3. Follow [SETUP.md](SETUP.md) to configure your development environment
4. Create a new branch: `git checkout -b feature/your-feature-name`

## Development Guidelines

### Code Style

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Comments**: Minimal, self-documenting code preferred
- **Formatting**: Follow Swift standard conventions

### Naming Conventions

- **Files**: PascalCase (e.g., `CalendarView.swift`)
- **Classes/Structs**: PascalCase (e.g., `CalendarViewModel`)
- **Variables/Functions**: camelCase (e.g., `selectedDate`)
- **Constants**: camelCase (e.g., `maxRetries`)

### Project Structure

```
LifeNotes/
├── Config/              # Configuration files
├── Domain/Models/       # Data models
├── Features/            # Feature modules
│   ├── [Feature]/
│   │   ├── Views/       # SwiftUI views
│   │   ├── ViewModels/  # View models
│   │   └── Components/  # Reusable components
├── Services/            # Business logic services
└── Shared/              # Shared utilities
    ├── Components/      # Shared UI components
    ├── Extensions/      # Swift extensions
    └── Theme/           # App theme
```

## Making Changes

### Before You Start

1. Check existing issues for similar work
2. Create an issue describing your proposed changes
3. Wait for feedback before starting major work

### Development Process

1. **Write Tests**: Add unit tests for new features
2. **Follow Architecture**: Use MVVM pattern
3. **Update Documentation**: Update relevant .md files
4. **Test Thoroughly**: Test on simulator and device
5. **Check Lints**: Ensure no warnings or errors

### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add event comment threading
fix: Resolve calendar scrolling issue
docs: Update setup instructions
refactor: Simplify workspace manager
test: Add calendar view model tests
```

### Pull Request Process

1. Update README.md or ARCHITECTURE.md if needed
2. Ensure all tests pass
3. Update CHANGELOG.md (if exists)
4. Create pull request with clear description
5. Link related issues

## Testing

### Running Tests

```bash
# Run all tests
Cmd + U in Xcode

# Run specific test
Right-click test → Run
```

### Test Coverage

Aim for:
- ViewModels: 80%+ coverage
- Services: 70%+ coverage
- Models: 60%+ coverage

## Code Review

All submissions require review. We use GitHub pull requests for this purpose.

### Review Criteria

- Code follows project conventions
- Tests are included and passing
- Documentation is updated
- No breaking changes (or clearly documented)
- Performance impact is acceptable

## Feature Requests

1. Check existing issues first
2. Create new issue with "Feature Request" label
3. Describe the feature and use case
4. Wait for discussion before implementing

## Bug Reports

Include:
- iOS version
- Device model
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable
- Relevant logs

## Questions?

- Open an issue with "Question" label
- Check [ARCHITECTURE.md](ARCHITECTURE.md) for technical details
- Review [SETUP.md](SETUP.md) for setup help

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

## Thank You!

Your contributions make LifePlanner better for everyone. We appreciate your time and effort!

