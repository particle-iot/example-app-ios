//
//  SparkConnectiProgressViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/25/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkConnectingProgressViewController.h"
#import "SparkSetupCommManager.h"
#import "SparkSetupMainController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupWebViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"
#import "SparkCloud.h"
#import "SparkSetupUIElements.h"
#import "SparkSetupSuccessFailureViewController.h"


NSInteger const kMaxRetriesDisconnectFromDevice = 5;
NSInteger const kMaxRetriesClaim = 15;
NSInteger const kMaxRetriesConfigureAP = 5;
NSInteger const kMaxRetriesConnectAP = 5;
NSInteger const kMaxRetriesReachability = 5;


@interface SparkConnectingProgressViewController () <UITableViewDataSource, UITableViewDelegate>//, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *ssidLabel;
@property (weak, nonatomic) IBOutlet UITableView *connectingProgressTableView;
@property (nonatomic, strong) NSMutableArray *connectionProgressTextList;
@property (weak, nonatomic) IBOutlet UILabel *deviceIsConnectingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *troubleshootingButton;
@property (strong, nonatomic) SparkDevice *device;

@property (strong, nonatomic) Reachability *hostReachability;
@property (nonatomic) BOOL hostReachable;
@property (nonatomic) NSInteger claimRetries;
@property (nonatomic) NSInteger configureRetries;
@property (nonatomic) NSInteger connectAPRetries;
@property (nonatomic) NSInteger disconnectRetries;
@property (nonatomic, strong) UIAlertView *errorAlertView;
@property (nonatomic) BOOL connectAPsent, disconnectedFromDevice;
@property (nonatomic) SparkSetupResult setupResult;
@end

@implementation SparkConnectingProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ssidLabel.text = self.networkName;
    self.connectingProgressTableView.delegate = self;
    self.connectingProgressTableView.dataSource = self;
    
    self.connectionProgressTextList = [[NSMutableArray alloc] init];
    
    // set logo
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    self.hostReachable = NO;
    self.hostReachability = [Reachability reachabilityWithHostName:@"www.spark.io"]; //TODO: change to https://api...
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [self.hostReachability startNotifier];
    
    self.connectAPsent = NO;
    self.disconnectedFromDevice = NO;

}



- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"reachabilityChanged -- NO");
            self.hostReachable = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            NSLog(@"reachabilityChanged -- YES 3G");
            self.hostReachable = YES; // we want to make sure device changed wifis
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"reachabilityChanged -- YES WiFi");
            self.hostReachable = YES;
            break;
        }
    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"connectingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer forIndexPath:indexPath];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
    }
    
   
    NSString *text = self.connectionProgressTextList[indexPath.row];
    cell.textLabel.text = text;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont fontWithName:[SparkSetupCustomization sharedInstance].normalTextFontName size:cell.textLabel.font.pointSize]; //+[SparkSetupCustomization sharedInstance].fontSizeOffset];
    
    
    if (indexPath.row+1 == self.connectionProgressTextList.count)
    {
 
        cell.imageView.image = [UIImage imageNamed:@"spinner_big" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        [self startAnimatingSpinner:cell.imageView];
        CGSize itemSize = CGSizeMake(30, 30);
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        UIGraphicsBeginImageContextWithOptions(itemSize, NO, UIScreen.mainScreen.scale);
        CGRect imageRect = CGRectMake(0, 0, itemSize.width, itemSize.height);
        [cell.imageView.image drawInRect:imageRect];
        cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;

    }
    else
    {
        [self stopAnimatingSpinner:cell.imageView];
        cell.imageView.hidden = NO;
        cell.imageView.image = [UIImage imageNamed:@"checkmark" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;;
        
    }
    
    cell.textLabel.textColor = [SparkSetupCustomization sharedInstance].normalTextColor;
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.connectionProgressTextList.count;
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.configureRetries = 0;

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateProgressStep:@"Configure device Wi-fi credentials"];
        [self configureDeviceNetworkCredentials];
    });
                   
   }


-(void)finishSetupWithResult:(SparkSetupResult)result
{
    self.setupResult = result;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"done" sender:self];
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"done"])
    {
        SparkSetupSuccessFailureViewController *resultVC = segue.destinationViewController;
        resultVC.device = self.device;
        resultVC.setupResult = self.setupResult;
    }
}

