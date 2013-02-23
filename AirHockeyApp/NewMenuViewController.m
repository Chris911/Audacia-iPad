//
//  NewMenuViewController.m
//  AirHockeyApp
//
//  Created by Chris on 13-02-13.
//
//

#import "NewMenuViewController.h"
#import "EAGLViewController.h"
#import "AppDemoAppDelegate.h"
#import "CarouselTestView.h"
#import "Session.h"
#import "AudioInterface.h"
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "JoystickViewController.h"
#import "LobbyViewController.h" 

@interface NewMenuViewController()
{
    BOOL isConnectionViewVisible;
    BOOL isSoundEnabled;
    
    EAGLViewController *eagl;
}
@end

@implementation NewMenuViewController

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Sound is disabled on load
    isSoundEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
        
    // Setup and start sounds
    [AudioInterface loadSounds];
    if(isSoundEnabled){
        [AudioInterface startBackgroundMusic];
    }
    
    // Clear the map container if any and the EAGLView
    [MapContainer removeMapsInContainers];
    
    if(eagl.isViewLoaded){
        [eagl release];
        eagl = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Button pressed methods
- (IBAction)editionModePressed:(id)sender
{
    eagl = [[EAGLViewController alloc]initWithNibName:@"EAGLViewController" bundle:nil];
    eagl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:eagl animated:YES];
}

- (IBAction)profileModePressed:(id)sender
{
    ProfileViewController* profile_vc = [[[ProfileViewController alloc]init]autorelease];
    profile_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:profile_vc animated:YES];
}

- (IBAction)controlerModePressed:(id)sender
{
    LobbyViewController* lobby_vc = [[[LobbyViewController alloc]init]autorelease];
    lobby_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:lobby_vc animated:YES];
}

- (IBAction)mapviewerModePressed:(id)sender
{
    CarouselTestView* carousel_vc = [[[CarouselTestView alloc]init]autorelease];
    carousel_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:carousel_vc animated:YES];
}

- (IBAction)logoutPressed:(id)sender
{
    [Session resetSession];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)soundPressed:(id)sender
{
    isSoundEnabled = !isSoundEnabled;
    if(isSoundEnabled){
        [AudioInterface startBackgroundMusic];
    } else {
        [AudioInterface stopBackgroundMusic];
    }
}
@end
