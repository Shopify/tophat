<h1 align="center">
  <img src="./media/icon.png" alt="Tophat" width="128">
  <br>
  Tophat 
  <br>
</h1>

<p align="center">
  As seen on the <a href="https://shopify.engineering/shopify-tophat-mobile-developer-testing">Shopify Engineering Blog</a>!
</p>

![Artwork](/media/banner.png)

<p align="center">
  <strong>Tophat is the best way to install and test any mobile application. Just add CI.</strong>
</p>

### One-Click Installation

With Tophat, you can skip building branches locally. Use Tophatʼs many features and APIs to easily create installation links to CI artifacts. Take your tooling a step further and offer contributors the ability to test pull requests without cloning anything!

### Extensions

With the [TophatKit](./TophatKit) SDK, you can easily extend Tophat to integrate with custom build and caching systems. This makes Tophat compatible with virtually any tooling setup you can imagine!

### Quick Launch

Quick Launch allows you to add your favourite apps right to the Tophat menu. Need the latest build? Click on the icon and go! Tophat will download the latest version, automatically update the icon, and launch it on your device.

<p align="center">
  <img src="./media/quick_launch.png" alt="Quick Launch" width="429">
</p>


### Device Pinning

Have lots of devices and only use a couple at a time? Easily pin them to the top of the devices list for quick access.

<p align="center">
  <img src="./media/device_pinning.png" alt="Device Pinning" width="588">
</p>

### Customize

Customize Tophat to your needs with the Settings window. Adjust preferences, add apps to Quick Launch, or even specify custom tooling paths to make Tophat work for your environment.

<p align="center">
  <img src="./media/settings.png" alt="Settings" width="713">
</p>

## Integrating Tophat

> :bulb: The following APIs have been introduced in Tophat 2. Legacy APIs have been removed.

Downloads with Tophat are powered by **_artifact providers_**. Some providers are built-in to Tophat, while some can be installed using Tophat Extensions (see [_Extensions_](#extensions)). When triggering an install with Tophat, you will need to specify the following information:

- The providerʼs ID.
- The providerʼs parameters.
- The platform (optional).
- The destination (optional).
- A list of launch arguments (optional).

The format by which this information is specified varies slightly depending on whether you use URLs, Quick Launch, or `tophatctl`, but each API requires roughly the same information.

You can view a list of all artifact provider IDs using `tophatctl list providers`.

Each request can install multiple artifacts. Within each request, these are called _recipes_, and are particularly useful when you want to have one link that supports both simulators and devices in the same link, where different builds are required for each.

### URLs

Tophat handles URLs using both the `tophat://` and `http://` schemes so that you can use them in any website or application. Where possible, prefer the `tophat://` scheme which does not navigate away from the current page.

The examples below will use `tophat://`, but `tophat://` is interchangeable with `http://localhost:29070/` for use with GitHub, for example.

> :memo: When creating an install link, prefer using “Install with Tophat” as the link text.

#### URL Format

Below is an example for a hypothetical artifact provider for Google Cloud Storage. In this case, `gcs` is the artifact provider ID:

```
tophat://install/gcs?bucket=<bucket>&object=<object>
```

The type of build downloaded will be interpreted by Tophat automatically, but the API provides a means to preheat the intended device ahead of time by specifying the platform and destination:

```
tophat://install/gcs?bucket=<bucket>&object=<object>&platform=ios&destination=device
```

If multiple artifacts are created for different destinations, parameters for both artifacts may be specified in the same URL by repeating query parameters. Tophat will then select the appropriate parameters for the selected device.

```
tophat://install/gcs?bucket=<bucket>&object=<object>&platform=ios&destination=device&bucket=<bucket>&object=<object>&platform=ios&destination=simulator
```

Launch arguments may be specified using the `arguments` query parameter:

```
tophat://install/gcs?bucket=<bucket>&object=<object>&arguments=one,two,three
```

On iOS, these arguments are retrievable using `ProcessInfo`. On Android, these arguments are delivered to your appʼs main activity _via_ intent argument extras in the `TOPHAT_ARGUMENTS` key as an array of strings.

## Using Tophat

### Core Providers

Some core providers are built-in to Tophat. These provide a balance between ease of use and flexibility.

#### Basic HTTP

```
tophat://install/http?url=<full_public_url>
```

#### Shell Script

A shell script allows you to have full control over how the artifact is downloaded. Shell scripts are placed in `~/Library/Application Scripts/com.shopify.Tophat.TophatCoreExtension/` and must have their executable flags set with `chmod +x <filename>`.

For example, a shell script with filename `filename` placed in the location described above can be invoked using:

```
tophat://install/shell?script=filename
```

The script is provided with two positional arguments:

- `$1` is a full path to a **staging** directory where you may temporarily store files during download and unzip.
- `$2` is a full path to the **output** directory where exactly one artifact must be located when the script finishes. Tophat will look in this directory to install the application.

### Command Line Helper

Tophat can be integrated with various tools and projects using `tophatctl`, Tophatʼs companion command line app. You can use `tophatctl` to perform the following tasks:

- **Manage Quick Launch apps.** Pre-populate Tophat with your projectʼs apps in a `dev up` step.
- **Install apps.** Install an app by URL or path.
- **List providers.** Display provider configuration to assist with integration.

For more details on how to use `tophatctl`, run the following command after installing the Command Line Helper:

```sh
tophatctl --help
```

### File Associations

Tophat also adds file associations to `*.ipa`, `*.apk`, and `*.zip` files so you can open artifacts from your device.

<p align="center">
  <img src="./media/open_with.png" alt="Open With" width="556">
</p>

## Getting Started

A signed universal binary of Tophat can be downloaded from the latest GitHub release. Click the button below to jump to it, download the `.zip` file, and move Tophat to your Applications folder:

[![Latest GitHub Release](https://img.shields.io/github/v/release/Shopify/tophat?color=black&label=download%20latest&logo=github&sort=semver&style=for-the-badge)](https://github.com/Shopify/tophat/releases/latest)

A full list of releases is available [here](https://github.com/Shopify/tophat/releases).

Tophat will automatically check for updates and let you know if a new one is available. Youʼll be prompted to enable automatic update checks the second time you launch Tophat. Automatic updates can also be configured from Tophatʼs Settings window.

Tophat requires a few developer tools to be set up. On first launch, Tophat will guide you through making sure everything you need is ready to go.

## Requirements

Tophat requires macOS 15 or later.

### iOS Development

- Xcode 15 or newer is required.
- All simulator versions are supported, but physical devices must be running iOS 17 or later.

### Android Development

Tophat works with Android Studio and Android toolchains with a working `adb` and `avdmanager` environment.

## Contributing

See the [contribution guidelines](CONTRIBUTING.md) for more information.
