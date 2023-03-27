# OpenXC iOS

## Contents

* [Using VI with iOS](#using-vi-with-ios)
* [Install the Demo Application](#install-the-demo-application)
* [For Contributors](#for-contributors)
* [App Tutorial](#app-tutorial)
* Starter Application

## Using VI with iOS

So, you just bought an openxc VI? Let’s get it programmed and test it in a car with your iOS device or laptop. If you have issues at any point in this process, check for similar issues in the [Google Group](http://groups.google.com/group/openxc) or create a new post to ask for some assistance.

## Install the Demo Application

iOS openxc demo application is available on GitHub in the [openxc-ios-library](https://github.com/openxc/openxc-ios-library) repository. 

Follow these steps to install it on your device:

1. Install XCode 8 or latest in your machine if not installed. ([steps to install XCode](https://developer.apple.com/xcode/downloads/))
1. Create an empty folder on your machine and name it accordingly.
1. Open terminal and go to that folder `cd <folder Path>`.
1. Copy the link from GitHub which you want to clone (master or next) branch.
1. Use command in terminal `git clone <link>` and press enter. It will start cloning the project inside your folder.
1. After cloning go to openxc-ios-library Example folder `cd openxc-ios-library/Example`.
1. If necessary, install cocoapods using `sudo gem install cocoapods`.
1. Run `pod install` from terminal. Note: May take a while.
1. Open .xcworkspace file and run the app in device or simulator. 

That’s it! You can now proceed to the next steps to start using the library in your project.

## For Contributors

Clone the [openxc-ios-library](https://github.com/openxc/openxc-ios-library) repository using Git. If you don’t already have Git installed, GitHub has a [good reference](https://help.github.com/articles/set-up-git) for all platforms.

After cloning the `openxc-ios-library`, open the .xcworkspace inside Example in XCode. This should have `openxc-framework`, `protobuf`, `AppCenter` as part of project and other ios framework also.

Once you have the library set up, you can start writing your first openxc app using the steps mentioned below. If you are having trouble, check out the troubleshooting steps.

## App Tutorial

This tutorial assumes you have a working knowledge of how to create an iOS application. Setting up the development environment and understanding iOS fundamentals is outside the scope of openxc, and Apple already provides documentation and tutorials. The best place to start is [Apple developer portal](https://developer.apple.com/).

Once you’re comfortable with creating an iOS app, continue on with this tutorial to enrich it with data from your vehicle.
