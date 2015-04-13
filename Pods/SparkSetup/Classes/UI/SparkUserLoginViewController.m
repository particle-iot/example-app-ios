//
//  SparkUserLoginViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/26/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkUserLoginViewController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupUIElements.h"
#import "Spark-SDK.h"

@interface SparkUserLoginViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *brandImage;
@property (weak, nonatomic) IBOutlet UIButton *noAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@end

@implementation SparkUserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self makeLinkButton:self.forgotButton withText:@"Forgot password"];
//    [self makeBoldButton:self.noAccountButton withText:nil];
    
    // move to super viewdidload?
    self.brandImage.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.brandImage.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // Trick to add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView1 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView2 = [[UIView alloc] initWithFrame:viewRect];
    
    self.emailTextField.leftView = emptyView1;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    
    self.passwordTextField.leftView = emptyView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self loginButton:self];
    }
    
    return YES;
    
}


- (IBAction)forgotPasswordButton:(id)sender
{
    [self.delegate didRequestPasswordReset:self];
}


- (IBAction)loginButton:(id)sender
{
    [self.view endEditing:YES];
    if (self.passwordTextField.text.length == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot sign in" message:@"Password cannot be blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    
    
    if ([self isValidEmail:self.emailTextField.text])
    {
        [self.spinner startAnimating];
         [[SparkCloud sharedInstance] loginWithUser:self.emailTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
             [self.spinner stopAnimating];
             if (!error)
             {
                 // dismiss modal view and call main controller delegate to go on to setup process since login is complete
//                 [self dismissViewControllerAnimated:YES completion:^{
                     [self.delegate didFinishUserLogin:self];
//                 }];
             }
             else
             {
                 NSString *errorText;
//                 if ([error.localizedDescription containsString:@"(400)"]) // TODO: fix this hack to something nicer
                 if ([error.localizedDescription rangeOfString:@"(400)"].length > 0) //iOS7 way to do it (still need to do something nicer here)
                     errorText = @"Incorrect username and/or password";
                 else
                     errorText = error.localizedDescription;
                     
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot sign in" message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [alert show];
             }
         }];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot sign in" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }

}


- (IBAction)noAccountButton:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserSignup:self];
    
    /*
    // go back to signup
    [self dismissViewControllerAnimated:YES completion:nil];
     */

}



@end
