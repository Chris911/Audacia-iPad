//
//  LobbyViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-22.
//  View used as a portal to pick your side in a
//  currently active game, retrived from the server
//  Transitions to the joystick view
//

#import "LobbyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JoystickViewController.h"
#import "Session.h"


@interface LobbyViewController ()
{
    int activeObjectTag;
    BOOL sideSelected;
}

@end

const int SELECTION_VIEW_TAG        = 100;
const int RIGHT_CAMP_VIEW_TAG       = 200;
const int LEFT_CAMP_VIEW_TAG        = 300;
const int HIDDEN_VIEW_TAG           = 400;

@implementation LobbyViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        activeObjectTag = -1;
        sideSelected = NO;
    }
    return self;
}

#pragma mark - lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self resetAllViews];
}

- (void) resetAllViews
{
    
    [self.selectionView.layer setCornerRadius:20.0f];
    [self.selectionView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.selectionView.layer setBorderWidth:1.5f];
    [self.selectionView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.selectionView.layer setShadowOpacity:0.8];
    [self.selectionView.layer setShadowRadius:3.0];
    [self.selectionView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.leftCampView.layer setBorderWidth:1.5f];
    [self.leftCampView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.leftCampView.layer setShadowOpacity:0.8];
    [self.leftCampView.layer setShadowRadius:3.0];
    [self.leftCampView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.rightCampView.layer setBorderWidth:1.5f];
    [self.rightCampView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.rightCampView.layer setShadowOpacity:0.8];
    [self.rightCampView.layer setShadowRadius:3.0];
    [self.rightCampView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.selectionView.alpha = 0.0f;
    
    [self resetGameInfos];
    
    // Assign camp
    [self selectCamp:[Session getInstance].Camp];
    
    // Launch the camp selection view
    [self showCampSelectionView];

}

// Replace various view and labels and images related to the selection view (with game infos)
- (void) resetGameInfos
{
    self.leftProfilePic.image = [UIImage imageNamed:@"anonymous-icon.jpg"];
    self.rightProfilePic.image = [UIImage imageNamed:@"anonymous-icon.jpg"];
    self.leftCampLabel.text = @"Red Team";
    self.rightCampLabel.text = @"Blue Team";
    [self.hiddenLeftView setHidden:YES];
    [self.hiddenRightView setHidden:YES];
    sideSelected = NO;
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

- (void)dealloc {
    [_selectionView release];
    [_leftProfilePic release];
    [_rightCampView release];
    [_leftCampView release];
    [_rightProfilePic release];
    [_rightCampLabel release];
    [_leftCampLabel release];
    [_connectButton release];
    [_hiddenRightView release];
    [_hiddenLeftView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setSelectionView:nil];
    [self setLeftProfilePic:nil];
    [self setRightCampView:nil];
    [self setLeftCampView:nil];
    [self setRightProfilePic:nil];
    [self setRightCampLabel:nil];
    [self setLeftCampLabel:nil];
    [self setConnectButton:nil];
    [self setHiddenRightView:nil];
    [self setHiddenLeftView:nil];
    [super viewDidUnload];
}

#pragma mark - Button methods
- (IBAction)backPressed:(id)sender
{
    [self resetAllViews];
    [self dismissModalViewControllerAnimated:YES];
}

// Connect (final step to transition to the joystick)
- (IBAction)connectPressed:(id)sender
{
    [self presentJoystick];
}

#pragma mark - Animation Methods

// Transition to the joystick view
- (void) presentJoystick
{
    JoystickViewController* joystic_vc = [[[JoystickViewController alloc]init]autorelease];
    joystic_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self resetAllViews];
    [self presentModalViewController:joystic_vc animated:YES];
}

- (void) showCampSelectionView
{
    [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.selectionView.alpha = 1.0f;
                     }
                     completion:nil];
}

- (void) hideCampSelectionView
{
    [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.selectionView.alpha = 0.0f;
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             [self resetGameInfos];
                         }}];
}

- (void) selectCamp:(NSString*)camp
{
    if([camp isEqualToString:leftCamp]){
        self.leftCampLabel.text = [Session getInstance].username;
        self.leftProfilePic.image = [UIImage imageNamed:@"checkmark.png"];
        [self.hiddenRightView setHidden:NO];
    }
    else if([camp isEqualToString:rightCamp]){
        self.rightCampLabel.text = [Session getInstance].username;
        self.rightProfilePic.image = [UIImage imageNamed:@"checkmark.png"];
        [self.hiddenLeftView setHidden:NO];
    } else {
        NSLog(@"Error assigning camp");
    }
}

@end
