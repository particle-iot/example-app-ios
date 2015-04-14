//
//  SparkSetupManager.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SparkSetupCustomization.h"
#import "Spark-SDK.h"

typedef NS_ENUM(NSInteger, SparkSetupMainControllerResult) {
    SparkSetupMainControllerResultSuccess=1,
    SparkSetupMainControllerResultFailure,
    SparkSetupMainControllerResultUserCancel,
};

extern NSString *const kSparkSetupDidLogoutNotification;
extern NSString *const kSparkSetupDidFinishNotification;
extern NSString *const kSparkSetupDidFinishStateKey;
extern NSString *const kSparkSetupDidFinishDeviceKey;

@class SparkSetupMainController;

@protocol SparkSetupMainControllerDelegate
@required
/**
 *  Method will be called whenever SparkSetup wizard completes
 *
 *  @param controller Instance of main SparkSetup viewController
 *  @param result     Result of setup completion - can be success, failure or user-cancelled.
 *  @param device     SparkDevice instance in case the setup completed successfully and a SparkDevice was claimed to logged in user
 */
- (void)sparkSetupViewController:(SparkSetupMainController *)controller didFinishWithResult:(SparkSetupMainControllerResult)result device:(SparkDevice *)device;
@end


@interface SparkSetupMainController : UIViewController// UINavigationController

// Viewcontroller displaying the modal setup UI control
@property (nonatomic, weak) id<SparkSetupMainControllerDelegate> delegate;
//@property (nonatomic, strong) SparkSetupCustomization *customization;


/**
 *  Entry point for invoking Spark Soft AP setup wizard, use by calling this on your viewController:
 *  SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init]; // or [SparkSetupMainController new]
 *  [self presentViewController:setupController animated:YES completion:nil];
 *
 *  @return An inititalized SparkSetupMainController instance ready to be presented.
 */
-(instancetype)init;

/**
 *  Open setup wizard in Signup screen with a pre-filled activation code from a URL scheme which was used to open the app
 *
 *  @param activationCode Activation code string
 */
-(void)showSignupWithPredefinedActivationCode:(NSString *)activationCode;

/**
 *  Get default resource bundle for Spark Soft AP setup wizard assets
 *
 *  @return Default assets resource NSBundle instance
 */
+(NSBundle *)getResourcesBundle;

@end


