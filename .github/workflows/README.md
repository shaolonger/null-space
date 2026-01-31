# CI/CD Pipeline Documentation

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipelines implemented for the Null Space project.

## Overview

The CI/CD pipeline consists of four main workflows:

1. **CI Workflow** - Continuous Integration for code quality and testing
2. **Release Workflow** - Automated release builds for multiple platforms
3. **Security Scan** - Dependency vulnerability scanning
4. **Code Coverage** - Test coverage reporting

## Workflows

### 1. CI Workflow (`ci.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**

#### Rust CI
- Checks out code
- Sets up Rust toolchain (stable)
- Caches Cargo dependencies for faster builds
- Runs `cargo fmt --check` for code formatting
- Runs `cargo clippy` for linting with warnings as errors
- Runs `cargo test` for unit tests
- Builds release binary

#### Flutter CI
- Checks out code
- Sets up Flutter SDK (3.16.0 stable)
- Gets dependencies with `flutter pub get`
- Runs `flutter analyze` for static analysis
- Runs `flutter test` for unit and widget tests
- Builds debug APK for Android

**Status:** Runs on every push and pull request to ensure code quality.

### 2. Release Workflow (`release.yml`)

**Triggers:**
- Push of tags matching `v*` pattern (e.g., `v1.0.0`, `v0.2.1`)

**Jobs:**

#### Create Release
- Creates a GitHub release for the tag

#### Build Rust Library
- Builds Rust core library for:
  - Linux (`.so`)
  - Windows (`.dll`)
  - macOS (`.dylib`)
- Uploads compiled libraries as release assets

#### Build Flutter Android
- Builds release APK for Android
- Uploads APK as release asset

#### Build Flutter Windows
- Builds Windows desktop application
- Creates ZIP archive
- Uploads as release asset

#### Build Flutter macOS
- Builds macOS desktop application
- Creates ZIP archive
- Uploads as release asset

**Usage:**
```bash
# Create and push a tag to trigger release
git tag v1.0.0
git push origin v1.0.0
```

### 3. Security Scan Workflow (`security.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches
- Weekly schedule (Monday at 00:00 UTC)

**Jobs:**

#### Rust Security Audit
- Runs `cargo audit` to check for known vulnerabilities in Rust dependencies
- Fails if critical vulnerabilities are found

#### Dependency Review
- Reviews dependency changes in pull requests
- Identifies security vulnerabilities and licensing issues
- Only runs on pull requests

**Status:** Automated security checks to prevent vulnerable dependencies.

### 4. Code Coverage Workflow (`coverage.yml`)

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs:**

#### Rust Coverage
- Uses `cargo-tarpaulin` to generate code coverage
- Uploads coverage report to Codecov

#### Flutter Coverage
- Runs `flutter test --coverage`
- Uploads coverage report to Codecov

**Status:** Tracks test coverage over time to ensure adequate testing.

## Caching Strategy

The CI workflows use GitHub Actions caching to speed up builds:

### Rust Caching
- Cargo registry (`~/.cargo/registry`)
- Cargo index (`~/.cargo/git`)
- Build artifacts (`target/`)

### Flutter Caching
- Flutter SDK (via `subosito/flutter-action` built-in caching)
- Pub cache (automatic)

## Workflow Status Badges

Add these badges to your README to show workflow status:

```markdown
![CI](https://github.com/shaolonger/null-space/workflows/CI/badge.svg)
![Security Scan](https://github.com/shaolonger/null-space/workflows/Security%20Scan/badge.svg)
![Code Coverage](https://github.com/shaolonger/null-space/workflows/Code%20Coverage/badge.svg)
```

## Local Development

### Running Checks Locally

Before pushing, you can run the same checks locally:

#### Rust
```bash
cd core/null-space-core

# Format check
cargo fmt --all -- --check

# Linting
cargo clippy --all-targets --all-features -- -D warnings

# Tests
cargo test --all-features

# Build
cargo build --release --all-features
```

#### Flutter
```bash
cd ui/null_space_app

# Get dependencies
flutter pub get

# Analysis
flutter analyze

# Tests
flutter test

# Build (example for Android)
flutter build apk --debug
```

## Troubleshooting

### CI Failures

#### Rust Formatting Issues
If `cargo fmt` fails, run locally and commit:
```bash
cargo fmt --all
```

#### Clippy Warnings
Fix all clippy warnings before pushing:
```bash
cargo clippy --all-targets --all-features -- -D warnings
```

#### Flutter Analysis Issues
Run flutter analyze and fix issues:
```bash
flutter analyze
```

### Release Build Failures

#### Missing Tag
Ensure you've created and pushed a valid tag:
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

#### Build Errors
Check the specific platform build logs in GitHub Actions for details.

## Security Best Practices

1. **Dependency Updates**: Review and update dependencies regularly
2. **Security Audits**: Address issues reported by `cargo audit`
3. **Code Review**: All PRs require review before merging
4. **Secret Management**: Never commit secrets or API keys
5. **Minimal Permissions**: Workflows use minimal required permissions

## Future Enhancements

Potential improvements to the CI/CD pipeline:

1. **Integration Tests**: Add end-to-end testing
2. **Performance Benchmarks**: Track performance metrics over time
3. **iOS Builds**: Add iOS release builds (requires macOS runner with signing)
4. **Docker Images**: Containerize builds for consistency
5. **Deploy to App Stores**: Automate deployment to Google Play and App Store
6. **Notification System**: Send build status notifications
7. **Artifact Retention**: Configure artifact retention policies
8. **Matrix Testing**: Test against multiple Rust/Flutter versions

## Maintenance

### Updating Workflow Dependencies

Regularly update GitHub Actions versions:
```yaml
- uses: actions/checkout@v4  # Check for newer versions
- uses: actions-rs/toolchain@v1
- uses: subosito/flutter-action@v2
```

### Monitoring

Monitor workflow runs in the "Actions" tab of the GitHub repository:
- Check for recurring failures
- Review security scan results
- Monitor build times and consider optimization

## Contributing

When modifying workflows:

1. Test changes in a fork or feature branch first
2. Review GitHub Actions documentation
3. Validate YAML syntax with `yamllint`
4. Document any new workflow features
5. Update this README with changes

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Rust CI Best Practices](https://doc.rust-lang.org/cargo/guide/continuous-integration.html)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [cargo-audit](https://github.com/RustSec/rustsec/tree/main/cargo-audit)
- [cargo-tarpaulin](https://github.com/xd009642/tarpaulin)
