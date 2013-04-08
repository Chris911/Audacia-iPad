//
//  CreditsViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-04-02.
//
//  Gotta give credits where it's due

#import "CreditsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDemoAppDelegate.h"
#import "WebClient.h"
#import "NetworkUtils.h"

@interface CreditsViewController ()

@end

@implementation CreditsViewController

@synthesize totalGames;
@synthesize totalGoals;
@synthesize statsAreSet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareViews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self rollCredits];
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
    [_textView release];
    [_creditView release];
    [_placeHolderView release];
    [_placeHolderImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setCreditView:nil];
    [self setPlaceHolderView:nil];
    [self setPlaceHolderImageView:nil];
    [super viewDidUnload];
}

- (IBAction)backPressed:(id)sender
{
    self.textView.alpha = 0.0f;
    [self dismissModalViewControllerAnimated:YES];
}

- (void) prepareViews
{
    if(!self.statsAreSet)
    {
        self.totalGames = @"Total Games Played:";
        self.totalGoals = @"Total Goals Scored:";
        if([NetworkUtils isNetworkAvailable])
        [self getGlobalStats];
    }
    
    self.textView.backgroundColor = [UIColor clearColor];

    [self.creditView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.creditView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.creditView.layer setShadowOpacity:0.8];
    [self.creditView.layer setShadowRadius:15.0];
    [self.creditView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.placeHolderView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.placeHolderView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [self.placeHolderView.layer setShadowOpacity:0.8];
    [self.placeHolderView.layer setShadowRadius:20.0];
    [self.placeHolderView.layer setShadowOffset:CGSizeMake(3.0, 3.0)];
    
    NSString *text = @"";
    
    text = [text stringByAppendingString:@"- iOS Developers \n"];
    text = [text stringByAppendingString:@"-------------------------------------\n"];
    text = [text stringByAppendingString:@"\tSamuel Des Rochers\n"];
    text = [text stringByAppendingString:@"\tChristophe Naud-Dulude\n\n"];
    
    text = [text stringByAppendingString:@"- Lead Designer \n"];
    text = [text stringByAppendingString:@"-------------------------------------\n"];
    text = [text stringByAppendingString:@"\tChristophe Naud-Dulude\n\n"];
    
    text = [text stringByAppendingString:@"- Project Manager \n"];
    text = [text stringByAppendingString:@"-------------------------------------\n"];
    text = [text stringByAppendingString:@"\tSamuel Des Rochers\n\n"];
    
    text = [text stringByAppendingString:@"\n"];
    
    text = [text stringByAppendingString:@"- Librairies used for AirHockey App  \n"];
    text = [text stringByAppendingString:@"-------------------------------------\n"];
    text = [text stringByAppendingString:@"\tCocos Denshion  \t: Audio API\n"];
    text = [text stringByAppendingString:@"\tiCarousel       \t\t\t: Maps Viewer\n"];
    text = [text stringByAppendingString:@"\tAFNetworking    \t\t\t: Network API\n"];
    text = [text stringByAppendingString:@"\tGDataXMLNode    \t: XML serializer\n"];
    text = [text stringByAppendingString:@"\tOpenGLWaveFront \t: Graphics\n"];

    text = [text stringByAppendingString:@"\n"];
    
    text = [text stringByAppendingString:@"- Global Stats \n"];
    text = [text stringByAppendingString:@"-------------------------------------\n\t"];
    text = [text stringByAppendingString:self.totalGames];
    text = [text stringByAppendingString:@"\n\t"];
    text = [text stringByAppendingString:self.totalGoals];
    
    text = [text stringByAppendingString:@"\n\n"];
    
    text = [text stringByAppendingString:@"Server provided by Polytechnique Montreal\n\n"];
    text = [text stringByAppendingString:@"Music by artist 'Flex Vector'\n\n"];
    
    text = [text stringByAppendingString:@"\n"];

    self.textView.text = text;
}

- (void) rollCredits
{
    [UIView animateWithDuration:40 delay: 0.0 options: nil
                    animations:^{
                        self.creditView.center = CGPointMake(self.creditView.center.x, -50);
                    }
                     completion:^(BOOL finished){
                         self.textView.alpha = 0.0f;
                         [self dismissModalViewControllerAnimated:YES];
                    }];
}

- (void) getGlobalStats
{
    if(!self.statsAreSet)
    {
        AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        [delegate.webClient fetchGlobalStats:@"stats"
                                onCompletion:^(NSDictionary *JSON)
            {
                NSNumber* totalGamesJson  = [JSON valueForKeyPath:@"TOTAL_GAMES"];
                NSNumber* totalGoalsJson  = [JSON valueForKeyPath:@"TOTAL_GOALS"];
                
                self.totalGames = [NSString stringWithFormat:@"Total Games Played\t: %d",[totalGamesJson intValue]];
                self.totalGoals = [NSString stringWithFormat:@"Total Goals Scored\t: %d",[totalGoalsJson intValue]];
                
                self.statsAreSet = YES;
                [self prepareViews];
            }];
    }
}
@end
