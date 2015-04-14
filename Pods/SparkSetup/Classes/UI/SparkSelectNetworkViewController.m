//
//  SparkSelectNetworkViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/19/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkSelectNetworkViewController.h"
#import "SparkSetupPasswordEntryViewController.h"
#import "SparkConnectingProgressViewController.h"
#import "SparkSetupCommManager.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupUIElements.h"
#import "SparkManualNetworkViewController.h"
#import "SparkSetupMainController.h"

// TODO: move it somewhere else
#define kSparkWifiRSSIThresholdStrong   -56
#define kSparkWifiRSSIThresholdWeak     -71



@interface SparkSelectNetworkViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *wifiTableView;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *refreshButton;
@property (weak, nonatomic) IBOutlet UILabel *selectNetworkLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;

@property (nonatomic, strong) NSIndexPath *selectedNetworkIndexPath;
@property (nonatomic, strong) NSTimer *checkConnectionTimer;
@property (nonatomic, strong) NSString *selectedNetworkSSID;
@property (nonatomic, strong) NSNumber *selectedNetworkSecurity;
@property (nonatomic, strong) NSNumber *selectedNetworkChannel;

@end

@implementation SparkSelectNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wifiTableView.delegate = self;
    self.wifiTableView.dataSource = self;
    self.wifiTableView.backgroundColor = [UIColor clearColor];
    
    // move to super viewdidload?
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    [self sortWifiList];
    self.wifiTableView.layer.borderWidth = 0.5;
    self.wifiTableView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    // temporary test init
    /*
    self.wifiList = @[
                      @{@"ssid" : @"network1", @"rssi" : @-70, @"sec" : @1},
                      @{@"ssid" : @"some-wifi", @"rssi" : @-75, @"sec" : @1},
                      @{@"ssid" : @"open_wifi", @"rssi" : @-80, @"sec" : @0},
                      @{@"ssid" : @"anotherone", @"rssi" : @-90, @"sec" : @1},
                      @{@"ssid" : @"hide_yer_kids_hide_yer_wifi", @"rssi" : @-65, @"sec" : @YES}];
     
     */
    
}


-(void)sortWifiList
{
    
    // sort by strength:
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"rssi" ascending:NO];

    // sort alphabeticly
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"ssid" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *s1 = obj1;
        NSString *s2 = obj2;
        return [s1 caseInsensitiveCompare:s2];
        
    }];

    self.wifiList = [self.wifiList sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nil]];

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifer = @"wifiCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer forIndexPath:indexPath];
    
    // Using a cell identifier will allow your app to reuse cells as they come and go from the screen.
//    if (cell == nil)
//    {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];
//    }
//    
    NSUInteger row = [indexPath row];
    
    UILabel *textLabel = (UILabel *)[cell.contentView viewWithTag:10];
    textLabel.text = self.wifiList[row][@"ssid"];
    textLabel.textColor = [SparkSetupCustomization sharedInstance].normalTextColor;
    
    UIImageView *signalStrengthImageView = (UIImageView *)[cell.contentView viewWithTag:30];
    int rssi = [self.wifiList[row][@"rssi"] intValue];
    if (rssi > kSparkWifiRSSIThresholdStrong)
    {
        [signalStrengthImageView setImage:[UIImage imageNamed:@"wifi3" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]]; // TODO: make iOS7 compatible];
    }
    else if (rssi > kSparkWifiRSSIThresholdWeak)
    {
        [signalStrengthImageView setImage:[UIImage imageNamed:@"wifi2" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]]; // TODO: make iOS7 compatible];
    }
    else
    {
        [signalStrengthImageView setImage:[UIImage imageNamed:@"wifi1" inBundle:[SparkSetupMainController getResourcesBundle] compatibleWithTraitCollection:nil]]; // TODO: make iOS7 compatible];
    }
    
        
    
//    UIImageView *secureImageView = (UIImageView *)[cell.contentView viewWithTag:20];
    SparkSetupWifiSecurityType sec = [self.wifiList[row][@"sec"] intValue];
    if (sec != SparkSetupWifiSecurityTypeOpen)
        [cell.contentView viewWithTag:20].hidden = NO;
    else
        [cell.contentView viewWithTag:20].hidden = YES;
    
    cell.backgroundColor = [UIColor clearColor];