-(void)configureDeviceNetworkCredentials
{
    
    // --- Configure-AP ---
    __block SparkSetupCommManager *managerForConfigure = [[SparkSetupCommManager alloc] init];
    
    [managerForConfigure configureAP:self.networkName passcode:self.password security:self.security channel:self.channel completion:^(id responseCode, NSError *error) {
        NSLog(@"configureAP sent");
        if ((error) || ([responseCode intValue]!=0))
        {
            self.configureRetries++;
            if (self.configureRetries >= kMaxRetriesConfigureAP-1)
            {
                [self setStateForCellOfProgressStep:0 error:YES];
                [self finishSetupWithResult:SparkSetupResultFailureConfigure];
//                self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                self.errorAlertView.delegate = self;
//                [self.errorAlertView show];
                
            }
            else
            {
                [self configureDeviceNetworkCredentials];
            }
        }
        else
        {
            if (!self.connectAPsent)
            {
                [self updateProgressStep:@"Connect to Wi-fi network"];
                self.connectAPRetries = 0;
                self.disconnectRetries = 0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self connectDeviceToNetwork];

                });
            }
            
        }
    }];
}




-(void)connectDeviceToNetwork
{
    // --- Connect-AP ---
    SparkSetupCommManager *managerForConnect = [[SparkSetupCommManager alloc] init];
    if (!self.disconnectedFromDevice)
        [managerForConnect connectAP:^(id responseCode, NSError *error) {
            //        if ((error) || ([responseCode intValue]!=0))
            //        {
            //            NSLog(@"connectAP response %ld error details %@", [responseCode intValue],error.description);
            //            if (self.connectRetries++ >= kMaxRetriesConnectAP-1)
            //            {
            //                [self setStateForCellOfProgressStep:1 error:YES];
            //                self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            //                [self.errorAlertView show];
            //                self.errorAlertView.delegate = self;
            //            }
            //            else
            //                [self connectDeviceToNetwork];
            //        }
            //        else
            //        {
            // ignoring errors on connect-ap per Mat request (device drops connection before close socket)
            // TODO: something less hacky to disregard dual callback (check why)
            //        if (!self.connectAPsent)
            //        {
            NSLog(@"connectAP sent");
            self.connectAPsent = YES;
            
            while (([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix]) && (self.disconnectRetries < kMaxRetriesDisconnectFromDevice))
            {
                [NSThread sleepForTimeInterval:2.0];
                self.disconnectRetries++;
            }
            
            // are we still connected to device?
            if ([SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
            {
                if (self.connectAPRetries++ >= kMaxRetriesConnectAP)
                {
                    [self setStateForCellOfProgressStep:1 error:YES];
                    [self finishSetupWithResult:SparkSetupResultFailureCannotDisconnectFromDevice];
//                    self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed disconnecting from device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    self.errorAlertView.delegate = self;
//                    [self.errorAlertView show];
                }
                else
                {
                    self.disconnectRetries = 0;
                    [self connectDeviceToNetwork]; // recursion retry sending connect-ap
                }
            }
            else
            {
                if (!self.disconnectedFromDevice) // assuring one time call (TODO: find out why this gets called many times)
                {
                    self.disconnectedFromDevice = YES;
                    NSLog(@"OK disconnected from photon, continuing after %ld x %ld tries",(long)self.connectAPRetries,(long)self.disconnectRetries);
                    [self updateProgressStep:@"Wait for device cloud connection"];
                    [self waitForCloudConnection];
                }
            }
            // --- Wait ---
        }];
    
}


-(void)waitForCloudConnection
{
    
    NSLog(@"Waiting for 5 seconds");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updateProgressStep:@"Check for internet connectivity"];
        [self checkForInternetConnectivity];

    });
    

}

