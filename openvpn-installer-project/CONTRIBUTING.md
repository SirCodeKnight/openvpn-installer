# Contributing to OpenVPN Installer

First off, thank you for considering contributing to OpenVPN Installer! It's people like you that make this project such a great tool.

## Code of Conduct

This project and everyone participating in it is governed by the [OpenVPN Installer Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [GitHub Issues](https://github.com/SirCodeKnight/openvpn-installer/issues).

## How Can I Contribute?

### Reporting Bugs

This section guides you through submitting a bug report. Following these guidelines helps maintainers and the community understand your report, reproduce the behavior, and find related reports.

**Before Submitting A Bug Report:**

* Check the [FAQs on the wiki](https://github.com/SirCodeKnight/openvpn-installer/wiki) for a list of common questions and problems.
* Determine which repository the problem should be reported in.
* Check if the issue has already been reported. If it has and the issue is still open, add a comment to the existing issue instead of opening a new one.

**How Do I Submit A Good Bug Report?**

Bugs are tracked as [GitHub issues](https://github.com/SirCodeKnight/openvpn-installer/issues). Create an issue and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the problem.
* **Describe the exact steps which reproduce the problem** in as many details as possible.
* **Provide specific examples to demonstrate the steps**. Include links to files or GitHub projects, or copy/pasteable snippets, which you use in those examples.
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior.
* **Explain which behavior you expected to see instead and why.**
* **Include screenshots and animated GIFs** which show you following the described steps and clearly demonstrate the problem.
* **If the problem wasn't triggered by a specific action**, describe what you were doing before the problem happened and share more information using the guidelines below.

### Suggesting Enhancements

This section guides you through submitting an enhancement suggestion, including completely new features and minor improvements to existing functionality.

**Before Submitting An Enhancement Suggestion:**

* Check if the enhancement has already been suggested. If it has, add a comment to the existing issue instead of opening a new one.
* Determine which repository the enhancement should be suggested in.

**How Do I Submit A Good Enhancement Suggestion?**

Enhancement suggestions are tracked as [GitHub issues](https://github.com/SirCodeKnight/openvpn-installer/issues). Create an issue and provide the following information:

* **Use a clear and descriptive title** for the issue to identify the suggestion.
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible.
* **Provide specific examples to demonstrate the steps**. Include copy/pasteable snippets which you use in those examples.
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why.
* **Explain why this enhancement would be useful** to most users.
* **List some other projects where this enhancement exists.**

### Pull Requests

The process described here has several goals:

- Maintain code quality
- Fix problems that are important to users
- Engage the community in working toward the best possible OpenVPN installer
- Enable a sustainable system for maintainers to review contributions

Please follow these steps to have your contribution considered by the maintainers:

1. Follow all instructions in [the template](PULL_REQUEST_TEMPLATE.md)
2. Follow the [styleguides](#styleguides)
3. After you submit your pull request, verify that all [status checks](https://help.github.com/articles/about-status-checks/) are passing

While the prerequisites above must be satisfied prior to having your pull request reviewed, the reviewer(s) may ask you to complete additional tests or changes before your pull request can be ultimately accepted.

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
    * 🎨 `:art:` when improving the format/structure of the code
    * ⚡️ `:zap:` when improving performance
    * 🔒 `:lock:` when dealing with security
    * 📝 `:memo:` when writing docs
    * 🐛 `:bug:` when fixing a bug
    * 🔥 `:fire:` when removing code or files
    * 💚 `:green_heart:` when fixing CI build
    * ✅ `:white_check_mark:` when adding tests
    * 🚀 `:rocket:` when deploying new features

### Shell Script Styleguide

* Use bash for all shell scripts
* Use spaces, not tabs
* Use 4 spaces for indentation
* Use `#!/bin/bash` shebang
* Use double quotes for strings with variables
* Use single quotes for strings without variables
* Use lowercase for variable names
* Use uppercase for constants and environment variables
* Add comments for complex code sections
* Add a newline at the end of the file
* Limit lines to 80 characters when possible

## Additional Notes

### Issue and Pull Request Labels

This section lists the labels we use to help us track and manage issues and pull requests.

* `bug` - Issues that are bugs
* `documentation` - Issues or PRs related to documentation
* `duplicate` - Issues or PRs that are duplicates
* `enhancement` - Issues that are feature requests
* `good first issue` - Good for newcomers
* `help wanted` - Extra attention is needed
* `invalid` - Issues that are not valid
* `question` - Issues that are questions
* `wontfix` - Issues that will not be fixed

Thank you for contributing to OpenVPN Installer!