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
#import "TwitterInterface.h"
#import "NetworkUtils.h"
#import "SocketUtil.h"
#import "AudioSampler.h"

#define notLoggedInErrorTag 0

@interface NewMenuViewController()
{
    BOOL isConnectionViewVisible;
    BOOL isSoundEnabled;
    BOOL isFeedActive;
    
    int tweetIndex;
    int tweetCount;
    NSTimer* fetchTimer;
    NSTimer* twitterTimer;
    
    EAGLViewController *eagl;
}
@property (nonatomic, retain) NSArray* tweets;

@end

@implementation NewMenuViewController

@synthesize loginButton;

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
    self.soundButton.selected = YES;
    
    //Add observer for Connected to game server event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(successConnectingToGameServer)
                                                 name:@"ConnectedToGameServer"
                                               object:nil];
    
    //Add observer for Game server Connexion error
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(failureConnectingToGameServer)
                                                 name:@"FailConnectedToGameServer"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareAdditionalView];
    
    //[AudioSampler extract];
    
    // Start twitter fetching  that will occur every 15 seconds
    if([NetworkUtils isNetworkAvailable]){
        tweetIndex = 0;
        tweetCount = 0;
        isFeedActive = YES;
        fetchTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                        target:self
                                                      selector:@selector(fetchTweets)
                                                      userInfo:nil
                                                       repeats:YES];
        [fetchTimer fire];
    } else {
        [self.twitterBackgroundView setHidden:YES];
    }
    
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
    
    // Set login button text according to session state
    if([Session getInstance].isAuthenticated)
    {
        [loginButton setImage:[UIImage imageNamed:@"icon-logout"] forState:UIControlStateNormal];
    } else {
        [loginButton setImage:[UIImage imageNamed:@"icon-login.png"] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"At NewMenuView");
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
    [self flushTimers];
    eagl = [[EAGLViewController alloc]initWithNibName:@"EAGLViewController" bundle:nil];
    eagl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:eagl animated:YES];
}

- (IBAction)profileModePressed:(id)sender
{
    if([Session getInstance].isAuthenticated)
    {
        [self flushTimers];
        ProfileViewController* profile_vc = [[[ProfileViewController alloc]init]autorelease];
        profile_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:profile_vc animated:YES];
    }
    else
    {
        [self showNotLoggedInError];
    }
}

- (IBAction)controlerModePressed:(id)sender
{
    // Attempt to connect to server
    [self  connectToGameSever];
    
    // Pop controller view in
    [self slideControllerViewIn];
}

- (IBAction)mapviewerModePressed:(id)sender
{
    [self flushTimers];
    CarouselTestView* carousel_vc = [[[CarouselTestView alloc]init]autorelease];
    carousel_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:carousel_vc animated:YES];
}

- (IBAction)logoutPressed:(id)sender
{
    if([[SocketUtil getInstance].tcpSocket isConnected]){
        [[SocketUtil getInstance].tcpSocket disconnect];
    }
    [Session resetSession];
    isFeedActive = NO;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)soundPressed:(id)sender
{
    isSoundEnabled = !isSoundEnabled;
    if(isSoundEnabled){
        [AudioInterface startBackgroundMusic];
        self.soundButton.selected = NO;
    } else {
        [AudioInterface stopBackgroundMusic];
        self.soundButton.selected = YES;
    }
}

- (IBAction)joystickButtonPressed:(id)sender
{
    if([Session getInstance].isAuthenticated)
    {
        [self flushTimers];
        JoystickViewController* joystick_vc = [[[JoystickViewController alloc]init]autorelease];
        joystick_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:joystick_vc animated:YES];
    }
    else
    {
        [self showNotLoggedInError];
    }
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self slideControllerViewOut];
}

#pragma mark - Twitter actions
- (void) fetchTweets
{
    NSArray* tempTweets = [TwitterInterface fetchTweets];
    if(tempTweets != nil){
        self.tweets = tempTweets;
        [self.twitterBackgroundView setHidden:NO];
    } else {
        //[self.twitterBackgroundView setHidden:YES];
    }
    
    // Check if new tweets
    if(tweetCount != [self.tweets count]){
        if(self.tweets == nil){
            NSLog(@"Error loading Tweets occured");
        } else {
            [twitterTimer invalidate];
            tweetCount = [self.tweets count];
            twitterTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                      target:self
                                                    selector:@selector(displayActiveTweet)
                                                    userInfo:nil
                                                     repeats:YES];
            [twitterTimer fire];
        }
    }
    
}


- (void)showNotLoggedInError
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Login Error"
                                                      message:@"This feature is only available to registered users"
                                                     delegate:self
                                            cancelButtonTitle:@"Dismiss"
                                            otherButtonTitles:nil];
    [message setAlertViewStyle:UIAlertViewStyleDefault];
    message.tag = notLoggedInErrorTag;
    [message show];
    [message release];
}

