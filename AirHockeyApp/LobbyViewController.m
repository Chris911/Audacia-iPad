//
//  LobbyViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-22.
//
//

#import "LobbyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JoystickViewController.h"
#import "Session.h"

@interface LobbyViewController ()
{
    NSString* leftCamp;
    NSString* rightCamp;
    int activeObjectTag;
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
        leftCamp = @"Gauche";
        rightCamp = @"Droite";
        activeObjectTag = -1;
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
    [self.backgroundView.layer setCornerRadius:20.0f];
    [self.backgroundView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.backgroundView.layer setBorderWidth:1.5f];
    [self.backgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.backgroundView.layer setShadowOpacity:0.8];
    [self.backgroundView.layer setShadowRadius:3.0];
    [self.backgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
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
    
    [self.hiddenView setHidden:YES];
    [self resetGameInfos];
}

- (void) resetGameInfos
{
    self.leftProfilePic.image = [UIImage imageNamed:@"anonymous-icon.jpg"];
    self.rightProfilePic.image = [UIImage imageNamed:@"anonymous-icon.jpg"];
    self.leftCampLabel.text = @"Red Team";
    self.rightCampLabel.text = @"Blue Team";
    [self.hiddenLeftView setHidden:YES];
    [self.hiddenRightView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundView release];
    [_selectionView release];
    [_leftProfilePic release];
    [_hiddenView release];
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
    [self setBackgroundView:nil];
    [self setSelectionView:nil];
    [self setLeftProfilePic:nil];
    [self setHiddenView:nil];
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

- (IBAction)gameInProgressPressed:(id)sender
{
    [self showCampSelectionView];
}

- (IBAction)cancelPressed:(id)sender
{
    [self hideCampSelectionView];
}

- (IBAction)connectPressed:(id)sender
{
    [self presentJoystick];
}

#pragma mark - Animation Methods
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
                         [self.hiddenView setHidden:NO];
                         [self.connectButton setEnabled:NO];
                     }
                     completion:nil];
}

- (void) hideCampSelectionView
{
    [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                     animations:^{
                         self.selectionView.alpha = 0.0f;
                         [self.hiddenView setHidden:YES];
                         [self.connectButton setEnabled:NO];
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             [self resetGameInfos];
                         }}];
}

#pragma mark - Touches methods

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in touches){
        [self handleFirstTouchOnView:touch.view];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

// Detect the touched view by its tag
- (void) handleFirstTouchOnView:(UIView*) view
{
    if(view.tag > 0) {
        activeObjectTag = view.tag;
    } else {
        NSLog(@"Invalid Tag");
    }
    [self dispatchFirstTouch];
}

// Action on touched view
- (void) dispatchFirstTouch
{
    if(activeObjectTag == HIDDEN_VIEW_TAG){
        [self hideCampSelectionView];
    } else if(activeObjectTag == LEFT_CAMP_VIEW_TAG){
        [self.connectButton setEnabled:YES];
        [Session getInstance].Camp = leftCamp;
        self.leftCampLabel.text = [Session getInstance].username;
        self.leftProfilePic.image = [UIImage imageNamed:@"checkmark.png"];
        [self.hiddenRightView setHidden:NO];
    
    } else if(activeObjectTag == RIGHT_CAMP_VIEW_TAG){
        [self.connectButton setEnabled:YES];
        [Session getInstance].Camp = rightCamp;
        self.rightCampLabel.text = [Session getInstance].username;
        self.rightProfilePic.image = [UIImage imageNamed:@"checkmark.png"];
        [self.hiddenLeftView setHidden:NO];
    }
    
    activeObjectTag = -1;
}
@end
