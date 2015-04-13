//
//  SparkUserForgotPasswordViewController.m
//  teacup-ios-app
//
//  Created by Ido on 2/13/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "SparkUserForgotPasswordViewController.h"
#import "SparkSetupCustomization.h"
#import "Spark-SDK.h"
#import "SparkSetupWebViewController.h"
#import "SparkUserLoginViewController.h"
#import "SparkSetupUIElements.h"

@interface SparkUserForgotPasswordViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;

@end

@implementation SparkUserForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.brandImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView = [[UIView alloc] initWithFrame:viewRect];
    
    self.emailTextField.leftView = emptyView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyGo;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)resetPasswordButtonTapped:(id)sender
{
    [self.view endEditing:YES];
    [self.spinner startAnimating];
    if ([SparkSetupCustomization sharedInstance].organization)
    {
        if ([self isValidEmail:self.emailTextField.text])
        {
            [[SparkCloud sharedInstance] requestPasswordReset:[SparkSetupCustomization sharedInstance].organizationName email:self.emailTextField.text completion:^(NSError *error) {
                [self.spinner stopAnimating];
                
                if (!error)
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Instuctions how to reset your password will be sent to the provided email address. Please check your email and continue according to instructions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    alert.delegate = self;
                    [alert show];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Could not find a user with supplied email address, please check the address supplied or create a new user via signup screen" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
   
                }
            }];
            
        }
        else
        {
            [self.spinner stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset password" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        [self.spinner stopAnimating];
        // TODO: should be in first screen - see what is the endpoint for non-org users
        SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
        webVC.link = [SparkSetupCustomization sharedInstance].forgotPasswordLinkURL;
        [self presentViewController:webVC animated:YES completion:nil];
    }

}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self resetPasswordButtonTapped:self];
        return YES;

    }
    return NO;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.delegate didRequestUserLogin:self];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self.delegate didRequestUserLogin:self];
    
}
@end