// Each X seconds, a new tweet will be displayed with a crossfade animation
- (void) displayActiveTweet
{
    if(isFeedActive){
        NSDictionary *tweet = self.tweets[tweetIndex];
        NSString* twitterString = @"";
        NSString *text = [tweet objectForKey:@"text"];
        NSDictionary *user = [tweet objectForKey:@"user"];
        NSString* name = [user objectForKey:@"screen_name"];
        
        // remove http tag
        NSRange rangeOfSubstring = [text rangeOfString:@"http"];
        
        if(rangeOfSubstring.location == NSNotFound){
            name = @"";
        }
        
        // Try to remove the substring, if it fails, just post the plain tag
        @try {
            text = [text substringToIndex:rangeOfSubstring.location];
            text = [text stringByAppendingString:@" @"];
            text = [text stringByAppendingString:name];
            twitterString = [twitterString stringByAppendingString:text];
        }
        @catch (NSException *exception) {
            twitterString = [tweet objectForKey:@"text"];
        }
        
        // Animation
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveLinear
                         animations:^{
                             if(self.twitterLabel.alpha == 1){
                                 self.twitterLabel.alpha = 0.0f;
                                 self.twitterLabel2.alpha = 1.0f;
                                 self.twitterLabel2.text = twitterString;
                             } else {
                                 self.twitterLabel.alpha = 1.0f;
                                 self.twitterLabel2.alpha = 0.0f;
                                 self.twitterLabel.text = twitterString;
                             }
                         }
                         completion:nil
         ];
        
        // Switch to next index
        tweetIndex = (tweetIndex + 1)%([self.tweets count]);
    }
}

#pragma UI preparation methods
- (void) prepareAdditionalView
{
    self.infoTextView.backgroundColor = [UIColor clearColor];
    [self.joystickButton setEnabled:NO];

    [self.controllerViewBackgroundImage.layer setMasksToBounds:YES];
    [self.controllerViewBackgroundImage.layer setCornerRadius:20.0f];

    [self.controllerView.layer setCornerRadius:20.0f];
    [self.controllerView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.controllerView.layer setBorderWidth:1.5f];
    [self.controllerView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.controllerView.layer setShadowOpacity:0.8];
    [self.controllerView.layer setShadowRadius:3.0];
    [self.controllerView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.controllerView.center = CGPointMake(1024 + self.controllerView.frame.size.width/2, 384);
    
    if(![[SocketUtil getInstance].tcpSocket isConnected]){
        [self.spinner startAnimating];
        self.connexionStatusLabel.text = @"Connecting to server...";
        [self.joystickButton setEnabled:NO];
    } else {
        [self.spinner stopAnimating];
        self.connexionStatusLabel.text = @"Connexion established!";
        [self.joystickButton setEnabled:YES];
    }
}

#pragma mark - Animation methods
- (void) animateTweetLabel
{
    while(YES){
        [self performSelectorOnMainThread:@selector(displaTwitterLabelNewPosition) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:0.05];
    }
}

- (void) slideControllerViewIn
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.controllerView.center = CGPointMake(512, 384);
                     }];
}

- (void) slideControllerViewOut
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.controllerView.center = CGPointMake(1024 + self.controllerView.frame.size.width/2, 384);
                     }];
}

#pragma mark - Socket methods
- (void) connectToGameSever
{
    // Connect to the game server
    if(![[SocketUtil getInstance].tcpSocket isConnected]){
        [[SocketUtil getInstance] connectToServer];
    }
}

- (void) successConnectingToGameServer
{
    [self.spinner stopAnimating];
    self.connexionStatusLabel.text = @"Connexion established!";
    [self.joystickButton setEnabled:YES];
}

- (void) failureConnectingToGameServer
{
    [self.spinner stopAnimating];
    self.connexionStatusLabel.text = @"Connexion error";
}


#pragma mark - Deallocation methods
- (void) flushTimers
{
    [fetchTimer invalidate];
    [twitterTimer invalidate];
    twitterTimer = nil;
    fetchTimer = nil;
    //[self.tweets release];
    //self.tweets = nil;
}

- (void)dealloc {
    //[self.tweets release];
    [_twitterLabel release];
    [_twitterBackgroundView release];
    [_twitterLabel2 release];
    [loginButton release];
    [_controllerView release];
    [_infoTextView release];
    [_connexionStatusLabel release];
    [_joystickButton release];
    [_controllerViewBackgroundImage release];
    [_spinner release];
    [_soundButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTwitterLabel:nil];
    [self setTwitterBackgroundView:nil];
    [self setTwitterLabel2:nil];
    [self setLoginButton:nil];
    [self setControllerView:nil];
    [self setInfoTextView:nil];
    [self setConnexionStatusLabel:nil];
    [self setJoystickButton:nil];
    [self setControllerViewBackgroundImage:nil];
    [self setSpinner:nil];
    [self setSoundButton:nil];
    [super viewDidUnload];
}

@end
