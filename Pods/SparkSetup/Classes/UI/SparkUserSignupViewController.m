//
//  SparkUserSignupViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 11/15/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkUserSignupViewController.h"
#import "Spark-SDK.h"
#import "SparkUserLoginViewController.h"
#import "SparkSetupWebViewController.h"
#import "SparkSetupCustomization.h"
#import "SparkSetupUIElements.h"

@interface SparkUserSignupViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet SparkSetupUISpinner *spinner;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordVerifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *activationCodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *privacyButton;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *haveAccountButton;
@property (weak, nonatomic) IBOutlet UILabel *createAccountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signupButtonSpace;


@end

@implementation SparkUserSignupViewController



- (void)viewDidLoad {
    [super viewDidLoad];

    // Add underlines to link buttons / bold to navigation buttons
//    [self makeLinkButton:self.termsButton withText:nil];
//    [self makeLinkButton:self.privacyButton withText:nil];
//    [self makeBoldButton:self.haveAccountButton withText:nil];
    
    // set brand logo
    self.logoImageView.image = [SparkSetupCustomization sharedInstance].brandImage;
    self.logoImageView.backgroundColor = [SparkSetupCustomization sharedInstance].brandImageBackgroundColor;
    
    // add an inset from the left of the text fields
    CGRect  viewRect = CGRectMake(0, 0, 10, 32);
    UIView* emptyView1 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView2 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView3 = [[UIView alloc] initWithFrame:viewRect];
    UIView* emptyView4 = [[UIView alloc] initWithFrame:viewRect];
    
    self.emailTextField.leftView = emptyView1;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.delegate = self;
    self.emailTextField.returnKeyType = UIReturnKeyNext;

    self.passwordTextField.leftView = emptyView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;

    self.passwordVerifyTextField.leftView = emptyView3;
    self.passwordVerifyTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordVerifyTextField.delegate = self;
    if ([SparkSetupCustomization sharedInstance].organization)
    {
        self.passwordVerifyTextField.returnKeyType = UIReturnKeyNext;
        
        self.activationCodeTextField.leftView = emptyView4;
        self.activationCodeTextField.leftViewMode = UITextFieldViewModeAlways;
        self.activationCodeTextField.delegate = self;
        self.activationCodeTextField.hidden = NO;
    }
    else
    {
        // make sign up button be closer to verify password textfield (no activation code field)
        self.signupButtonSpace.constant = 16;
    }
    
    self.activationCodeTextField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    self.activationCodeTextField.delegate = self;
    
    if ((self.predefinedActivationCode) && (self.predefinedActivationCode.length >= 4))
    {
        // trim white space, set string max length to 4 chars and uppercase it
        NSString *code = self.predefinedActivationCode;
        NSString *codeWhiteSpaceTrimmed = [code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        codeWhiteSpaceTrimmed = [codeWhiteSpaceTrimmed stringByReplacingOccurrencesOfString:@" " withString:@""];
        codeWhiteSpaceTrimmed = [codeWhiteSpaceTrimmed stringByReplacingOccurrencesOfString:@"%20" withString:@""];
        NSRange stringRange = {0, 4};
        NSString *shortActCode = [codeWhiteSpaceTrimmed substringWithRange:stringRange];
        self.activationCodeTextField.text = [shortActCode uppercaseString];
    }

}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == self.activationCodeTextField)
    {
        NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
        // make activation code uppercase
        if (lowercaseCharRange.location != NSNotFound) {
            textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                     withString:[string uppercaseString]];
            return NO;
        }
        
        // limit it to 4 chars
        if(range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return (newLength > 4) ? NO : YES;
    }
    
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.emailTextField)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    if (textField == self.passwordTextField)
    {
        [self.passwordVerifyTextField becomeFirstResponder];
    }
    if (textField == self.passwordVerifyTextField)
    {
        if ([SparkSetupCustomization sharedInstance].organization)
            [self.activationCodeTextField becomeFirstResponder];
        else
            [self signupButton:self];
    }
    if (textField == self.activationCodeTextField)
    {
        [self signupButton:self];
    }
    
    return YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupButton:(id)sender
{
    [self.view endEditing:YES];
    
    if (![self.passwordTextField.text isEqualToString:self.passwordVerifyTextField.text])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords do not match" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    else if ([self isValidEmail:self.emailTextField.text])
    {
        BOOL orgMode = [SparkSetupCustomization sharedInstance].organization;
        if (orgMode)
        {
            if (self.activationCodeTextField.text.length < 4)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activation code" message:@"Activation code should be at least 4 characters long" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                // org user sign up
                [self.spinner startAnimating];
                
                // Sign up and then login
                [[SparkCloud sharedInstance] signupWithOrganizationalUser:self.emailTextField.text password:self.passwordTextField.text inviteCode:self.activationCodeTextField.text orgName:[SparkSetupCustomization sharedInstance].organizationName completion:^(NSError *error)
                {
                    if (!error)
                    {
                        [[SparkCloud sharedInstance] loginWithUser:self.emailTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
                            [self.spinner stopAnimating];
                            if (!error)
                            {
                                [self.delegate didFinishUserLogin:self];
                            }
                            else
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not login" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                [alert show];
                            }
                        }];
                    }
                    else
                    {
                        [self.spinner stopAnimating];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not signup" message:@"Make sure your user email does not already exist and that you have entered the activation code correctly and that it was not already used"/*error.localizedDescription*/ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alert show];
                        
                    }
                }];

            }
        }
        else
        {
            // normal user sign up
            [self.spinner startAnimating];
            
            // Sign up and then login
            [[SparkCloud sharedInstance] signupWithUser:self.emailTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
                if (!error)
                {
                    [[SparkCloud sharedInstance] loginWithUser:self.emailTextField.text password:self.passwordTextField.text completion:^(NSError *error) {
                        [self.spinner stopAnimating];
                        if (!error)
                        {
                            //                        [self performSegueWithIdentifier:@"discover" sender:self];
                            [self.delegate didFinishUserLogin:self];
                        }
                        else
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
                }
                else
                {
                    [self.spinner stopAnimating];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Invalid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)privacyPolicyButton:(id)sender
{
    [self.view endEditing:YES];
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].privacyPolicyLinkURL;
//    webVC.htmlFilename = @"test";
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)termOfServiceButton:(id)sender
{
    [self.view endEditing:YES];
    SparkSetupWebViewController* webVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"webview"];
    webVC.link = [SparkSetupCustomization sharedInstance].termsOfServiceLinkURL;
    [self presentViewController:webVC animated:YES completion:nil];
}



- (IBAction)haveAnAccountButtonTouched:(id)sender
{
    [self.view endEditing:YES];
    [self.delegate didRequestUserLogin:self];
    
    /*
    SparkUserLoginViewController* loginVC = [[UIStoryboard storyboardWithName:@"setup" bundle:[NSBundle bundleWithIdentifier:SPARK_SETUP_RESOURCE_BUNDLE_IDENTIFIER]] instantiateViewControllerWithIdentifier:@"login"];
    loginVC.delegate = self.delegate;
    loginVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;// //UIModalPresentationPageSheet;
    [self presentViewController:loginVC animated:YES completion:nil];
     */
}


@end
