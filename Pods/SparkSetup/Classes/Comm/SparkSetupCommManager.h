//
//  SparkSetupManager.h
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/20/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SparkSetupConnection.h"

extern NSString *const kSparkSetupConnectionEndpointAddress;
extern int const kSparkSetupConnectionEndpointPort;

typedef NS_ENUM(NSInteger, SparkSetupWifiSecurityType) {
    SparkSetupWifiSecurityTypeOpen           = 0,          /**< Unsecured                               */
    SparkSetupWifiSecurityTypeWEP_PSK        = 1,          /**< WEP Security with open authentication   */
    SparkSetupWifiSecurityTypeWEP_SHARED     = 0x8001,     /**< WEP Security with shared authentication */
    SparkSetupWifiSecurityTypeWPA_TKIP_PSK   = 0x00200002, /**< WPA Security with TKIP                  */
    SparkSetupWifiSecurityTypeWPA_AES_PSK    = 0x00200004, /**< WPA Security with AES                   */
    SparkSetupWifiSecurityTypeWPA2_AES_PSK   = 0x00400004, /**< WPA2 Security with AES                  */
    SparkSetupWifiSecurityTypeWPA2_TKIP_PSK  = 0x00400002, /**< WPA2 Security with TKIP                 */
    SparkSetupWifiSecurityTypeWPA2_MIXED_PSK = 0x00400006, /**< WPA2 Security with AES & TKIP           */
};


@interface SparkSetupCommManager : NSObject

//@property (nonatomic) BOOL ready;
+(BOOL)checkSparkDeviceWifiConnection;

//-(instancetype)initWithConnection:(SparkSetupConnection *)connection;

-(instancetype)init NS_DESIGNATED_INITIALIZER;

-(void)version:(void(^)(id version, NSError *error))completion;
-(void)deviceID:(void(^)(id responseDict, NSError *error))completion;
-(void)scanAP:(void(^)(id scanResponse, NSError *error))completion; 
-(void)configureAP:(NSString *)ssid passcode:(NSString *)passcode security:(NSNumber *)securityType channel:(NSNumber *)channel completion:(void(^)(id responseCode, NSError *error))completion;
-(void)connectAP:(void(^)(id responseCode, NSError *error))completion;
-(void)publicKey:(void(^)(id responseCode, NSError *error))completion; // retrieve the device public key and store it in keychain
-(void)setClaimCode:(NSString *)claimCode completion:(void(^)(id responseCode, NSError *error))completion;
@end
