//
//  SparkDiscoverDeviceViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/16/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkDiscoverDeviceViewController.h"
#import "SparkSetupConnection.h"
#import "SparkSetupCommManager.h"
#import "SparkSelectNetworkViewController.h"
#import <Foundation/Foundation.h>
#import "SparkSetupCustomization.h"
#import "SparkCloud.h"
#import "SparkSetupSecurityManager.h"
#import "SparkSetupUILabel.h"
//#import "UIViewController+SparkSetupCommManager.h"
#import "SparkSetupUIElements.h"

#define isiPhone4  ([[UIScreen mainScreen] bounds].size.height == 480) ? YES : NO

@interface SparkDiscoverDeviceViewController () <NSStreamDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) NSTimer *checkConnectionTimer;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIButton *settingsLinkButton;
@property (weak, nonatomic) IBOutlet UIImageView *wifiSignalImageView;

@property (weak, nonatomic) IBOutlet UILabel *networkNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *troubleShootingButton;

@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (strong, nonatomic) NSArray *scannedWifiList;
@property (weak, nonatomic) IBOutlet UIButton *cancelSetupButton;
@property (nonatomic, strong) NSString *detectedDeviceID;

@property (nonatomic) BOOL gotPublicKey;
@property (nonatomic) BOOL gotOwnershipInfo;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productImageHeight;

// new claiming process
@property (nonatomic) BOOL isDetectedDeviceClaimed;
@property (nonatomic) BOOL needToCheckDeviceClaimed;
@property (nonatomic) BOOL userAlreadyOwnsDevice;
@property (nonatomic) BOOL deviceClaimedByUser;
@property (nonatomic, strong) UIAlertView *changeOwnershipAlertView;

@end

@implementation SparkDiscoverDeviceViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDidAppear:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    


    self.productImageView.image = [SparkSetupCustomization sharedInstance].deviceImage;
    
    // apply tint to spinner
    //][self.spinner.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    self.spinner.tintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;
    //    self.spinner.color = [SparkSetupCustomization sharedInstance].elementBackgroundColor;

    
    // customize logo
    self.brandImage.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    self.wifiSignalImageView.image = [UIImage imageNamed:@"wifi3"  inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
    self.wifiSignalImageView.hidden = NO;
    self.needToCheckDeviceClaimed = NO;
    
    self.gotPublicKey = NO;
    self.gotOwnershipInfo = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)resetWifiSignalIconWithDelay
{
    // TODO: this is a hack
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.wifiSignalImageView.image = [UIImage imageNamed:@"wifi3" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self.spinner stopAnimating];
        self.wifiSignalImageView.hidden = NO;
        
    });
}

-(void)restartDeviceDetectionTimer
{
    NSLog(@"restartDeviceDetectionTimer called");
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;
    
    self.checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(checkDeviceWifiConnection:) userInfo:nil repeats:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // TODO: solve this via autolayout?
    if (isiPhone4)
        self.productImageHeight.constant = 80; //for 3.5" screen
    else
        self.productImageHeight.constant = 140;
    
    [self.view layoutIfNeeded];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self restartDeviceDetectionTimer];
}



-(void)checkDeviceWifiConnection:(id)sender
{
//    printf("Detect device timer\n");
    if ([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
    {
        [self.checkConnectionTimer invalidate];
        
        // UI activity indicator
        dispatch_async(dispatch_get_main_queue(), ^{
            self.wifiSignalImageView.hidden = YES;
            [self.spinner startAnimating];
            
            
        });
        
        // Start connection command chain process with a small delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getDeviceID];
        });

    }
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];

    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"select_network"])
    {
        [self.checkConnectionTimer invalidate];
        // Get reference to the destination view controller
        SparkSelectNetworkViewController *vc = [segue destinationViewController];
        [vc setWifiList:self.scannedWifiList];
        vc.deviceID = self.detectedDeviceID;
        vc.needToClaimDevice = self.needToCheckDeviceClaimed;
    }
}


-(void)getDeviceID
{
    if (!self.detectedDeviceID)
    {
        
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [self.checkConnectionTimer invalidate];
        [manager deviceID:^(id deviceResponseDict, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Could not send device-id command: %@", error.localizedDescription);
                 [self restartDeviceDetectionTimer];
                 [self resetWifiSignalIconWithDelay];
                 
             }
             else
             {
                 
                 self.detectedDeviceID = (NSString *)deviceResponseDict[@"id"]; //TODO: fix that dict interpretation is done in comm manager (layer completion)
                 self.detectedDeviceID = [self.detectedDeviceID lowercaseString];
                 self.isDetectedDeviceClaimed = [deviceResponseDict[@"c"] boolValue];
                 [self photonPublicKey];
                 NSLog(@"Got device ID: %@",deviceResponseDict);
             }
         }];
    }
    else
    {
        NSLog(@"getDeviceID called again");
        [self photonPublicKey];
    }
}




-(void)photonScanAP
{
    if (!self.scannedWifiList)
    {
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [manager scanAP:^(id scanResponse, NSError *error) {
            if (error)
            {
                NSLog(@"Could not send scan-ap command: %@",error.localizedDescription);
                [self restartDeviceDetectionTimer];
                [self resetWifiSignalIconWithDelay];
            }
            else
            {
                if (scanResponse)
                {
                    self.scannedWifiList = scanResponse;
                    NSLog(@"Scan data:\n%@",self.scannedWifiList);
                    [self checkDeviceOwnershipChange];
                    
                }
                
            }
        }];
    }
    else
    {
        [self checkDeviceOwnershipChange];
    }
    
}


