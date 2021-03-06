//
//  MenuViewController.m
//  AppDemo
//

#import "MenuViewController.h"
#import "EAGLViewController.h"
#import "AppDemoAppDelegate.h"
#import "CarouselTestView.h"
#import "MapsViewController.h"
#import "Scene.h"
#import "Session.h" 
#import "AudioInterface.h"
#import "LoginViewController.h"
#import "NewMenuViewController.h"

@interface MenuViewController()
{
    BOOL isConnectionViewVisible;
    BOOL isSoundEnabled;
    
    EAGLViewController *eagl;
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
    [super didReceiveMemoryWarning];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    isSoundEnabled = NO;

}

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Prepare for connection view and hide it
    isConnectionViewVisible = NO;
    self.ConnectionView.center = CGPointMake(512, -125);
    self.UsernameLabel.text = [Session getInstance].username;
    
    // Setup and start sounds
    [AudioInterface loadSounds];
    if(isSoundEnabled){
        [AudioInterface startBackgroundMusic];
    }
    
    [MapContainer removeMapsInContainers];
    
    if(eagl.isViewLoaded){
        [eagl release];
        eagl = nil;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)afficherVueAnimee
{
    eagl = [[EAGLViewController alloc]initWithNibName:@"EAGLViewController" bundle:nil];
    eagl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:eagl animated:YES];
//    if(!isConnectionViewVisible) {
//    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
//        [delegate afficherVueAnimee];
//    } else {
//        [self toggleConnectionView];
//    }
}

- (IBAction)testCaseButtonPressed:(id)sender
{

}

- (IBAction)usernameChanged:(id)sender
{
    [Session getInstance].username = ((UITextField*)sender).text;
    self.UsernameLabel.text = [Session getInstance].username;
}

- (IBAction)passwordChanged:(id)sender
{
    
}

- (IBAction)showConnectionView:(id)sender
{
    [self toggleConnectionView];
}

- (IBAction)toggleSound:(id)sender
{
    isSoundEnabled = !isSoundEnabled;
    if(isSoundEnabled){
        [AudioInterface startBackgroundMusic];
    } else {
        [AudioInterface stopBackgroundMusic];
    }
}

- (IBAction)showCarouselView:(id)sender
{
    if(!isConnectionViewVisible) {        
        CarouselTestView* carousel_vc = [[[CarouselTestView alloc]init]autorelease];
        carousel_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:carousel_vc animated:YES];
    } else {
        [self toggleConnectionView];
    }
    
//    if(!isConnectionViewVisible) {
//        MapsViewController* carousel_vc = [[[MapsViewController alloc]init]autorelease];
//        carousel_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentModalViewController:carousel_vc animated:YES];
//    } else {
//        [self toggleConnectionView];
//    }
}

- (IBAction)showLoginView:(id)sender
{
    if(!isConnectionViewVisible) {
        LoginViewController* login_vc = [[[LoginViewController alloc]init]autorelease];
        login_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:login_vc animated:YES completion:nil];
    } else {
        [self toggleConnectionView];
    }
}

- (IBAction)newMenuButtonPressed:(id)sender
{
    if(!isConnectionViewVisible) {
        NewMenuViewController* newmenu_vc = [[[NewMenuViewController alloc]init]autorelease];
        newmenu_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:newmenu_vc animated:YES completion:nil];
    } else {
        [self toggleConnectionView];
    }
}

// Show or hide the connection view
- (void) toggleConnectionView
{
    if(!isConnectionViewVisible) {
        [UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             self.ConnectionView.center = CGPointMake(512, 125);
                         }
                         completion:nil];
    } else {
        [UIView animateWithDuration:0.3 delay: 0.0 options: UIViewAnimationCurveEaseIn
                         animations:^{
                             self.ConnectionView.center = CGPointMake(512, -125);
                         }
                         completion:nil];
    }
    isConnectionViewVisible = !isConnectionViewVisible;
}

// Allows the keyboard to do different actions on 'return' pressed
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.UserNameTextField) {
        [self.PasswordTextField becomeFirstResponder];
    } else if(textField == self.PasswordTextField) {
        [textField resignFirstResponder];
        [self toggleConnectionView];
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
