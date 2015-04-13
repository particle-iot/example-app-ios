//
//  SparkSetupSuccessFailureViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/3/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkSetupSuccessFailureViewController.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupMainController.h"
#import "SparkSetupWebViewController.h"

@interface SparkSetupSuccessFailureViewController ()
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *shortMessageLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUILabel *longMessageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *setupResultImageView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;

@end

@implementation SparkSetupSuccessFailureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // set logo
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    switch (self.setupResult) {
        case SparkSetupResultSuccess:
            self.setupResultImageView.image = [UIImage imageNamed:@"success" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup completed successfully";
            self.longMessageLabel.text = @"Congrats! You've successfully set up your {device}.";
            break;
            
        case SparkSetupResultSuccessUnknown:
            self.setupResultImageView.image = [UIImage imageNamed:@"success" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup completed!";
            self.longMessageLabel.text = @"Setup was successful, but you're not the primary owner so we can't check if the {device} connected to the Internet. If you see the LED breathing cyan this means it worked! If not, please restart the setup process.";
            break;
            
        case SparkSetupResultFailureClaiming:
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Setup failed";
            // TODO: add customization point for custom troubleshoot texts
//            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials. If {device} LED is breathing cyan an internal cloud issue occured - please contact product support.";
            self.longMessageLabel.text = @"Setup process failed at claiming your {device}, if your {device} LED is blinking in blue or green this means that you provided wrong Wi-Fi credentials. If {device} LED is breathing cyan an internal cloud issue occured - please contact customer care for help connecting your Wi-Fi module.";

            break;
            
        case SparkSetupResultFailureCannotDisconnectFromDevice:
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Oops!";
            self.longMessageLabel.text = @"Setup process couldn't claim your {device}! If the {device} LED is blinking blue or green then you may have mistyped the Wi-Fi credentials and you should try setup again. If the LED is breathing cyan a server issue may have occurred - please contact support.";
            break;
            
        case SparkSetupResultFailureConfigure:
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Uh oh!";
            self.longMessageLabel.text = @"Setup process couldn't disconnect from the {device} Wi-fi network. This is an internal problem with the device, so please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
            break;
            
        case SparkSetupResultFailureLostConnectionToDevice:
            self.setupResultImageView.image = [UIImage imageNamed:@"failure" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
            self.shortMessageLabel.text = @"Error!";
            self.longMessageLabel.text = @"Setup process couldn't configure the Wi-Fi credentials for your {device}, please try running setup again after resetting your {device} and putting it back in blinking blue listen mode if needed.";
            break;
            
            
    }
    
    [self.longMessageLabel setType:@"normal"];
}


- (IBAction)doneButtonTapped:(id)sender
{
    
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if ((self.setupResult == SparkSetupResultSuccess) || (self.setupResult == SparkSetupResultSuccessUnknown))
    {
        userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultSuccess);
        if (self.device)
            userInfo[kSparkSetupDidFinishDeviceKey] = self.device;
    }
    else
    {
        userInfo[kSparkSetupDidFinishStateKey] = @(SparkSetupMainControllerResultFailure);
    }
    
    // finish with success and provide device
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidFinishNotification
                                                        object:nil
                                                      userInfo:userInfo];

    
}


- (IBAction)troubleshootingButtonTouched:(id)sender
{
    
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
