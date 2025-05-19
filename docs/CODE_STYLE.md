# Tatlı Sözlük Code Style Guide

This guide outlines the coding conventions and style guidelines for the Tatlı Sözlük project.

## General Principles

- **Readability**: Write code that is easy to read and understand.
- **Consistency**: Follow consistent patterns throughout the codebase.
- **Simplicity**: Keep code simple and avoid unnecessary complexity.
- **Documentation**: Document code appropriately with comments and documentation.

## Dart Style Guide

We follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with some project-specific additions.

### Naming Conventions

#### Files

- Use `snake_case` for file names: `user_model.dart`, `entry_service.dart`
- Widget files should be named after the primary widget they contain

#### Classes

- Use `PascalCase` for class names: `UserModel`, `EntryService`
- Widget classes should end with the type of widget: `ProfilePage`, `EntryCard`

#### Variables and Functions

- Use `camelCase` for variables and functions: `userName`, `fetchEntries()`
- Private variables and functions should start with underscore: `_userState`, `_handleSubmit()`

### Code Organization

#### File Structure

1. Imports (organized by type)
   - Dart/Flutter packages
   - External packages
   - Local imports
2. Class/widget declaration
3. Constants and static fields
4. Instance variables
5. Constructors
6. Override methods (e.g., `initState`, `dispose`, `build`)
7. Public methods
8. Private methods
9. Static methods

#### Widget Structure

For Flutter widgets:

1. Static properties and constants
2. Instance variables
3. Constructor
4. BuildContext-dependent getters
5. `initState`, `dispose` and other lifecycle methods
6. Build methods (starting with `build`)
7. Event handlers
8. Helper methods

### Formatting

- Maximum line length: 80 characters
- Use 2 spaces for indentation
- Add trailing commas for multiline lists/maps
- Wrap widget parameters for better readability when nesting

```dart
// Good
ElevatedButton(
  onPressed: _handleSubmit,
  child: Text('Submit'),
)

// Avoid
ElevatedButton(onPressed: _handleSubmit, child: Text('Submit'))
```

### Comments

- Use `///` for documentation comments
- Use `//` for implementation comments
- Comment complex algorithms and business logic
- Don't comment obvious code

### State Management

- Use Provider pattern consistently
- Keep UI and business logic separate
- Minimize widget state, prefer state in providers
- Use `const` constructors for stateless widgets

### Error Handling

- Handle all errors appropriately
- Use try/catch blocks for expected exceptions
- Provide meaningful error messages
- Log errors for debugging

## Code Quality

- Run `flutter analyze` before committing
- Fix all linter warnings
- Use `flutter format` to format code
- Write tests for business logic

## Example

```dart
/// A service for managing user data.
class UserService {
  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  /// Returns the currently logged in user.
  User? get currentUser => _auth.currentUser;
  
  /// Signs in a user with email and password.
  /// 
  /// Returns the User if successful, throws an exception otherwise.
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      // Log error and rethrow
      print('Login error: $e');
      rethrow;
    }
  }
}
``` 