-(void)checkForInternetConnectivity
{
    
    // --- reachability check ---
    if (!self.hostReachable)
    {
        for (int i=0; i<kMaxRetriesReachability-1; i++)
        {
            if (![SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
            {
                [[SparkCloud sharedInstance] getDevices:^(NSArray *devices, NSError *error) {
                    NSLog(@"getDevices completed - to wake radio up");
                }];
            }
            
            if ([self.hostReachability currentReachabilityStatus] != NotReachable)
            {
                self.hostReachable = YES;
                break;
            }
            else
            {
                [NSThread sleepForTimeInterval:1.0];
            }
        }
    }
    
    if (self.hostReachable)
    {
        self.claimRetries = 0;
        // check that SSID disappears here and didn't come back
        if (self.needToClaimDevice)
        {
            [self updateProgressStep:@"Verify product ownership"];
            [self checkDeviceIsClaimed];
        }
        else
        {
            // finished
            [self setStateForCellOfProgressStep:3 error:NO];
            [self finishSetupWithResult:SparkSetupResultSuccessUnknown];
            
        }
    }
    else
    {
        [self setStateForCellOfProgressStep:3 error:YES];
        [self finishSetupWithResult:SparkSetupResultFailureCannotDisconnectFromDevice];
//        self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot re-connect to the internet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        self.errorAlertView.delegate = self;
//        [self.errorAlertView show];
        
//        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)checkDeviceIsClaimed
{
    // --- Claim device ---
//    [[SparkCloud sharedInstance] claimDevice:self.deviceID completion:^(NSError *error) {
    [[SparkCloud sharedInstance] getDevices:^(NSArray *devicesInfo, NSError *error) {
        BOOL deviceClaimed = NO;
        if (devicesInfo)
        {
            for (NSDictionary *deviceDict in devicesInfo)
            {
                NSLog(@"list device ID: %@",deviceDict[@"id"]);
                if ([deviceDict[@"id"] isEqualToString:self.deviceID])
                {
                    // device now appear's in users claimed devices so it's claimed
                    deviceClaimed = YES;
                }
            }
            NSLog(@"--------");
        }
        
        if ((error) || (!deviceClaimed))
        {
            self.claimRetries++;
            NSLog(@"Claim try %ld",(long)self.claimRetries);
            if (self.claimRetries >= kMaxRetriesClaim-1)
            {
                [self setStateForCellOfProgressStep:4 error:YES];
                [self finishSetupWithResult:SparkSetupResultFailureClaiming];
//                self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not verify device ownership." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                self.errorAlertView.delegate = self;
//                [self.errorAlertView show];
            }
            else
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self checkDeviceIsClaimed]; // recursion retry
                });
                
            }
        }
        else
        {
            NSLog(@"Claim success");
            // get the claimed device to report it back to the user
            [[SparkCloud sharedInstance] getDevice:self.deviceID completion:^(SparkDevice *device, NSError *error) {
                // --- Done ---
                if (!error)
                {
                    self.device = device;
//                    self.doneButton.enabled = YES;
                    [self setStateForCellOfProgressStep:4 error:NO];
                    
                    self.setupResult = SparkSetupResultSuccess;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self performSegueWithIdentifier:@"done" sender:self];
                    });
                }
                else
                {
                    [self setStateForCellOfProgressStep:4 error:YES];
                    [self finishSetupWithResult:SparkSetupResultFailureClaiming];

//                    self.errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Could not get owned device from cloud.\n\n(%@)",error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    self.errorAlertView.delegate = self;
//                    [self.errorAlertView show];
                    
                }
            }];


        }
    }];
    
}


-(void)updateProgressStep:(NSString *)stepText
{
    [self setStateForCellOfProgressStep:self.connectionProgressTextList.count error:NO]; // set V to the previous cell
    // check that SSID disappears here and didn't come back
    [self.connectionProgressTextList addObject:stepText];
    NSLog(@" + updateProgressStep: %@",stepText);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.connectingProgressTableView reloadData];
        [self.connectingProgressTableView setNeedsDisplay];
    });

}






- (void)dealloc
{
//    NSLog(@"-- removed kReachabilityChangedNotification");
    [self.hostReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"-- removed kReachabilityChangedNotification");
    [self.hostReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


-(void)setStateForCellOfProgressStep:(NSInteger)row error:(BOOL)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell *cell = [self.connectingProgressTableView cellForRowAtIndexPath:indexPath];
        [self stopAnimatingSpinner:cell.imageView];
        cell.imageView.hidden = NO;
        if (error)
            cell.imageView.image = [UIImage imageNamed:@"x" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        else
            cell.imageView.image = [UIImage imageNamed:@"checkmark" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]; // TODO: make iOS7 compatible
        cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.imageView.tintColor = [SparkSetupCustomization sharedInstance].elementBackgroundColor;
        [cell setNeedsDisplay];

    });
}


// TODO: try again to make a custom cell with SparkSetupUISpinner + imageview + label + autolayout and remove this dup code-
-(void)startAnimatingSpinner:(UIImageView *)spinner
{
    spinner.hidden = NO;
    CABasicAnimation *rotation;
    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotation.fromValue = [NSNumber numberWithFloat:0];
    rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
    rotation.duration = 1.1; // Speed
    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    [spinner.layer addAnimation:rotation forKey:@"Spin"];
}


-(void)stopAnimatingSpinner:(UIImageView *)spinner

{
    spinner.hidden = YES;
    [spinner.layer removeAllAnimations];
}


@end
