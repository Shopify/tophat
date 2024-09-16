# Contributing

We welcome any meaningful contributions to Tophat. This includes bug fixes, performance improvements, and new features that would be beneficial to _all_ Tophat users.

## Code of Conduct

We expect all participants to read our [code of conduct](CODE_OF_CONDUCT.md) to understand which actions are and aren’t tolerated.

## Contributor License Agreement (CLA)

Each contributor is required to [sign a CLA](https://cla.shopify.com/). This process is automated as part of your first pull request and is only required once. If any contributor has not signed the CLA or does not have an associated GitHub account, the CLA check will fail and the pull request cannot be merged.

## Overview

Tophat is a macOS app build with Swift and SwiftUI.

Tophat is a _modular codebase_ and leverages Swift Packages to compartmentalize code. Where applicable, favour extensibility—code should be loosely coupled to make extending or removing Tophat functionality as easy as possible. When adding new functionality, consider what abstractions would help with identifying the boundary of the new feature.

### Code Style

- Use tabs for indentation.
- Try to keep line lengths short and easy to digest.
- When in doubt, try to match the style of other code in the project.

### User Experience

Tophat is designed to offer a seamless experience, especially for those familiar with developer tooling on macOS.

- Look and feel should match the system menu bar experience as closely as possible.
- The interface should be performant.

## Reporting Issues

- Bug reports are accepted and will be addressed directly if the issue also affects internal teams.
- Feature requests will **not** be accepted unless the feature is developed by the community. However, community-developed features are subject to discussion and review.

Please open an [issue](https://github.com/Shopify/tophat/issues) and clearly describe what you are reporting. Check to make sure that there are no existing issues before opening a duplicate.

## Contributing Code

- Concrete code contributions that make meaningful additions, improvements, or bug fixes are accepted.
- Large scale changes that significantly alter Tophat beyond its current form will **not** be accepted (e.g. expansion to other operating systems).

Before opening a pull request, check if there are any open [issues](https://github.com/Shopify/tophat/issues) that are applicable to your changes. For larger changes, consider opening an issue for discussion first.

## Developing

To build Tophat, you will need at least Xcode 15.0 and macOS 14.0.

1. Fork the repo and create a new branch for your changes.
1. Ensure that you have [Mint](https://github.com/yonaskolb/Mint) installed, either directly or _via_ Homebrew:
   ```bash
   brew install mint
   ```
1. Install Mint dependencies using:
   ```bash
   mint bootstrap
   ```
   This will allow you to run SwiftLint using `mint run swiftlint`.
1. Before you start a piece of work, ensure that you sync any submodules using:
   ```bash
   git submodule update --init --recursive
   ```
1. Make any changes to Tophat and create commits as needed.
1. Add tests, if needed.
1. Create a pull request and provide detailed context in the description.

### Creating a Release

To create a release build of Tophat, use the following steps:

1. Create an archive using Product → Archive.
1. Select the archive that was created, click Distribute App, then Copy App.