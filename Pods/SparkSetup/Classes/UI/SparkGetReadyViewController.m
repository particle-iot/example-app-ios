//
//  SparkGetReadyViewController.m
//  teacup-ios-app
//
//  Created by Ido on 1/15/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkGetReadyViewController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SparkCloud.h"
#import "SparkSetupMainController.h"
#import "SparkDiscoverDeviceViewController.h"
#import "SparkSetupUIElements.h"

#import "SparkSetupSuccessFailureViewController.h"

@interface SparkGetReadyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet UILabel *getReadyLabel;
@property (weak, nonatomic) IBOutlet UIButton *troubleShootingButton;
@property (strong, nonatomic) MPMoviePlayerController *videoPlayer;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;

@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;

// new claiming process
@property (nonatomic, strong) NSString *claimCode;
@property (nonatomic, strong) NSArray *claimedDevices;


@end

@implementation SparkGetReadyViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;

    self.loggedInLabel.text = [self.loggedInLabel.text stringByAppendingString:[SparkCloud sharedInstance].loggedInUsername];
    self.loggedInLabel.alpha = 0.7;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.videoPlayer stop];
    [self.videoPlayer.view removeFromSuperview];
    self.videoPlayer = nil;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSString *videoFileName = [SparkSetupCustomization sharedInstance].welcomeVideoFilename;
    if (videoFileName)
    {
        NSArray *videoFilenameArr = [videoFileName componentsSeparatedByString:@"."];
        NSString *path = [[NSBundle mainBundle] pathForResource:videoFilenameArr[0] ofType:videoFilenameArr[1]];
        
        if (path)
            self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
        if (self.videoPlayer)
        {
            self.videoPlayer.shouldAutoplay = YES;
            self.videoPlayer.view.frame = self.videoView.bounds;
            self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
            self.videoPlayer.fullscreen = NO;
            self.videoPlayer.movieSourceType = MPMovieSourceTypeFile;
            self.videoPlayer.scalingMode = MPMovieScalingModeAspectFit;
            self.videoPlayer.controlStyle = MPMovieControlStyleNone;
            [self.videoView addSubview:self.videoPlayer.view];
            [self.videoPlayer play];
        }
    }
}

- (IBAction)troubleShootingButtonTapped:(id)sender
{
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].troubleshootingLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.videoPlayer stop];
    
    if ([[segue identifier] isEqualToString:@"discover"])
    {
        SparkDiscoverDeviceViewController *vc = [segue destinationViewController];
        vc.claimCode = self.claimCode;
        vc.claimedDevices = self.claimedDevices;
    }
}

- (IBAction)readyButtonTapped:(id)sender
{
    [self.spinner startAnimating];
    self.readyButton.userInteractionEnabled = NO;
    
    
    [[SparkCloud sharedInstance] generateClaimCode:^(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
    //  [[SparkCloud sharedInstance] generateClaimCode:^(NSString *claimCode, NSArray *userClaimedDeviceIDs, NSError *error) {
    
        self.readyButton.userInteractionEnabled = YES;
        [self.spinner stopAnimating];
        
        if (!error)
        {
            self.claimCode = claimCode;
            self.claimedDevices = userClaimedDeviceIDs;
            NSLog(@"Got claim code: %@",self.claimCode);
            NSLog(@"Devices IDs owned by user: %@",self.claimedDevices);
            [self performSegueWithIdentifier:@"discover" sender:self];
            
        }
        else
        {
            if (error.code == 401)// localizedDescription containsString:@"unauthorized"])
            {
                NSString *errStr = [NSString stringWithFormat:@"Sorry, you must be logged in as a %@ customer.",[SparkSetupCustomization sharedInstance].brandName];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Access denied" message:errStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [[SparkCloud sharedInstance] logout];
                // call main delegate or post notification
                [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidLogoutNotification object:nil userInfo:nil];
            }
            else
            {
                NSString *errStr = [NSString stringWithFormat:@"Could not communicate with Spark cloud. Make sure your iOS device is connected to the internet and retry.\n\n(%@)",error.localizedDescription];
                UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:errStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                errorAlertView.delegate = self;
                [errorAlertView show];
            }
        }
    }];
    

}


- (IBAction)logoutButtonTouched:(id)sender
{
//    [self.checkConnectionTimer invalidate];
    [[SparkCloud sharedInstance] logout];
    // call main delegate or post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kSparkSetupDidLogoutNotification object:nil userInfo:nil];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
}



@end
