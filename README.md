# CSCoreSDK

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# Features

- [x] **[Locker](./docs/locker.md)** - Secure authentication using CSAS oAuth servers
- [x] **[WebApi Framework](./docs/webapi-howto.md)** - Greatly simplifies the task of writing SDKs that communicate with WebApi.
- [x] **[Signing](./docs/signing.md)** - Implements signing of orders returned from WebApi. This mechanism is currently used by NetBanking SDK.

# [CHANGELOG](CHANGELOG.md)

# Requirements

- iOS 8.1+
- Xcode 8.3+

# CoreSDK Instalation

You would normally use CoreSDK through other CSAS SDKs. If you want to use Locker without the UI or develop your app against the bare bones, you can install CoreSDK directly.


## Install through Carthage

If you use [Carthage](https://github.com/Carthage/Carthage) you can add a dependency on CoreSDK by adding it to your Cartfile:

```
github "Ceskasporitelna/cs-core-sdk-ios"
```

## Install through CocoaPods

You can install CoreSDK by adding the following line into your Podfile:

```ruby
#Add Ceska sporitelna pods specs respository
source 'https://github.com/Ceskasporitelna/cocoa-pods-specs.git'
source 'https://github.com/CocoaPods/Specs.git'

pod 'CSCoreSDK'
```

# Usage

After you've installed the SDK using Carthage or CocoaPods You can simply import the module wherever you wish to use it:

```swift
import CSCoreSDK
```

## Configuration

Before using CoreSDK in your application, you need to initialize it by providing it your WebApiKey.

```swift
CoreSDK.sharedInstance.useWebApiKey( "YourApiKey" )
```

**See [configuration guide](docs/configuration.md)** for all the available configuration options.

## Locker

Locker simplifies authentication against CSAS servers. It allows developer to obtain access token for the user and store it in a secure manner.

Please see [locker guide](./docs/locker.md) to see how to configure & use locker.

# Contributing

Contributions are more than welcome!

Please read our [contribution guide](CONTRIBUTING.md) to learn how to contribute to this project.

# Terms and License

Please read our [terms & conditions in license](LICENSE.md)