//    [cell setNeedsLayout];
    return cell;
}


-(void)checkPhotonConnection:(id)sender
{
//    NSLog(@"checkPhotonConnection");
    if (![SparkSetupCommManager checkSparkDeviceWifiConnection:[SparkSetupCustomization sharedInstance].networkNamePrefix])
    {
        [self.checkConnectionTimer invalidate];
        [self.navigationController popViewControllerAnimated:YES];
    }
}




-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.wifiTableView reloadData];
    [self restartDeviceDetectionTimer];
    [self disableKeyboardMovesViewUp];

}

-(void)restartDeviceDetectionTimer
{
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(checkPhotonConnection:) userInfo:nil repeats:YES];

}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.wifiList count];
}



-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.checkConnectionTimer invalidate];

    if ([[segue identifier] isEqualToString:@"connect"])
    {
        // Get reference to the destination view controller
        SparkConnectingProgressViewController *vc = [segue destinationViewController];
        vc.networkName = self.selectedNetworkSSID;
        vc.channel = self.selectedNetworkChannel;
        vc.security = self.selectedNetworkSecurity;
        vc.password = @""; // non secure network
        vc.deviceID = self.deviceID; // propagate device ID
        vc.needToClaimDevice = self.needToClaimDevice;
    }
    if ([[segue identifier] isEqualToString:@"require_password"]) // prompt user for password
    {
        // Get reference to the destination view controller
        SparkSetupPasswordEntryViewController *vc = [segue destinationViewController];
        vc.networkName = self.selectedNetworkSSID;
        vc.channel = self.selectedNetworkChannel;
        vc.security = self.selectedNetworkSecurity;
        vc.deviceID = self.deviceID; // propagate device ID
        vc.needToClaimDevice = self.needToClaimDevice;
    }
    if ([[segue identifier] isEqualToString:@"manual_network"]) // prompt user for password
    {
        // Get reference to the destination view controller
        SparkManualNetworkViewController *vc = [segue destinationViewController];
        vc.deviceID = self.deviceID; // propagate device ID
        vc.needToClaimDevice = self.needToClaimDevice;
    }
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.wifiTableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedNetworkIndexPath = indexPath;

    SparkSetupWifiSecurityType secInt = [self.wifiList[indexPath.row][@"sec"] intValue];
    self.selectedNetworkSecurity = [NSNumber numberWithInt:secInt];
    self.selectedNetworkChannel = self.wifiList[indexPath.row][@"ch"];
    self.selectedNetworkSSID = self.wifiList[indexPath.row][@"ssid"];
    [self.checkConnectionTimer invalidate];
    
    if (secInt == SparkSetupWifiSecurityTypeOpen)
        [self performSegueWithIdentifier:@"connect" sender:self];
    else
        [self performSegueWithIdentifier:@"require_password" sender:self];
  
}


//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if (buttonIndex == 1)
//    {
//        NSString *password = [alertView textFieldAtIndex:0].text;
//        NSLog(@"password: %@",password);
//        [self connectToSelectedNetwork:self.selectedNetworkIndexPath withPassword:password];
//    }
//    else // User Cancelled
//        [self restartDeviceDetectionTimer];
//
//}


- (IBAction)manualNetworkButtonTapped:(id)sender
{
    
}


-(void)photonScanAP
{
    
    self.refreshButton.enabled = NO;
    [self.spinner startAnimating];
    SparkSetupCommManager *manager = [[SparkSetupCommManager alloc] init];
    [manager scanAP:^(id scanResponse, NSError *error) {
        [self.spinner stopAnimating];
        if (error)
        {
            NSLog(@"Could not send scan-ap command: %@",error.localizedDescription);
        }
        else
        {
            if (scanResponse) // check why getting two callbacks
            {
                self.wifiList = scanResponse;
                [self sortWifiList];
                [self.wifiTableView reloadData];
            }
            
        }
        self.refreshButton.enabled = YES;
    }];
}

- (IBAction)refreshScanButton:(id)sender
{
    [self photonScanAP];
}




@end
