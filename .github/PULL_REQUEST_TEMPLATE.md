# Pull Request

## 📋 Description

<!-- Provide a brief description of your changes -->

### What does this PR do?

<!-- Explain what changes you've made and why -->

### Related Issues

<!-- Link to related issues using keywords: Fixes #123, Closes #456, Relates to #789 -->

Fixes #
Closes #
Relates to #

---

## 🔄 Type of Change

<!-- Mark the relevant option with an 'x' -->

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update (changes to documentation only)
- [ ] 🎨 Code style update (formatting, renaming, refactoring)
- [ ] ⚡ Performance improvement
- [ ] ✅ Test update (adding or updating tests)
- [ ] 🔧 Configuration change
- [ ] 🔒 Security fix

---

## 🧪 Testing

### Test Environment

- [ ] Tested on Windows 10
- [ ] Tested on Windows 11
- [ ] Tested with PowerShell 5.1
- [ ] Tested with PowerShell 7.x
- [ ] Tested with Winget
- [ ] Tested with Chocolatey
- [ ] Tested with Microsoft Store updates

### Test Scenarios

<!-- Describe the test scenarios you've covered -->

- [ ] Fresh installation
- [ ] Upgrade from previous version
- [ ] Default configuration
- [ ] Custom configuration
- [ ] Error handling scenarios
- [ ] Edge cases

### Test Results

<!-- Describe the results of your testing -->

```
[Paste test output or results here]
```

---

## 📸 Screenshots/Logs

<!-- If applicable, add screenshots or log excerpts to demonstrate your changes -->

### Before

<!-- Screenshots or output before your changes -->

```
[Paste before state here]
```

### After

<!-- Screenshots or output after your changes -->

```
[Paste after state here]
```

---

## ✅ Checklist

### Code Quality

- [ ] My code follows the project's [style guidelines](../CONTRIBUTING.md#coding-standards)
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] My changes generate no new warnings or errors
- [ ] I have used proper PowerShell verb-noun naming conventions
- [ ] I have included `[CmdletBinding()]` for new functions
- [ ] I have added parameter validation where appropriate

### Documentation

- [ ] I have updated the README.md (if applicable)
- [ ] I have updated the FAQ.md (if applicable)
- [ ] I have updated the TROUBLESHOOTING.md (if applicable)
- [ ] I have added/updated comment-based help (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`)
- [ ] I have updated the configuration example (config-example.json) if needed
- [ ] My changes are documented in comments where necessary

### Testing

- [ ] I have added tests that prove my fix is effective or that my feature works (if applicable)
- [ ] New and existing unit tests pass locally with my changes
- [ ] I have tested with both PowerShell 5.1 and PowerShell 7.x
- [ ] I have tested on both Windows 10 and Windows 11 (if possible)
- [ ] I have tested error handling and edge cases

### Configuration & Compatibility

- [ ] My changes are backward compatible with existing configurations
- [ ] I have added new configuration options to `config-example.json` (if applicable)
- [ ] I have tested with default configuration
- [ ] I have tested with custom configurations
- [ ] My changes work with all supported package managers (Winget, Chocolatey, Store)

### Security

- [ ] My changes do not introduce security vulnerabilities
- [ ] I have not hardcoded any credentials or sensitive information
- [ ] I have properly validated all user inputs
- [ ] I have followed secure coding practices
- [ ] I have considered potential security implications

### Commits

- [ ] My commits follow the [Conventional Commits](https://www.conventionalcommits.org/) specification
- [ ] Each commit has a clear and descriptive message
- [ ] I have squashed unnecessary commits
- [ ] My branch is up to date with the main branch

---

## 🔍 Code Review Focus Areas

<!-- Highlight specific areas where you'd like reviewers to focus -->

- [ ] Algorithm/logic correctness
- [ ] Error handling
- [ ] Performance impact
- [ ] Security considerations
- [ ] Documentation clarity
- [ ] Test coverage
- [ ] Backward compatibility

**Specific areas for review:**

<!-- Add any specific areas you'd like reviewers to pay attention to -->

---

## 📊 Impact Assessment

### Files Changed

<!-- List the main files that were modified -->

- `script-name.ps1` - Description of changes
- `config-example.json` - Description of changes
- `README.md` - Description of changes

### Breaking Changes

<!-- If this PR introduces breaking changes, describe them here -->

**Is this a breaking change?** No / Yes

<!-- If yes, explain what breaks and how users should update -->

### Performance Impact

<!-- Describe any performance implications -->

- [ ] No performance impact
- [ ] Improves performance
- [ ] May impact performance (explain below)

**Performance notes:**

<!-- Add performance testing results or considerations -->

### Dependency Changes

<!-- List any new dependencies or version updates -->

- [ ] No new dependencies
- [ ] Added new dependencies (list below)
- [ ] Updated existing dependencies (list below)

**Dependency changes:**

<!-- List dependency changes here -->

---

## 🚀 Deployment Notes

<!-- Any special instructions for deployment or usage after merge -->

### Migration Steps

<!-- If users need to take action after this change, describe it here -->

1. Step 1
2. Step 2

### Configuration Updates Required

<!-- Does this require users to update their config.json? -->

- [ ] No configuration changes required
- [ ] Optional configuration changes
- [ ] Required configuration changes (describe below)

**Configuration changes:**

<!-- Describe configuration changes needed -->

---

## 📝 Additional Notes

<!-- Any additional information that reviewers should know -->

### Implementation Details

<!-- Explain key implementation decisions or trade-offs -->

### Known Limitations

<!-- List any known limitations of this PR -->

### Future Improvements

<!-- Suggest follow-up work or future enhancements -->

---

## 👥 Reviewers

<!-- Tag specific reviewers if needed -->

@sathyendrav

### Review Checklist for Maintainers

- [ ] Code quality meets project standards
- [ ] Tests are adequate and passing
- [ ] Documentation is complete and accurate
- [ ] No security concerns identified
- [ ] Backward compatibility verified
- [ ] Performance impact acceptable
- [ ] Ready to merge

---

## 📚 References

<!-- Add links to relevant documentation, discussions, or external resources -->

- [Related Documentation](link)
- [Discussion Thread](link)
- [External Reference](link)

---

## 🎉 Thank You!

Thank you for contributing to Windows Update Helper Scripts! Your effort helps make this project better for everyone.

Please be patient as maintainers review your PR. We'll provide feedback as soon as possible.

---

**By submitting this pull request, I confirm that my contribution is made under the terms of the Apache License 2.0.**
