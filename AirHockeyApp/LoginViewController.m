//
//  LoginViewController.m
//  AirHockeyApp
//
//  Created by Chris on 13-02-11.
//
//

#import "LoginViewController.h"
#import "AppDemoAppDelegate.h"
#import "WebClient.h"
#import "NetworkUtils.h"
#import "Session.h"
#import <QuartzCore/QuartzCore.h>

#define usernameTextBoxTag 0
#define passwordTextBoxTag 1

@interface LoginViewController()
{
    BOOL loginViewIsHidden;
}

@end

@implementation LoginViewController
- (void) setUpView
{
    self.usernameTextBox.delegate = self;
    self.usernameTextBox.tag = usernameTextBoxTag;
    self.passwordTextBox.delegate = self;
    self.passwordTextBox.tag = passwordTextBoxTag;
    
    [self.loginBoxView.layer setCornerRadius:20.0f];
    [self.loginBoxView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loginBoxView.layer setBorderWidth:1.5f];
    [self.loginBoxView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loginBoxView.layer setShadowOpacity:0.8];
    [self.loginBoxView.layer setShadowRadius:3.0];
    [self.loginBoxView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    self.loginBoxView.userInteractionEnabled = NO;
    
    self.serverTextBox.text = @"kepler.step.polymtl.ca";
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void) toggleConnectionView
{
    if(!loginViewIsHidden) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             self.loginButton.alpha = 0.0f;
                             self.loginButton.userInteractionEnabled = NO;
                             self.continueAnonButton.center = CGPointMake(512, 625);
        }];
        [UIView animateWithDuration:0.8 delay: 0.4 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.bottomView.center = CGPointMake(512, 624);
                             self.topView.center = CGPointMake(512, 200);
                             self.loginBoxView.userInteractionEnabled = YES;
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.8 delay: 0.0 options: UIViewAnimationCurveEaseIn
                         animations:^{
                             self.bottomView.center = CGPointMake(512, 384);
                             self.topView.center = CGPointMake(512, 364);
                             self.loginBoxView.userInteractionEnabled = NO;
                         }
                         completion:nil];
        [UIView animateWithDuration:0.5 delay:0.6 options: UIViewAnimationOptionAllowAnimatedContent
                         animations:^{
                             self.loginButton.alpha = 1.0f;
                             self.loginButton.userInteractionEnabled = YES;
                             self.continueAnonButton.center = CGPointMake(512, 475);
                         }
                         completion:nil];
    }
    loginViewIsHidden = !loginViewIsHidden;
}

- (IBAction)pressedLoginButton:(id)sender
{
    [self toggleConnectionView];
}

- (IBAction)pressedContinueAnonButton:(id)sender
{
    [self toggleConnectionView];
}

- (IBAction)pressedValidateButton:(id)sender
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    if([NetworkUtils isNetworkAvailable]) {
        if(self.usernameTextBox.text.length == 0) {
            self.errorLabel.text = @"Missing Username";
        } else if (self.passwordTextBox.text.length == 0){
            self.errorLabel.text = @"Missing Password";
        } else {
            if([delegate.webClient validateLogin:self.usernameTextBox.text :self.passwordTextBox.text]){
                [Session getInstance].username = self.usernameTextBox.text;
                [self dismissModalViewControllerAnimated:YES];
            } else {
                [Session getInstance].username = @"Anonymous";
                self.errorLabel.text = @"Invalid account";
            }
        }
    } else { // Internet not connected, display error
        [NetworkUtils showNetworkUnavailableAlert];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == usernameTextBoxTag) {
        [self.passwordTextBox becomeFirstResponder];
    } else {
       //Do login
    }
    return YES;
}

- (void)dealloc {
    [_iceView release];
    [_topView release];
    [_bottomView release];
    [_loginBoxView release];
    [_usernameTextBox release];
    [_passwordTextBox release];
    [_serverTextBox release];
    [_loginButton release];
    [_continueAnonButton release];
    [_teamAudacityLabel release];
    [_errorLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setIceView:nil];
    [self setTopView:nil];
    [self setBottomView:nil];
    [self setLoginBoxView:nil];
    [self setUsernameTextBox:nil];
    [self setPasswordTextBox:nil];
    [self setServerTextBox:nil];
    [self setLoginButton:nil];
    [self setContinueAnonButton:nil];
    [self setTeamAudacityLabel:nil];
    [self setErrorLabel:nil];
    [super viewDidUnload];
}

@end
