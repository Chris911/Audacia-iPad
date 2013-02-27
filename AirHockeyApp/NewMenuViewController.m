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
#import "TwitterInterface.h"
#import "NetworkUtils.h"

@interface NewMenuViewController()
{
    BOOL isConnectionViewVisible;
    BOOL isSoundEnabled;
    BOOL isFeedActive;
    
    int tweetIndex;
    NSTimer* twitterTimer;
    
    EAGLViewController *eagl;
}
@property (nonatomic, retain) NSArray* tweets;

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
    
    [self.twitterBackgroundView.layer setCornerRadius:15.0f];
    [self.twitterBackgroundView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.twitterBackgroundView.layer setBorderWidth:2.5f];
    [self.twitterBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.twitterBackgroundView.layer setShadowOpacity:0.8];
    [self.twitterBackgroundView.layer setShadowRadius:1.0];
    [self.twitterBackgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    // Sound is disabled on load
    isSoundEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start twitter fetching 
    if([NetworkUtils isNetworkAvailable]){
        tweetIndex = 0;
        isFeedActive = YES;
        [self fetchTweets];
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
    [twitterTimer invalidate];
    eagl = [[EAGLViewController alloc]initWithNibName:@"EAGLViewController" bundle:nil];
    eagl.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:eagl animated:YES];
}

- (IBAction)profileModePressed:(id)sender
{
    [twitterTimer invalidate];
    ProfileViewController* profile_vc = [[[ProfileViewController alloc]init]autorelease];
    profile_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:profile_vc animated:YES];
}

- (IBAction)controlerModePressed:(id)sender
{
    [twitterTimer invalidate];
    LobbyViewController* lobby_vc = [[[LobbyViewController alloc]init]autorelease];
    lobby_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:lobby_vc animated:YES];
}

- (IBAction)mapviewerModePressed:(id)sender
{
    [twitterTimer invalidate];
    CarouselTestView* carousel_vc = [[[CarouselTestView alloc]init]autorelease];
    carousel_vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:carousel_vc animated:YES];
}

- (IBAction)logoutPressed:(id)sender
{
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
    } else {
        [AudioInterface stopBackgroundMusic];
    }
}

#pragma mark - Twitter actions
- (void) fetchTweets
{
    self.tweets = [TwitterInterface fetchTweets];
    if(self.tweets == nil){
        NSLog(@"Error loading Tweets occured");
    } else {
        twitterTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                  target:self
                                                selector:@selector(displayActiveTweet)
                                                userInfo:nil
                                                 repeats:YES];
        [twitterTimer fire];
    }
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
            NSLog(@"%@",exception);
            twitterString = [tweet objectForKey:@"text"];
        }
        
        // Animation
        [UIView animateWithDuration:0.6 delay: 0.0 options: UIViewAnimationCurveLinear
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

- (void) animateTweetLabel
{
    while(YES){
        [self performSelectorOnMainThread:@selector(displaTwitterLabelNewPosition) withObject:nil waitUntilDone:NO];
        [NSThread sleepForTimeInterval:0.05];
    }
}

- (void) postTweet
{
//    if ([TWTweetComposeViewController canSendTweet]) {
//        TWTweetComposeViewController *tweetSheet =
//        [[TWTweetComposeViewController alloc] init];
//        [tweetSheet setInitialText:
//         @"Tweeting from iOS 5 By Tutorials! :)"];
//	    [self presentModalViewController:tweetSheet animated:YES];
//        
//    } else {
//        UIAlertView *alertView = [[UIAlertView alloc]
//                                  initWithTitle:@"Sorry"
//                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
//                                  delegate:self
//                                  cancelButtonTitle:@"OK"
//                                  otherButtonTitles:nil];
//        [alertView show];
//    }
}
- (void)dealloc {
    [self.tweets release];
    [_twitterLabel release];
    [_twitterBackgroundView release];
    [_twitterLabel2 release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTwitterLabel:nil];
    [self setTwitterBackgroundView:nil];
    [self setTwitterLabel2:nil];
    [super viewDidUnload];
}
@end
