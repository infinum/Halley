# Halley

[![Version](https://img.shields.io/cocoapods/v/Halley.svg?style=flat)](https://cocoapods.org/pods/Halley)
[![License](https://img.shields.io/cocoapods/l/Halley.svg?style=flat)](https://cocoapods.org/pods/Halley)
[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
![Platforms](https://img.shields.io/static/v1?label=platform&message=iOS%2013%20&color=brightgreen)

<p align="center">
    <img src="img/halley-logo.png" width="300" max-width="50%" alt="Halley"/>
</p>

Halley provides a simple way on iOS to parse and traverse models according to [JSON Hypertext Application Language specification](https://datatracker.ietf.org/doc/html/draft-kelly-json-hal) also known just as HAL.

## Getting started

### Requirements

- iOS 13
- Swift 5.0

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

## Author

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

## License

Halley is available under the MIT license. See the LICENSE file for more info.
