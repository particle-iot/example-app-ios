//
//  SparkSetupSuccessFailureViewController.h
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupUIViewController.h"
#import "Spark-SDK.h"

typedef NS_ENUM(NSInteger, SparkSetupResult) {
    SparkSetupResultSuccess=0,
    SparkSetupResultSuccessUnknown,
    SparkSetupResultFailureClaiming,
    SparkSetupResultFailureConfigure,
    SparkSetupResultFailureCannotDisconnectFromDevice,
    SparkSetupResultFailureLostConnectionToDevice
};

@interface SparkSetupSuccessFailureViewController : SparkSetupUIViewController
@property (nonatomic, strong) SparkDevice *device;
@property (nonatomic) SparkSetupResult setupResult;

@end
