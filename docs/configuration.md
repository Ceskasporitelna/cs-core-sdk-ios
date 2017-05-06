# Configuration

## Basic configuration

Before you use any of the CSAS SDKs in your application, you need to initialize it by providing your WebApiKey into the CoreSDK.

```swift
CoreSDK.sharedInstance.useWebApiKey( "YourApiKey" )
```

This Api key will be then used for all communications with CSAS WebApi.

Best place to configure the framework is in the **AppDelegate** in `application(application:, didFinishLaunchingWithOptions:)` method.

You can find example of full configuration below:

```swift
func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        CoreSDK.sharedInstance
            .useWebApiKey("YourApiKey")
            .useEnvironment(Environment.Sandbox)
            .useLanguage("en-US")
            .useRequestSigning("YourPrivateSigningKey")
            .useLocker(
                clientId: "YourClientID",
                clientSecret: "YourClientSecret",
                publicKey: "YourPublicKey",
                redirectUrlPath: "yourscheme://your-path",
                scope: "/v1/netbanking")

        return true
    }
```

## Set environment

Environment can be set by `useEnvironment()` method. You can use one of the predefined environments or define your own. SDK ships with two predefined environments:

- `Environment.Sandbox` - Sandbox environment that is intended to be used in the development and testing phase.
- `Environment.Production` - Production environment that is intended to be used in the Production builds. **This environment is a gateway to real banking data, so be carefull!**

You can also specify your own environment. You can do so by creating the Environment object yourslef:

```swift
let customEnvironment = Environment(
                        apiContextBaseUrl: "https://www.example.com/webapi",
                        oAuth2ContextBaseUrl:"https://www.example.com/widp/oauth2"))
```

## Set language

Language of communication can be set by the `.useLanguage()` method. Passed language will be sent in the `Accept-Language` header with each request to the WebApi. Default setting is `cs-CZ`

## Turn on Request signing

If you have request signing enabled for your WebApiKey, you can pass your private signing key into `.useRequestSigning()` method. SDK will then sign your requests for every API that supports request signing.

## Turn on Locker

Please see [locker guide](locker.md) on how to configure & use locker.
