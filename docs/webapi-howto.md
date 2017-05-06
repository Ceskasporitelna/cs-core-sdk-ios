# Building a WebApi SDK based on CoreSDK

Building your own client that can talk to CSAS WebApi is easy thanks to basic building blocks that are included in the CoreSDK.

## Process

When you want to roll out your own implementation of CSAS WebApi client, you need to go through the following steps:

1. Subclass `WebApiClient`
2. Model the API in the language using the `Resource` and other primitives of **WebApi SDK**
3. Add transformations to your models to maintain consistency and ease of use
4. Write unit tests against [ReDredd](https://github.com/Ceskasporitelna/judge) (Judge).

## Primitives of WebApi SDK

You can use the following primitives to build a WebApi SDK:

- **WebApiClient** - This class serves as an entry point for the user of your sdk when he/she wants to interact with the WebApi. You start the SDK development by subclassing this class.
- **Resource** - Resource classes models the actions and resources that are available to SDK user on different endpoints of the WebApi. You model the endpoints and their supported HTTP actions using subclasses of `Resource` and `InstanceResource`
- **WebApiEntity** - Every response that comes from WebApi has this class as its base class. WebApiEntity allows you to easily map server response to Swift objects.
- **ApiQuery** - We provide you with sets of protocols that tells the user of the SDK what can be done with the given Resource or WebApiEntity subclass. These protocols in conjunction with the afromentioned classes make up a micro DSL of WebApi called _ApiQuery_. You have to implement these in your `Resources` and `WebApiEntities` in order to ensure behaviour consistency accross different endpoints and SDKs

## WebApiClient

This class serves as an entry point for the user of your sdk when he/she wants to interact with the WebApi. You start the SDK development by subclassing this class.

WebApiClients are initialized with `[WebApiConfiguration](../CoreSDK/WebApiConfiguration.swift)` which gives them the `apiContextBaseUrl` from the environment. Your task is to define `apiBasePath` which is the start of the WebApi context for that given API.

You start modelling the API by defining `Resource` getters on your WebApiClient subclass.

WebApiClient also contains a generic `.callApi` method that allows you to make nearly any request to WebApi without any API modelling. This method is used internally by the WebApi frameworks to make the calls on your behalf.

[View Example](../CoreSDKTests/TestApiClient.swift)

[View Code](../CoreSDK/WebApiClient.swift)

### Best Practices

- Each SDK SHOULD contain exactly one subclass of `WebApiClient`
- `WebApiClient` SHOULD contain root `Resources` that start from the web api context of the API being modelled.

## ApiQuery

In the heart of WebApi SDKs is the DSL language named **ApiQuery**, which allows to access to the resources in an uniform way. It does not matter whether you are building a NetBanking SDK or PointOfInterest SDK. Thanks to ApiQuery, the developer can access the CSAS WebApi through common and well defined interface.

**ApiQuery** allows developer to write queries like `apiClient.accounts.withId("account-number").get()`

or like

`apiClient.uniforms.list()`

ApiQuery maps directly to method verbs and concepts used in RESTfull HTTP context. Developer can therefore use [CSAS WebApi documentation](https://developers.csas.cz) as a source of documentation to the SDK itself.

### Verbs of API Query (the idea)

ApiQuery DSL consists of the following verbs. These verbs can be called upon the **Resource** and **WebApiEntity** primitives.

ApiQuery method  | HTTP                            | Returns
---------------- | ------------------------------- | --------------------
.get()           | GET Method on InstanceResource  | ResponseCallback
.list()          | GET Method on Resource          | ListResponseCallback
.create(request) | POST Method                     | ResponseCallback
.update(request) | PUT Method                      | ResponseCallback
.delete()        | DELETE Method                   | EmptyCallback
.withId(id)      | Appends `/{id}` to current path | InstanceResource

### Protocols of API Query (the implementation)

WebApi provides you with the following protocols to implement the ApiQuery DSL in your SDK:

- **GetEnabled** - Marks Resource or Entity that supports `.get` method.
- **ParametrizedGetEnabled** - Marks Resource or Entity that supports `.get` method which accepts query parameters.
- **HasInstanceResource** - Marks Resource or Entity that has InstanceResource and implements `.withId` method
- **UpdateEnabled** - Marks Resource or Entity that has `.update` method
- **EmptyUpdateEnabled** - Marks Resource or Entity that has `.update` method without any payload.
- **CreateEnabled** - Marks Resource or Entity that has `.create` method
- **EmptyCreateEnabled** - Marks Resource or Entity that has `.create` method without any payload.
- **DeleteEnabled** - Marks Resource or Entity that has `.delete` method
- **ParametrizedDeleteEnabled** - Marks Resource or Entity that has `.delete` method with query parameters.
- **ListEnabled** - Marks Resource or Entity that has `.list` method without pagination and parameters
- **ParametrizedListEnabled** - Marks Resource or Entity that has `.list` method without pagination but with parameters
- **PaginatedListEnabled** - Marks Resource or Entity that has `.list` method whith pagination parameters.

[View Code](../CoreSDK/ApiQuery.swift)

#### Best practices

- Parametrized methods that sends query parameters to server should name their parameter classes with suffix `Parameters`. Example: `get(parameters : UserGetParameters,callback : ...)`
- Classes representing the body payload sent so server should end with `Request` suffix. Example: `create(payload : CreateUserRequest,callback : ...)`
- Classes representing responses from the WebApi should be named simply by what they represent. Example: `User`, `BankingAccount` and so on.

## Resource

Resource represents collection of API query verbs on a given URL. For example, if you have endpoint `https://secure.banking.com/api/v1/users` you could represent it by `UsersResource`.

Each resource stores its `path` and the `WebApiClient` it belongs to.

You can nest resources by exposing them as a properties on their parent resource.

[View Example](../CoreSDKTests/Users.swift)

[View Code](../CoreSDK/Resource.swift)

### InstanceResource

InstanceResource is a Resource subclass that represents collections of API query verbs that are available on given entity.

For example if you have `https://secure.banking.com/api/v1/users/123`, you could represent it by `UserResource` that is a subclass of `Instance Resource`

InstanceResource stores it's entity `id` and usually implements `GetEnabled` protocol to get the actual `WebApiEntity`.

[View Example](../CoreSDKTests/Users.swift)

[View Code](../CoreSDK/InstanceResource.swift)

### Best practices

- Use subclasses of `InstanceResource` to model enpdpoints that return single entity
- Usually `Resource` returns a `InstanceResource` through `withId(id)` call. (example: instance of `UsersResource` returns a `UserResource` by invoking `client.users.withId(1)`)
- Resource SHOULD adhere to default ApiQuery verbs where possible. Aliases for defaultmethods COULD be added. Example `FilesResource` can have method `upload`, which is alias for the default ApiQuery method `Create`
- If there is an action on given server endpoint that does not correspond to ApiQuery methods, you may model it as custom method.

  Example: If the following endpoint exist `(POST) https://secure.banking.com/api/v1/users/123/send_notification`, You could model it as `sendNotification` method defined on `UserResource`

## WebApiEntity

WebApiEntity represents base subclass for all responses recieved from the server and also all body payloads sent to server.

WebApiEntity remembers it's `Resource` from which it was obtained which allows you to add convenience methods and implement ApiQuery verbs straight on the entity itself.

[View Example](../CoreSDKTests/Users.swift)

[View Code](../CoreSDK/WebApiEntity.swift)

### Best practices

- If the entity being modeled does not have an `id` property but has some different property which is its primary id (say `userId`), you should provide an alias getter (and eventually setter) called `id` so that the user of the SDK can access entity id in a consistent way.
- Consider adding convenience ApiQuery methods for easier querying after obtaining the entity.

  Example: You allow user to obtain list of `UserSummary` objects through `client.users.list()` call. And also to obtain more detailed `User` object through `client.users.withId(123).get()` call. You should consider implemeting `getEnabled` protocol on `UserSummary` so that user can call `userSumarryObject.get()` to get the more detailed `User` straight from the `UserSummary`.

- Focus your efforts on modelling the entity with the correct data types and correct nullability. It can save a user lot of work if you can ensure them, that some properties will always be there on the returned WebApiEntity.

## ResourceUtils

ResourceUtils are set of helpfull methods that makes implementing calls to WebApi easy. They are not considered WebApi primitives as users of the SDK won't come in contact with them directly, but you should utilize them to implement the SDK functionality as much as possible.

ResourceUtils ensure that:

- Default request/response transformations are performed to the request/response.
- You have an easy way how to define your own transformations.
- Set `Resource` and possible pathSuffix to recieved `WebApiEntity`.
- Ensure correct item mapping in List responses.
- Ensure proper functionality of Paginated lists.

[View Example](../CoreSDKTests/Users.swift)

[View Code](../CoreSDK/ResourceUtils.swift)

## Technologies inside WebApi framework

The WebApi Swift framework internally uses embedded [Alamofire](https://github.com/Alamofire/Alamofire) for making requests and [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper) for object mapping. If you know these two, you should find developing your SDK an easy task.

# Testing

TBD

# Example implementation

You can look at the example implementation of WebApi SDK for fictitious API that is tested against ReDredd (Judge). You can find it in CoreSDKTest/WebApi group in XCode project of CoreSDK.

[Example WebApiClient](../CoreSDKTests/TestApiClient.swift)

[Example Resources and WebApiEntities](../CoreSDKTests/users.swift)

[Example SDK usage](../CoreSDKTests/WebApiClientTests.swift)

[ReDredd fictitious API definition](https://github.com/Ceskasporitelna/judge/blob/master/cases/webapi.json)
