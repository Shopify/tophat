# TophatKit
A Swift SDK for building extensions for [Tophat](https://github.com/Shopify/tophat).

> :memo: TophatKit will eventually be available as a standalone package, but is temporarily hosted directly inside the Tophat repo. If you want to start building your own extensions right away, clone the `tophat` repo and reference the `TophatSDK` directory as a local Swift package.

## Overview

TophatKit makes it easy to quickly build custom integrations for Tophat. Currently, TophatKit lets you build your own _artifact providers_ so that you can use Swift to integrate Tophat with your CI or storage solution to retrieve artifacts.

A Tophat extension is a Generic Extension target in Xcode and is hosted in a standalone application, similar to Safari extensions. Some of Tophatʼs [core features](../TophatExtensions/TophatCoreExtension) are defined in extensions as well.

## Getting Started

This guide assumes that you are familiar with Xcode and basic macOS application structure.

Decide whether you want to host your extension directly in Tophat so that all Tophat users can have access, or whether you need a private extension that is exclusive to your organizationʼs systems. If you want to host in Tophat, open the Tophat Xcode project. If you want to create a private extension, create a new Xcode project and create a macOS application.

1. Go to File → New → Target.
2. Select **Generic Extension**.
3. Choose a product name, and ensure that “Supports User Interface” is selected, even if you do not plan to support a settings interface.
4. Once the target is created, add the TophatSDK Swift package to your project and ensure that it is linked to your new Generic Extension target.
5. Open the `Info.plist` file for your extension and ensure that the `EXExtensionPointIdentifier` is set to `com.shopify.Tophat.extension`.

### Basic Extension Structure

Start by opening the `MyExtension.swift` file at the root of your extension target (the name will match the name of the product you chose) and replace the contents of the file with the following:

```swift
// MyExtension.swift

import TophatKit

@main
struct MyExtension: TophatExtension {
  static let title: LocalizedStringResource = "My Extension"
}
```

This is the default structure for an extension. The extension may then conform to one or more additional protocols to support additional functionality, such as `ArtifactProviding` and `SettingsProviding`.

### Adding an Artifact Provider

To add an artifact provider, start by creating a new Swift file to host the artifact provider in. Weʼll use Google Cloud Storage as an example:

```swift
// GoogleCloudStorageArtifactProvider.swift

import TophatKit

struct GoogleCloudStorageArtifactProvider: ArtifactProvider {
  static let id = "gcs"
  static let title: LocalizedStringResource = "Google Cloud Storage"

  @Parameter(key: "bucket", title: "Bucket")
  var bucket: String

  @Parameter(key: "object", title: "Object")
  var object: String

  func retrieve() async throws -> some ArtifactProviderResult {
    let downloadedFileURL = // Your logic for downloading the build.

    return .result(localURL: downloadedFileURL)
  }

  func cleanUp(localURL: URL) async throws {
    // Perform clean up.
  }
}
```

Youʼll notice a few things here:
- The `id` is used to identify the artifact provider when using Tophat URLs or `tophatctl`.
- The `title` is what is displayed in various parts of the Tophat user interface.
- There are two `Parameter` values. An artifact provider receives zero or more parameters as inputs when it is called. Use the `@Parameter` property wrapper to define parameters for your artifact provider.
- The `retrieve()` function is the implementation of the artifact provider. Use the parameters to make the necessary requests to retrieve the artifact.
- The `cleanUp(localURL:)` function defines what needs to be done to delete the downloaded artifact produced by `retrieve()`. You must implement this function.

Now that the artifact provider is created, register it in `MyExtension.swift`:

```swift
// MyExtension.swift

import TophatKit

@main
struct MyExtension: TophatExtension, ArtifactProviding {
  static let title: LocalizedStringResource = "My Extension"

  static var artifactProviders: some ArtifactProviders {
    GoogleCloudStorageArtifactProvider()
  }
}
```

Build and run and you should now have a functioning extension and artifact provider!

### Making the Extension Configurable

If the user needs to be able to configure the extension (e.g. to provide an API key), conform `MyExtension` to `SettingsProviding`:

```swift
// GoogleCloudExtension.swift

import SwiftUI
import TophatKit

@main
struct MyExtension: TophatExtension, ArtifactProviding, SettingsProviding {
  // ...

  static var settings: some View {
    Text("Settings")
  }
}
```

The `settings` property accepts a full SwiftUI view. The user can access the settings view by going to Tophat → Settings → Extensions, and clicking the info icon next to the extension.

## Contributing

See the [contribution guidelines](../CONTRIBUTING.md) for more information.
