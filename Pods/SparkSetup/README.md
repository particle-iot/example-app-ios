<p align="center" >
<img src="https://s3.amazonaws.com/spark-website/spark.png" alt="Spark" title="Spark">
</p>

# SparkSetup
The Spark Soft AP setup library is meant for integrating the initial setup process of Spark devices in your app.
This library will enable you to easily invoke a standalone setup wizard UI for setting up internet-connect products
powered by a Spark Photon/P0/P1. The setup UI can be easily customized by a customization proxy class available to the user
that includes: look & feel, colors, fonts as well as custom brand logos and instructional video for your product.

<!---
[![CI Status](http://img.shields.io/travis/spark/SparkSetup.svg?style=flat)](https://travis-ci.org/spark/SparkSetup)
[![Version](https://img.shields.io/cocoapods/v/Spark-Setup.svg?style=flat)](http://cocoapods.org/pods/SparkSetup)
[![License](https://img.shields.io/cocoapods/l/Spark-Setup.svg?style=flat)](http://cocoapods.org/pods/SparkSetup)
[![Platform](https://img.shields.io/cocoapods/p/Spark-Setup.svg?style=flat)](http://cocoapods.org/pods/SparkSetup)
-->

## Usage

### Basic
Import `SparkSetupMainController.h` in your view controller implementation file, and invoke setup wizard by:
```Objective-C
SparkSetupMainController *setupController = [SparkSetupMainController new];
[self presentViewController:setupController animated:YES completion:nil];
```

### Customization

Customize setup look and feel by #importing `SparkSetupCustomization.h`,
access the SparkSetupCustomization singleton appearance proxy using 
```Objective-C
[SparkSetupCustomization sharedInstance]
```
and modify its self-explanatory properties.

### Advanced

You can get an active instance of `SparkDevice` by making your viewcontroller conform to protocol `<SparkSetupMainControllerDelegate>` when Setup Wizard completes:
```Objective-C
-(void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device;
```
will be called. and if `(result == SparkSetupMainControllerResultSuccess)` the device parameter will contain an active `SparkDevice` instance you can interact with
using the Spark-SDK.

(Extended usage instructions coming soon)

## Requirements

(coming soon)

## Installation

Spark-Setup is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SparkSetup"
```

## Communication

- If you **need help**, use [Our community website](http://community.spark.io)
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Author

Ido K, ido@spark.io
Spark

## License

SparkSetup is available under the LGPL v3 license. See the LICENSE file for more info.
