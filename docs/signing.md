# Signing

Some of the create/update/delete active calls done by the user/application need to be signed by the client. User can use various authorization methods, to confirm his/hers intention to execute active operation and authorize it. Those entities that can be signed implement `Signable` protocol.

You can find possible signing authorization methods in the following list:

* __NO AUTHORIZATION__ - validation of user intent without additional security measure. This form of signing is usually done by clicking some button in the UI.
* __TAC__ - validation of user intent to execute order by one time password sent to user personal device via SMS
* __MOBILE CASE (NOT IMPLEMENTED YET)__ - validation of the user response using mobile application, this method have two forms (user can choose which he'll use)
    * __ONLINE__ - mobile application receives PUSH notification with relevant data for authorization and user just clicks confirmation button in mobile application (data are sent over internet to bank)
    * __QR__ - mobile application retrieves relevant data for authorization by reading QR code displayed in frontend application, generates onetime password and user enters this OTP into frontend application to authorize operation

The signing is done in the following steps:

##1. Create signable order

You can sign any call that returns signable response. Responses that are signable implement [`Signable`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/Signable.swift) protocol. Response that is signable has `signing` key that contains [`SigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningObject.swift). [`SigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningObject.swift) contains public `state` which shows the current state of the signing and `signId` which is an unique identifier of the signing process for that particular order. You can use function `isOpen()` to see if the object is ready to be signed.

```swift

    // Call API endpoint that returns Signable response
    client.posts.create(postRequest) { (result) in
            let post = result.getObject()
            //This object contains signing info
            let signingInfo = post?.signing!
            if signingInfo.isOpen(){
               //This object can be signed
            }
        }
    }

```

##2. Get info
Before you can sign the order, you need to find out which authorization methods you can use to sign the object.

You have to call method `getInfo()` to get the necesarry information for the sgining on the [`SigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningObject.swif). This method returns [`FilledSigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/FilledSigningObject.swift) in callback.

```swift

    // Call getInfo method on SigningObject
    signingInfo.getInfo { (result) in
      if let filledSigningObject = result.getObject(){
        //Get possible signing auth typesfi
        let possibleAuthTypes = filledSigningObject.getPossibleAuthorizationTypes()
      }
    }

```

##3. Start signing

[`FilledSigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/FilledSigningObject.swift) extends [`SigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningObject.swift) so you get all of the methods and properties like `isOpen()` from it. In addition [`FilledSigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/FilledSigningObject.swift) has `authorizationType` and `scenarios` properties.

Convenience methods are also available. For example `canBeSignedWith(authType)` which takes `authorizationType` and returns `true` or `false` based on whether or not passed `authorizationType` is available, `getPossibleAuthorizationTypes` method that returns all possible `authorizationTypes`.

The most important methods are `startSigningWithTac`, `startSigningWithCaseMobile` and `startSigningWithNoAuthorization` that return [`TacSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift), [`CaseMobileSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift) or [`NoAuthSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift) in callback.

Call one of these methods to start signing.

```swift

    // Start signing with tac
    filledSigningObject
        .startSigningWithTac { (result) in
          if let tacSigningProcess = result.getObject(){
            //Continue signing here
          }
        }


```

##4. Finish signing

[`TacSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift), [`CaseMobileSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift) and [`NoAuthSigningProcess`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningProcess.swift) have two methods. First one is `cancel` that cancels the signing process and `finishSigning` which finishes the signing.

`TacSigningProcess'` `finishSigning` takes `oneTimePassword` as a parameter for authorization. All of the methods return updated [`SigningObject`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/SigningObject.swif).

```swift

    // Finish signing with 1234 as password
    tacSigningProcess
        .finishSigning('1234'){(result in)
          let signingObject = response.getObject();
        }
```

If the call was successful then the `state` value should be either `DONE` or `OPEN`.

`OPEN` means that you need to sign the order by additional method. Call `.getInfo()` on the signing object to continue signing. `DONE` state indicates that the order was fully signed and no further signing is needed.

```swift
    if signingObject.isDone(){
      print("Signing is complete")
    }else if(signingObject.isOpen(){
      signingObject.getInfo {(result) in
        //Continue signing
      }
    }
```

## Example
[You can see example of signing process in the signing tests.](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDKTests/SigningTests.swift)

#Implementing signing on WebApi entities

To enable signing on new WebApi entities, implement [`Signable`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/Signable.swift) protocol on them.

If the `Signable` protocol is implemented on [`WebApiEntity`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/WebApiEntity.swift) and API is called through [`ResourceUtils`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/ResourceUtils.swift) the `SigningObject` is automatically injected in the returned object to the developer.

Methods in [`UrlUtils`](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDK/UrlUtils.swift) can be used to create `signUrl` from relative Urls.

You can see [examples of Signable implementation in the tests](https://github.com/Ceskasporitelna/cs-core-sdk-ios/blob/master/CoreSDKTests/Posts.swift#L89)

