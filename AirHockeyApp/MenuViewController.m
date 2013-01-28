//
//  MenuViewController.m
//  AppDemo
//

#import "MenuViewController.h"
#import "EAGLViewController.h"
#import "AppDemoAppDelegate.h"
#import "BetaViewController.h"
#import "Scene.h"
#import "Session.h" 

@interface MenuViewController()
{
    BOOL isConnectionViewVisible;
}

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Prepare for connection view and hide it
    isConnectionViewVisible = NO;
    self.ConnectionView.center = CGPointMake(self.ConnectionView.center.x, -(768/2));
    self.UsernameLabel.text = [Session getInstance].username;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)afficherVueAnimee
{
    if(!isConnectionViewVisible) {
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        [delegate afficherVueAnimee];
    } else {
        [self toggleConnectionView];
    }
}

- (IBAction)testCaseButtonPressed:(id)sender
{
    if(!isConnectionViewVisible) {
        BetaViewController* beta_vc = [[[BetaViewController alloc]init]autorelease];
        beta_vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentModalViewController:beta_vc animated:YES];
    } else {
        [self toggleConnectionView];
    }
}

- (IBAction)usernameChanged:(id)sender
{
    self.UsernameLabel.text = ((UITextField*)sender).text;
}

- (IBAction)passwordChanged:(id)sender
{
    
}

- (IBAction)showConnectionView:(id)sender
{
    [self toggleConnectionView];
}

- (void) toggleConnectionView
{
    if(!isConnectionViewVisible) {
        [UIView animateWithDuration:0.5 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.ConnectionView.center = CGPointMake(512, 768/2);
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.5 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.ConnectionView.center = CGPointMake(512, -768/2);
                         }
                         completion:nil];
    }
    isConnectionViewVisible = !isConnectionViewVisible;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.UserNameTextField) {
        [self.PasswordTextField becomeFirstResponder];
    } else if(textField == self.PasswordTextField) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)dealloc {
    [_UsernameLabel release];
    [_UserNameTextField release];
    [_PasswordTextField release];
    [_ConnectionView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setUsernameLabel:nil];
    [self setUserNameTextField:nil];
    [self setPasswordTextField:nil];
    [self setConnectionView:nil];
    [super viewDidUnload];
}
@end
