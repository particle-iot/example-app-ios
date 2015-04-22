//
//  SparkSetupViewController.m
//  mobile-sdk-ios
//
//  Created by Ido Kleinman on 12/13/14.
//  Copyright (c) 2014-2015 Spark. All rights reserved.
//

#import "SparkSetupUIViewController.h"
#import "SparkSetupCustomization.h"

@interface SparkSetupUIViewController ()
@property (nonatomic, assign) CGFloat kbSizeHeight;
@property (weak, nonatomic) IBOutlet UIImageView *brandImageView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation SparkSetupUIViewController

#pragma mark view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [SparkSetupCustomization sharedInstance].pageBackgroundColor;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[SparkSetupCustomization sharedInstance].pageBackgroundImage];
    backgroundImage.frame = [UIScreen mainScreen].bounds;
    
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];

    // do customization
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)disableKeyboardMovesViewUp
{
    // TODO: something less hacky
    [self viewWillDisappear:NO];

}
#pragma mark public methods


- (BOOL)isValidEmail:(NSString *)checkString // TODO: move to NSString category under helpers (as well as encode/decode hex)
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}



#pragma mark - Notifications / Keyboard move handling

- (void)keyboardWillShow:(NSNotification *)notification
{
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    self.tap.cancelsTouchesInView = YES; // to enable touches to go through tableviews, etc
    [self.view addGestureRecognizer:self.tap];

    self.kbSizeHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.kbSizeHeight -= [self keyboardHeightAdjust];
    
    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.view removeGestureRecognizer:self.tap];

    if (self.view.frame.origin.y >= 0) {
        [self setViewMovedUp:YES];
    } else if (self.view.frame.origin.y < 0) {
        [self setViewMovedUp:NO];
    }
}

- (void)dismissKeyboard
{
    [self.view endEditing:YES];
}

- (CGFloat)keyboardHeightAdjust
{
    return 100.0; // TODO: something dynamic
}


//method to move the view up/down whenever the keyboard is shown/dismissed
- (void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= self.kbSizeHeight;
        rect.size.height += self.kbSizeHeight;
    } else {
        // revert back to the normal state.
        rect.origin.y += self.kbSizeHeight;
        rect.size.height -= self.kbSizeHeight;
    }
    self.view.frame = rect;
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
}

@end
