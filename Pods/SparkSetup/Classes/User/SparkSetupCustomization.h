//
//  SparkSetupCustomization.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/12/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SparkSetupCustomization : NSObject

/**
 *  Spark soft AP setup wizard apperance customization proxy class
 *
 *  @return Singleton instance of the customization class
 */
+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *deviceName;
@property (nonatomic, strong) UIImage *deviceImage;

@property (nonatomic, strong) NSString *brandName;
@property (nonatomic, strong) UIImage *brandImage;
@property (nonatomic, strong) UIColor *brandImageBackgroundColor;
@property (nonatomic, strong) NSString *welcomeVideoFilename;

@property (nonatomic, strong) NSString *modeButtonName;
@property (nonatomic, strong) NSString *listenModeLEDColorName;
@property (nonatomic, strong) NSString *networkNamePrefix;
@property (nonatomic, strong) NSString *appName;

@property (nonatomic, strong) NSURL *termsOfServiceLinkURL; // URL for terms of service of the app/device usage
@property (nonatomic, strong) NSURL *privacyPolicyLinkURL;  // URL for privacy policy of the app/device usage
@property (nonatomic, strong) NSURL *forgotPasswordLinkURL; // URL for user password reset (non-organization setup app only)
@property (nonatomic, strong) NSURL *troubleshootingLinkURL; // URL for troubleshooting text of the app/device usage

@property (nonatomic, strong) NSString *termsOfServiceHTMLFile; // Static HTML for terms of service of the app/device usage
@property (nonatomic, strong) NSString *privacyPolicyHTMLFile;  // Static HTML for privacy policy of the app/device usage
@property (nonatomic, strong) NSString *forgotPasswordHTMLFile; // Static HTML for user password reset (non-organization setup app only)
@property (nonatomic, strong) NSString *troubleshootingHTMLFile; // Static HTML for troubleshooting text of the app/device usage

@property (nonatomic, strong) UIColor *pageBackgroundColor;
@property (nonatomic, strong) UIImage *pageBackgroundImage;
@property (nonatomic, strong) UIColor *normalTextColor;
@property (nonatomic, strong) UIColor *linkTextColor;
@property (nonatomic, strong) UIColor *errorTextColor;

@property (nonatomic, strong) UIColor *elementBackgroundColor;  // Buttons/spinners background color
@property (nonatomic, strong) UIColor *elementTextColor;        // Buttons text color
@property (nonatomic, strong) NSString *normalTextFontName;     // Customize setup font - include OTF/TTF file in project
@property (nonatomic, strong) NSString *boldTextFontName;       // Customize setup font - include OTF/TTF file in project
@property (nonatomic) CGFloat fontSizeOffset;                   // Set offset of font size so small/big fonts can be fine-adjusted

@property (nonatomic, assign) BOOL organization;                 // enable invite codes, other APIs
@property (nonatomic, strong) NSString *organizationName;        // organizational name for API endpoint URL
@property (nonatomic, strong) NSString *getReadyVideoFilePath;   // video in get ready screen
//@property (nonatomic, strong) NSString *discoverVideoFilePath; // video in device discovery screen


@end