-(void)checkDeviceOwnershipChange
{
    if (!self.gotOwnershipInfo)
    {
        [self.checkConnectionTimer invalidate];
        self.needToCheckDeviceClaimed = NO;
        
//        self.isDetectedDeviceClaimed = YES; // DEBUG
        if (!self.isDetectedDeviceClaimed) // device was never claimed before - so we need to claim it anyways
        {
            self.needToCheckDeviceClaimed = YES;
            [self setDeviceClaimCode];
        }
        else
        {
            self.deviceClaimedByUser = NO;
            
            for (NSString *claimedDeviceID in self.claimedDevices)
            {
                if ([claimedDeviceID isEqualToString:self.detectedDeviceID])
                {
                    self.deviceClaimedByUser = YES;
                }
            }
            
            // if the user already owns the device it does not need to be set with a claim code but claiming check should be performed as last stage of setup process
            if (self.deviceClaimedByUser)
                self.needToCheckDeviceClaimed = YES;
            
            self.gotOwnershipInfo = YES;
            
            if ((self.isDetectedDeviceClaimed == YES) && (self.deviceClaimedByUser == NO))
            {
                // that means device is claimed by somebody else - we want to check that with user (and set claimcode if user wants to change ownership)
                NSString *messageStr = [NSString stringWithFormat:@"This %@ is owned by another user, do you wish to change ownership to %@?",[SparkSetupCustomization sharedInstance].deviceName,[SparkCloud sharedInstance].loggedInUsername];
                self.changeOwnershipAlertView = [[UIAlertView alloc] initWithTitle:@"Product ownership" message:messageStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes",@"No",nil];
                [self.checkConnectionTimer invalidate];
                [self.changeOwnershipAlertView show];
            }
            else
            {
                // no need to set claim code because the device is owned by current user
                [self performSegueWithIdentifier:@"select_network" sender:self];
            }
            
        }
        
        // all cases:
//        (1) device not claimed c=0 — device should also not be in list from API => mobile app assumes user is claiming and sets device claimCode + check its claimed at last stage
//        (2) device claimed c=1 and already in list from API => mobile app does not ask user about taking ownership because device already belongs to this user, does NOT set claimCode to device (no need) but does check ownership in last setup step
//        (3) device claimed c=1 and NOT in the list from the API => mobile app asks whether user would like to take ownership. YES: set claimCode and check ownership in last step, NO: doesn't set claimCode, doesn't check ownership in last step
    }
    else
    {
        if (self.needToCheckDeviceClaimed)
        {
            if (!self.deviceClaimedByUser)
                [self setDeviceClaimCode];
        }
        else
            [self performSegueWithIdentifier:@"select_network" sender:self];
            
    }
    
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.changeOwnershipAlertView)
    {
        NSLog(@"button index %ld",(long)buttonIndex);
        if (buttonIndex == 0) //YES
        {
            self.needToCheckDeviceClaimed = YES;
            [self setDeviceClaimCode];
        }
        else
        {
            self.needToCheckDeviceClaimed = NO;
            [self performSegueWithIdentifier:@"select_network" sender:self];
        }
    }
}




-(void)photonPublicKey
{
    if (!self.gotPublicKey)
    {
        SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
        [self.checkConnectionTimer invalidate];
        [manager publicKey:^(id responseCode, NSError *error) {
            if (error)
            {
                NSLog(@"Error sending public-key command to target: %@",error.localizedDescription);
                [self restartDeviceDetectionTimer]; // TODO: better error handling
                [self resetWifiSignalIconWithDelay];
            }
            else
            {
                NSInteger code = [responseCode integerValue];
                if (code != 0)
                {
                    NSLog(@"Public key retrival error");
                    [self restartDeviceDetectionTimer]; // TODO: better error handling
                    [self resetWifiSignalIconWithDelay];
                    
                }
                else
                {
                    self.gotPublicKey = YES;
                    [self photonScanAP];
                }
            }
        }];
    }
    else
    {
        [self photonScanAP];
    }
}




-(void)setDeviceClaimCode
{
    SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
    [self.checkConnectionTimer invalidate];
    [manager setClaimCode:self.claimCode completion:^(id responseCode, NSError *error) {
        if (error)
        {
            NSLog(@"Could not send set command: %@", error.localizedDescription);
            [self restartDeviceDetectionTimer];
        }
        else
        {
            NSLog(@"Set device claim code %@",self.claimCode);
            // finished - segue
            [self performSegueWithIdentifier:@"select_network" sender:self];

        }
    }];
    
}




-(void)getDeviceVersion
{
    SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
    [self.checkConnectionTimer invalidate];
    [manager version:^(id version, NSError *error) {
        if (error)
        {
            NSLog(@"Could not send version command: %@",error.localizedDescription);
        }
        else
        {
            NSString *versionStr = version;
            NSLog(@"Device version:\n%@",versionStr);
        }
    }];
}



- (IBAction)cancelButtonTouched:(id)sender
{
    // finish gracefully
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification object:nil userInfo:@{kSparkSetupDidFinishStateKey:@(SparkSetupMainControllerResultUserCancel)}];
    
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self.setupController.delegate sparkSetupViewController:self.setupController didFinishWithResult:SparkSetupMainControllerResultUserCancel error:nil];
//    }];
    
}

- (IBAction)settingsButton:(id)sender
{

    BOOL canOpenSettings = (UIApplicationOpenSettingsURLString != NULL); // TODO: find iOS 7 solution
    if (canOpenSettings) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}






@end
