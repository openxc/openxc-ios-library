# OpenXC-iOS-Library

[![CI Status](https://img.shields.io/travis/kranjanford/openxcframework.svg?style=flat)](https://travis-ci.org/openxc/openxc-ios-library)
[![Version](https://img.shields.io/cocoapods/v/openxcframework.svg?style=flat)](https://cocoapods.org/pods/openxcframework)
[![License](https://img.shields.io/cocoapods/l/openxcframework.svg?style=flat)](https://cocoapods.org/pods/openxcframework)
[![Platform](https://img.shields.io/cocoapods/p/openxcframework.svg?style=flat)](https://cocoapods.org/pods/openxcframework)

# OpenXC-iOS-Library
This framework is part of the OpenXC project. This iOS framework contains the tools required to read vehicle data from the vehicle's CAN bus through the OpenXC vehicle interface in any iOS application.


OpenXC iOS framework for use with the C5 BLE device. To run the example project, clone the repo, and run `pod install` from the Example directory first.

## OpenXC-iOS-Library-Version
* V6.0.0

## Supported versions:
* iOS - up to 13.3
* XCode - up to 11.4
* Swift - Swift5

Note: TravisCI build run will work only till XCode 10.2 -iOS 12.0 (https://github.com/travis-ci/travis-ci/issues/7031) but the framework supports XCode 10.2 and iOS 12

## Using the Framework
The framework can be picked directly from the releases
* Simulator build - openXCiOSFramework.framework.simulator.zip, ProtocolBuffers.framework.simulator.zip
* Device build - openXCiOSFramework.framework.device.zip, ProtocolBuffers.framework.device.zip

## Building from XCode

Make sure you have XCode10 installed with iOS11 to build it from XCode. This framework must be included in any iOS application that needs to connect to a VI

Refer to this [document](OpenXC_iOS_Document.md) for more details on installation and usage.

API usage details are available [here](iOS%20Framework%20API%20Guide.md). 

Also see [Step by Step Guide](https://github.com/openxc/openxc-ios-library/blob/master/StepsToBuildOpenXCiOSFrameworkAndDemoApp.docx) to build framework. 


## Tests

* to be added

## Building from Command Line

The project requires XCode, XCode command line tools installed. 

To install XCode command line tools, follow these steps for XCode:

* Launch XCode
* Go to Preferences - Locations - Command Line Tools - Install
* Open "Terminal" and change directory to framework
* Run - xcodebuild clean build test -project openxc-ios-framework.xcodeproj -scheme openxc-ios-framework


## Releasing the App and Library

* Update CHANGELOG.mkd
* Merge into master push to GitHub
* Update OpenXC in CocoaPods:
    * Update s.version in openxcframework.podspec
    * Follow the instructions in step #7 [here.](https://code.tutsplus.com/tutorials/creating-your-first-cocoapod--cms-24332)
    * When pushing to the specs repository, you must register your session first: $pod trunk register name@example.com 'Your Name'
    * The email address must belong to an owner of the pod 
* Go to https://github.com/openxc/openxc-ios-library/releases and promote the tag you just created to a new release - copy and paste the changelog into the description. Note that the tag was already created in the CocoaPods section above.


## Contributing

Please see our [Contribution Documents](https://github.com/openxc/openxc-ios-library/blob/master/CONTRIBUTING.mkd)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

openxcframework is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'openxcframework'
```

## Author

kranjanford, kranjan@ford.com

## License

openxcframework is available under the MIT license. See the LICENSE file for more info.

Copyright (c) 2016 Ford Motor Company Licensed under the BSD license.
