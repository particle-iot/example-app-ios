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
    SparkSetupMainControllerResultLoggedIn, // relevant to initWithAuthenticationOnly:YES only

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


@interface SparkSetupMainController : UIViewController

// Viewcontroller displaying the modal setup UI control
@property (nonatomic, weak) id<SparkSetupMainControllerDelegate> delegate;

/**
 *  Entry point for invoking Spark Soft AP setup wizard, use by calling this on your viewController:
 *  SparkSetupMainController *setupController = [[SparkSetupMainController alloc] init]; // or [SparkSetupMainController new]
 *  [self presentViewController:setupController animated:YES completion:nil];
 *  If no active user session exists than this call will also authenticate user to the Spark cloud (or allow her to sign up) before the soft AP wizard will be displayed
 *
 *  @return An inititalized SparkSetupMainController instance ready to be presented.
 */
-(instancetype)init NS_DESIGNATED_INITIALIZER;

/**
 *  Entry point for invoking Spark Cloud authentication (login/signup/password recovery screens) only, use by calling this on your viewController:
 *  SparkSetupMainController *setupController = [[SparkSetupMainController alloc] initWithAuthenticationOnly:YES];
 *  [self presentViewController:setupController animated:YES completion:nil];
 *  After user has successfully logged in or signed up, control will be return to the calling app. If an active user session already exists control will be returned immediately
 *
 *  @param yesOrNo YES will invoke Authentication wizard only, NO will invoke whole Device Setup process (will skip authentication if user session is active, same as calling -init)
 *
 *  @return An inititalized SparkSetupMainController instance ready to be presented.
 */
-(instancetype)initWithAuthenticationOnly:(BOOL)yesOrNo;

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


