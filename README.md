# Halley

[![Version](https://img.shields.io/cocoapods/v/Halley.svg?style=flat)](https://cocoapods.org/pods/Halley)
[![License](https://img.shields.io/cocoapods/l/Halley.svg?style=flat)](https://cocoapods.org/pods/Halley)
[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
![Platforms](https://img.shields.io/static/v1?label=platform&message=iOS%2013%20&color=brightgreen)

<p align="center">
    <img src="img/halley-logo.png" width="300" max-width="50%" alt="Halley"/>
</p>


## Description

Halley provides a simple way on iOS to parse and traverse models according to [JSON Hypertext Application Language specification](https://datatracker.ietf.org/doc/html/draft-kelly-json-hal) also known just as HAL.


## Table of contents

* [Requirements](#requirements)
* [Getting started](#getting-started)
* [Usage](#usage)
* [Contributing](#contributing)
* [License](#license)
* [Credits](#credits)


## Requirements

- iOS 13
- Swift 5.0


## Getting started

There are several ways to include _Halley_ in your project, depending on your use case.

### CocoaPods

Halley is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'Halley'
```

### Swift Package Manager

If you are using SPM for your dependency manager, add this to the dependencies in your `Package.swift` file:
```swift
dependencies: [
    .package(url: "https://github.com/infinum/Halley.git")
]
```


## Usage

### Model

A typical HAL model class prepared for _Halley_ consists of several parts.

```swift
struct Website: HalleyCodable {
    let _links: Links?

    let id: String
    let url: URL
}

struct Contact: HalleyCodable {
    let _links: Links?

    let id: String
    let name: String
    let contacts: [Contact]?
    let website: Website?

    enum CodingKeys: String, CodingKey, IncludeKey {
        case _links
        case id
        case name
        case contacts
        case website = "webSiteLink"
    }
}
```
Going from top to bottom, these classes/structs must obey the following list of rules:

* A class/struct **must** conform `HalleyCodable` protocol.
* A class/struct **must** define `_links` variable which is used while traversing the model's tree. 
* `CodingKeys` **should** conform `IncludeKey` protocol for type-safe traversing the tree.

### Traversal paths - Include list

```swift
extension Contact: IncludeableType {

    enum IncludeType {
        case full
        case contacts
        case website
        case contactsOfContacts
        case contactsAndWebsiteOfContacts
    }
}

extension Contact.IncludeType: IncludeTypeInterface {
    typealias IncludeCodingKey = Contact.CodingKeys

    @IncludesBuilder<IncludeCodingKey>
    public func prepareIncludes() -> [IncludeField] {
        switch self {
        case .full:
            ToMany(.contacts)
            ToOne(.website)
        case .contacts:
            ToMany(.contacts)
        case .website:
            ToOne(.website)
        case .contactsOfContacts:
            Nested(Contact.self, including: .contacts, at: .contacts, toMany: true)
        case .contactsAndWebsiteOfContacts:
            Nested(Contact.self, including: .full, at: .contacts, toMany: true)
            ToOne(.website)
        }
    }
}
```

To support type-safe traversing and building pre-computed traversing paths (include lists) model **should** conform `IncludeableType` protocol.

Supported include types: `ToOne`, `ToMany`, and `Nested`. `Nested` is used in case one needs to fetch nested relationships of an already nested relationship.

### Traversing

*Halley* is heavily extensible when it comes to fetching the data and traversing. The client needs to implement/conform to `RequesterInterface` which will provide the implementation for fetching the specific resource from the given link. For example, with network requests and Alamofire:

```swift
class AlamofireRequester: RequesterInterface {

    func requestResource(
        at url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> RequestContainerInterface {
        let request = AF
            .request(Router(url: url, method: .get))
            .responseData() { response in
                completion(response.result.mapError { $0 as Error })
            }
        return RequestContainer(dataRequest: request)
    }
}

struct RequestContainer: RequestContainerInterface {

    let dataRequest: DataRequest

    func cancelRequest() {
        dataRequest.cancel()
    }
}
```

Once defined, the requester is used when starting the initial resource request:

```swift
let resourceManager = ResourceManager(requester: AlamofireRequester())
let request = HalleyRequest<Contact>(
    url: "https//www.example.com/contact/1",
    includeType: .contactsAndWebsiteOfContacts,
    queryItems: [],
    decoder: JSONDecoder()
)
_ = resourceManager
    .request(request)
    .sink { _ in
        // Print error here
    } receiveValue: { contact in
        // Parsed and traversed Contact
    }
  ```

### Templating

*Halley* supports [templated](https://datatracker.ietf.org/doc/html/draft-kelly-json-hal#name-templated) links. Each link will be resolved and templated before creating the request via `RequesterInterface`. Templates are resolved via `TemplateLinkResolver` and `DefaultTemplateHandler.shared` where the client can provide their default values which will be templated before any request made via *Halley*, or by providing custom `queryItems` in `HalleyRequest` initializer.

```swift
DefaultTemplateHandler
    .shared
    .updateTemplate(for: "country_key") { "US" }

// Link object:
// { "website": "https://www.example.com/contact/1/website{?country_key}", "templated": true }
// will be resolved as:
// https://www.example.com/contact/1/website?country_key=US
```

### Manual traversing

The client can opt-out from using Codable and type-safe parsing and use simplified methods on `ResourceManager`

```swift
func resource(
    from url: URL,
    includes: [String] = [],
    options: HalleyKit.Options = .default,
    linkResolver: LinkResolver = URLLinkResolver()
) -> some Publisher<Result<Parameters, Error>, Never>

func resourceCollection(
    from url: URL,
    includes: [String] = [],
    options: HalleyKit.Options = .default,
    linkResolver: LinkResolver = URLLinkResolver()
) -> some Publisher<Result<[Parameters], Error>, Never>

func resourceCollectionWithMetadata(
    from url: URL,
    includes: [String] = [],
    options: HalleyKit.Options = .default,
    linkResolver: LinkResolver = URLLinkResolver()
) -> some Publisher<Result<Parameters, Error>, Never>
```

In the case of `String` includes, a simple `website` string represents a to-one relationship, while a string inside square brackets `[contacts]` represents a to-many relationship. 

The nested relationship can be achieved via dot-operator like `[contacts].website` - this will fetch all the contacts of a top-level object, and for those contacts, Halley will fetch a website of each one of them.

The example above with contacts and website can be transpiled into:

```swift
let resourceManager = ResourceManager(requester: AlamofireRequester())
resourceManager
    .resource(
        from: URL(string: "https//www.example.com/contact/1")!,
        includes: [
            "[contacts]",
            "[contacts].[contacts]",
            "[contacts].website",
            "website"
        ],
        options: .default,
        linkResolver: TemplateLinkResolver(parameters: [:])
    )
    .sink { _ in
        // Print error here
    } receiveValue: { dict in
        // Parsed and traversed contact dict
    }
```


## Contributing

We believe that the community can help us improve and build better a product.
Please refer to our [contributing guide](CONTRIBUTING.md) to learn about the types of contributions we accept and the process for submitting them.

To ensure that our community remains respectful and professional, we defined a [code of conduct](CODE_OF_CONDUCT.md) <!-- and [coding standards](<link>) --> that we expect all contributors to follow.

We appreciate your interest and look forward to your contributions.


## License

```text
Copyright 2024 Infinum

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```


## Credits

* Filip Gulan - filip.gulan@infinum.com
* Zoran Turk - zoran.turk@infinum.com

Maintained and sponsored by [Infinum](http://www.infinum.com).

<p align="center">
  <a href='https://infinum.com'>
    <picture>
        <source srcset="https://assets.infinum.com/brand/logo/static/white.svg" media="(prefers-color-scheme: dark)">
        <img src="https://assets.infinum.com/brand/logo/static/default.svg">
    </picture>
  </a>
</p>
