# Contributing to Windows Update Helper Scripts

First off, thank you for considering contributing to Windows Update Helper Scripts! It's people like you that make this project better for everyone.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
  - [Reporting Bugs](#reporting-bugs)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Contributing Code](#contributing-code)
  - [Improving Documentation](#improving-documentation)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to sathyendrav@gmail.com.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include as many details as possible:

#### How to Submit a Good Bug Report

1. **Use a clear and descriptive title** for the issue
2. **Describe the exact steps to reproduce the problem**
3. **Provide specific examples** to demonstrate the steps
4. **Describe the behavior you observed** after following the steps
5. **Explain which behavior you expected** to see instead and why
6. **Include screenshots or animated GIFs** if relevant
7. **Include your environment details**:
   - Windows version (e.g., Windows 11 22H2)
   - PowerShell version (`$PSVersionTable.PSVersion`)
   - Script version
   - Package manager versions (Winget, Chocolatey)

#### Bug Report Template

```markdown
**Description**
A clear and concise description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Run script '...'
2. With parameters '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Screenshots/Logs**
If applicable, add screenshots or log excerpts.

**Environment**
 - OS: [e.g., Windows 11 22H2]
 - PowerShell: [e.g., 7.4.0]
 - Script Version: [e.g., 1.0.0]
 - Winget Version: [e.g., 1.6.3482]
 - Chocolatey Version: [e.g., 2.0.0]

**Additional Context**
Any other context about the problem.

**Configuration**
Relevant sections from your config.json (remove sensitive data).
```

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear and descriptive title**
- **Detailed description** of the proposed feature
- **Use cases** explaining why this would be useful
- **Possible implementation** if you have ideas
- **Alternatives considered**

#### Enhancement Request Template

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
A clear description of what you want to happen.

**Describe alternatives you've considered**
Alternative solutions or features you've considered.

**Use Cases**
Specific scenarios where this feature would be helpful.

**Additional Context**
Any other context, mockups, or examples.
```

### Contributing Code

#### First Time Contributors

Look for issues labeled `good first issue` or `help wanted`. These are great starting points for new contributors.

#### Development Workflow

1. **Fork the repository**
2. **Clone your fork**
   ```powershell
   git clone https://github.com/YOUR-USERNAME/windows11-update-powershell-scripts.git
   cd windows11-update-powershell-scripts
   ```
3. **Create a feature branch**
   ```powershell
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes**
5. **Test thoroughly**
6. **Commit your changes**
7. **Push to your fork**
   ```powershell
   git push origin feature/your-feature-name
   ```
8. **Create a Pull Request**

### Improving Documentation

Documentation improvements are always welcome! This includes:

- Fixing typos or grammatical errors
- Improving clarity or adding examples
- Adding missing documentation
- Updating outdated information
- Translating documentation

## Development Setup

### Prerequisites

- Windows 10 (1809+) or Windows 11
- PowerShell 5.1 or PowerShell 7.x
- Git for Windows
- Visual Studio Code (recommended)
- Winget and/or Chocolatey (for testing)

### Recommended VS Code Extensions

- PowerShell Extension
- GitLens
- Markdown All in One
- EditorConfig for VS Code

### Setting Up Development Environment

1. **Clone the repository**
   ```powershell
   git clone https://github.com/sathyendrav/windows11-update-powershell-scripts.git
   cd windows11-update-powershell-scripts
   ```

2. **Set execution policy** (if needed)
   ```powershell
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Create a test configuration**
   ```powershell
   Copy-Item config-example.json config.json
   ```

4. **Run tests** (if available)
   ```powershell
   .\TestValidation.ps1
   ```

## Coding Standards

### PowerShell Style Guide

We follow the [PowerShell Practice and Style Guide](https://poshcode.org/PowerShell-Practice-and-Style/). Key points:

#### Naming Conventions

- **Functions**: Use approved PowerShell verbs (Get-, Set-, New-, etc.) and PascalCase
  ```powershell
  function Get-PackageVersion { }
  ```
- **Variables**: Use camelCase for local variables, PascalCase for script-level
  ```powershell
  $packageName = "example"
  $GlobalConfig = @{}
  ```
- **Parameters**: Use PascalCase
  ```powershell
  param(
      [string]$ConfigPath,
      [switch]$SkipValidation
  )
  ```

#### Code Structure

- Use `[CmdletBinding()]` for all functions
- Include parameter validation attributes
- Add comprehensive comment-based help
- Keep functions focused and single-purpose
- Use proper error handling with try/catch

#### Example Function

```powershell
<#
.SYNOPSIS
    Short description of what the function does.

.DESCRIPTION
    Longer description with more details.

.PARAMETER ParameterName
    Description of the parameter.

.EXAMPLE
    Example-Function -ParameterName "value"
    Description of what this example does.

.NOTES
    Author: Sathyendra Vemulapalli
    Version: 1.0.0
#>
function Verb-Noun {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Description")]
        [ValidateNotNullOrEmpty()]
        [string]$ParameterName
    )
    
    begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"
    }
    
    process {
        try {
            # Main logic here
        }
        catch {
            Write-Error "Error: $_"
            throw
        }
    }
    
    end {
        Write-Verbose "Completed $($MyInvocation.MyCommand)"
    }
}
```

#### Formatting

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Maximum 120 characters
- **Braces**: Opening brace on same line
  ```powershell
  if ($condition) {
      # code
  }
  ```
- **Spacing**: Space after commas, around operators
  ```powershell
  $array = @(1, 2, 3)
  $result = $value1 + $value2
  ```

#### Comments

- Use `#` for single-line comments
- Use `<# #>` for multi-line comments
- Include comment-based help for all functions
- Explain "why" not "what" in code comments
- Keep comments up-to-date with code changes

