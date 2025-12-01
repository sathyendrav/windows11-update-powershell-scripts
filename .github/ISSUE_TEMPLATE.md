# Issue Template

Thank you for taking the time to report an issue or suggest an enhancement! Please choose the appropriate template below and fill in the required information.

---

## 🐛 Bug Report

**Description**
A clear and concise description of the bug.

**To Reproduce**
Steps to reproduce the behavior:
1. Run script '...'
2. With parameters '...'
3. Execute command '...'
4. See error

**Expected Behavior**
A clear and concise description of what you expected to happen.

**Screenshots/Logs**
If applicable, add screenshots or paste log excerpts to help explain your problem.

```
[Paste log output here]
```

**Environment**
- **OS**: [e.g., Windows 11 22H2, Windows 10 21H2]
- **PowerShell Version**: [e.g., 7.4.0, 5.1.19041.4522]
- **Script Version**: [e.g., 1.0.0]
- **Winget Version**: [e.g., 1.6.3482] (Run `winget --version`)
- **Chocolatey Version**: [e.g., 2.0.0] (Run `choco --version`)
- **Running as Administrator**: [Yes/No]

**Configuration**
Please provide relevant sections from your `config.json` (remove any sensitive data):

```json
{
  "UpdateSettings": {
    ...
  }
}
```

**Additional Context**
Add any other context about the problem here.

---

## 💡 Feature Request / Enhancement

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Use Cases**
Describe specific scenarios where this feature would be helpful:
1. Scenario 1: ...
2. Scenario 2: ...

**Possible Implementation**
If you have ideas on how this could be implemented, please describe them here.

**Additional Context**
Add any other context, mockups, or examples about the feature request here.

---

## 📚 Documentation Issue

**Page/Section**
Which documentation page or section needs improvement?

**Issue Description**
What is unclear, incorrect, or missing?

**Suggested Improvement**
How should this be improved or corrected?

---

## ❓ Question / Help Request

**Question**
What would you like to know?

**What I've Tried**
Describe what you've already tried or researched:
- Checked README.md: [Yes/No]
- Checked FAQ.md: [Yes/No]
- Checked TROUBLESHOOTING.md: [Yes/No]
- Searched existing issues: [Yes/No]

**Context**
Any additional context that might help us answer your question.

---

## 📋 Checklist

Before submitting your issue, please ensure:

- [ ] I have searched existing issues to avoid duplicates
- [ ] I have read the [README.md](../README.md)
- [ ] I have read the [FAQ.md](../FAQ.md) (if applicable)
- [ ] I have read the [TROUBLESHOOTING.md](../TROUBLESHOOTING.md) (if applicable)
- [ ] I have reviewed the [Code of Conduct](../CODE_OF_CONDUCT.md)
- [ ] I have provided all requested information above
- [ ] I have removed any sensitive information from logs/config

---

## 🏷️ Issue Labels

Please apply appropriate labels to your issue (if you have permission):

### Type Labels
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `question` - Further information is requested
- `help wanted` - Extra attention is needed
- `good first issue` - Good for newcomers

### Priority Labels
- `priority: critical` - Critical issue requiring immediate attention
- `priority: high` - High priority issue
- `priority: medium` - Medium priority issue
- `priority: low` - Low priority issue

### Component Labels
- `component: install-updates` - Related to install-updates.ps1
- `component: update-checker` - Related to update-checker scripts
- `component: rollback` - Related to rollback-updates.ps1
- `component: validation` - Related to update/security validation
- `component: config` - Related to configuration
- `component: logging` - Related to logging functionality
- `component: notifications` - Related to toast/email notifications
- `component: winget` - Related to Winget package manager
- `component: chocolatey` - Related to Chocolatey package manager
- `component: store` - Related to Microsoft Store updates

### Status Labels
- `status: investigating` - Issue is being investigated
- `status: confirmed` - Issue has been confirmed
- `status: in progress` - Work is in progress
- `status: blocked` - Issue is blocked by another issue
- `status: needs info` - More information needed from reporter
- `status: duplicate` - This issue already exists
- `status: wontfix` - This will not be worked on

---

## 📝 Additional Guidelines

### For Bug Reports
- Provide as much detail as possible
- Include exact error messages
- Attach relevant log files from `.\logs\` directory
- Test with default configuration if possible
- Try to reproduce on a clean environment

### For Feature Requests
- Explain the "why" not just the "what"
- Consider backward compatibility
- Think about configuration options
- Provide real-world use cases

### For Questions
- Be specific about what you're trying to accomplish
- Include relevant code snippets or commands
- Mention what you've already tried

---

## 🤝 Contributing

Interested in contributing a fix or implementation? Check out our [Contributing Guidelines](../CONTRIBUTING.md) to get started!

---

**Thank you for contributing to Windows Update Helper Scripts!** 🚀
