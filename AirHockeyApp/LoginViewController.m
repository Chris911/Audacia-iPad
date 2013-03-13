//
//  LoginViewController.m
//  AirHockeyApp
//
//  Created by Chris on 13-02-11.
//
//

#import "LoginViewController.h"
#import "AppDemoAppDelegate.h"
#import "NewMenuViewController.h"
#import "WebClient.h"
#import "NetworkUtils.h"
#import "Session.h"
#import <QuartzCore/QuartzCore.h>

#define usernameTextBoxTag 0
#define passwordTextBoxTag 1
#define serverTextBoxTag   2

@interface LoginViewController()
{
    BOOL loginViewIsHidden;
    BOOL loginViewIsOnTop;
}

@end

@implementation LoginViewController

- (void) setUpView
{
    self.usernameTextBox.tag = usernameTextBoxTag;
    self.passwordTextBox.tag = passwordTextBoxTag;
    self.serverTextBox.tag = serverTextBoxTag;
    
    self.loginBoxView.center = CGPointMake(512, 384);
    [self.loginBoxView.layer setCornerRadius:20.0f];
    [self.loginBoxView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.loginBoxView.layer setBorderWidth:1.5f];
    [self.loginBoxView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.loginBoxView.layer setShadowOpacity:0.8];
    [self.loginBoxView.layer setShadowRadius:3.0];
    [self.loginBoxView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    self.loginBoxView.userInteractionEnabled = NO;
    
    self.serverTextBox.text = @"kepler.step.polymtl.ca";
    self.usernameTextBox.text = @"";
    self.passwordTextBox.text = @"";
    self.errorLabel.text = @"";
    
    //Add observer for login event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginEventFinished)
                                             name:@"LoginEventFinish"
                                             object:nil];
    
    //Add observers for keyboard
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow)
                                             name: UIKeyboardWillShowNotification
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide)
                                             name: UIKeyboardWillHideNotification
                                             object:nil];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    loginViewIsHidden = YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if(loginViewIsHidden) {
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
    if([NetworkUtils isNetworkAvailable]) {
    [self toggleConnectionView];
    } else {
        [NetworkUtils showNetworkUnavailableAlert];
    }
}

- (IBAction)pressedContinueAnonButton:(id)sender
{
    if([NetworkUtils isNetworkAvailable]){
        
        AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        // Check if the webClient is properly created
        if(delegate.webClient == nil){
            delegate.webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
        }
        // switch to menu
        [self transitionToMenu];
    } else {
        //[NetworkUtils showNetworkUnavailableAlert];
        [self transitionToMenu];
    }
}

- (IBAction)pressedValidateButton:(id)sender
{
    [self initLoginEvent];
}

- (void) initLoginEvent
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    // Check if the webClient is properly created
    if(delegate.webClient == nil){
        delegate.webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
    }
    
    if(self.usernameTextBox.text.length == 0) {
        self.errorLabel.text = @"Missing Username";
    } else if (self.passwordTextBox.text.length == 0){
        self.errorLabel.text = @"Missing Password";
    } else {
        //Call the real login event here. Return is handled in loginEventFinished below
        [self.hiddenView setHidden:NO];
        [self.spinner setHidden:NO];
        [self.spinner startAnimating];
        [delegate.webClient validateLogin:self.usernameTextBox.text :self.passwordTextBox.text];
    }
}

- (void) loginEventFinished
{
    [self.hiddenView setHidden:YES];
    [self.spinner setHidden:YES];
    [self.spinner stopAnimating];
    if([Session getInstance].isAuthenticated){
        [Session getInstance].username = self.usernameTextBox.text;
        [Session getInstance].password = self.passwordTextBox.text;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self transitionToMenu];
    } else {
        [Session getInstance].username = @"Guest";
        self.errorLabel.text = @"Invalid account";
    }
}

- (void) transitionToMenu
{
    if(!loginViewIsHidden)
        [self toggleConnectionView];
    
    NewMenuViewController* mv = [[[NewMenuViewController alloc]initWithNibName:@"NewMenuViewController" bundle:nil]autorelease];
    mv.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:mv animated:YES];
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == usernameTextBoxTag) {
        [self.passwordTextBox becomeFirstResponder];
    } else {
       //Do login
        [self initLoginEvent];
    }
    return YES;
}

- (void)keyboardWillShow
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.logoImage.center = CGPointMake(512, 50);
                         self.topView.center = CGPointMake(512, -40);
                         self.loginBoxView.center = CGPointMake(512, 250);
                     }];

}

- (void)keyboardWillHide
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.logoImage.center = CGPointMake(512, 71);
                         self.topView.center = CGPointMake(512, 200);
                         self.loginBoxView.center = CGPointMake(512, 382);
                     }];
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
    [_spinner release];
    [_hiddenView release];
    [_logoImage release];
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
    [self setSpinner:nil];
    [self setHiddenView:nil];
    [self setLogoImage:nil];
    [super viewDidUnload];
}

@end