#### Error Handling

```powershell
try {
    # Code that might fail
}
catch [System.IO.IOException] {
    Write-Error "IO Error: $_"
}
catch {
    Write-Error "Unexpected error: $_"
    throw
}
finally {
    # Cleanup code
}
```

### Configuration File Guidelines

- Use JSON for configuration
- Include comments in example files
- Validate configuration on load
- Provide sensible defaults
- Document all settings in README

### Security Guidelines

- Never hardcode credentials
- Validate all user input
- Use secure credential storage
- Implement proper error handling
- Follow principle of least privilege
- Enable security features by default

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `security`: Security improvements

### Examples

```
feat(update-checker): add differential update support

Implemented caching system to track package versions and only report
packages with actual version changes. This reduces scan time and
provides more relevant update information.

Closes #123
```

```
fix(install-updates): resolve Unicode encoding issue

Replaced Unicode checkmark characters with ASCII [OK]/[FAIL] to
prevent encoding errors in some PowerShell environments.

Fixes #456
```

```
docs(readme): update parameter documentation

Added comprehensive parameter documentation for all 9 scripts including
examples, descriptions, and valid ranges.
```

## Pull Request Process

### Before Submitting

1. ✅ **Test your changes thoroughly**
2. ✅ **Update documentation** if needed
3. ✅ **Follow coding standards**
4. ✅ **Write descriptive commit messages**
5. ✅ **Ensure no merge conflicts**
6. ✅ **Run validation tests**

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Testing
- [ ] Tested on Windows 10
- [ ] Tested on Windows 11
- [ ] Tested with PowerShell 5.1
- [ ] Tested with PowerShell 7.x
- [ ] Tested with Winget
- [ ] Tested with Chocolatey

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed my own code
- [ ] Commented complex code sections
- [ ] Updated documentation
- [ ] No new warnings generated
- [ ] Added tests (if applicable)
- [ ] All tests passing

## Related Issues
Closes #(issue number)

## Screenshots (if applicable)
Add screenshots to demonstrate changes.
```

### Review Process

1. **Automated checks** will run (if configured)
2. **Maintainers will review** your code
3. **Address feedback** by making additional commits
4. **Approval required** before merging
5. **Squash and merge** is the preferred merge method

### After Your PR is Merged

- Delete your feature branch
- Update your fork's main branch
- Celebrate your contribution! 🎉

## Testing Guidelines

### Manual Testing

Before submitting, test your changes:

1. **Fresh install scenario**
   - Test on a clean Windows installation
   - Verify dependency installation works

2. **Upgrade scenario**
   - Test updating from previous version
   - Ensure configuration migration works

3. **Different environments**
   - Windows 10 and Windows 11
   - PowerShell 5.1 and 7.x
   - With and without package managers

4. **Error scenarios**
   - Network disconnection
   - Insufficient permissions
   - Invalid configuration
   - Package manager errors

### Test Cases to Cover

- ✅ Default configuration works
- ✅ Custom configuration is respected
- ✅ Error handling works correctly
- ✅ Logs are generated properly
- ✅ Reports are formatted correctly
- ✅ Rollback functionality works
- ✅ Validation features work
- ✅ Help documentation is accurate

### Creating Tests

If adding new features, consider adding test cases to `TestValidation.ps1`:

```powershell
Describe "New Feature Tests" {
    It "Should perform expected behavior" {
        # Test code
        $result = YourFunction -Parameter "value"
        $result | Should -Be "expected"
    }
}
```

## Community

### Getting Help

- 💬 **GitHub Discussions**: Ask questions and share ideas
- 🐛 **GitHub Issues**: Report bugs and request features
- 📧 **Email**: sathyendrav@gmail.com

### Staying Updated

- ⭐ **Star the repository** to stay notified
- 👀 **Watch releases** for new versions
- 📰 **Read release notes** for important changes

### Recognition

Contributors will be recognized in:
- README.md acknowledgments section
- Release notes
- Project documentation

## Additional Resources

### PowerShell Resources
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)
- [PowerShell Gallery](https://www.powershellgallery.com/)
- [PowerShell Practice and Style Guide](https://poshcode.org/PowerShell-Practice-and-Style/)

### Git Resources
- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Git Documentation](https://git-scm.com/doc)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Package Manager Resources
- [Winget Documentation](https://docs.microsoft.com/en-us/windows/package-manager/)
- [Chocolatey Documentation](https://docs.chocolatey.org/)

## Questions?

Don't hesitate to ask! Open an issue with the `question` label or reach out via email.

---

**Thank you for contributing to Windows Update Helper Scripts!** 🚀

Your contributions help make Windows update management easier for everyone.
