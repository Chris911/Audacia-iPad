//
//  ProfileViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-20.
//
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Session.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    
    [self.backgroundView.layer setCornerRadius:20.0f];
    [self.backgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.backgroundView.layer setBorderWidth:2.5f];
    [self.backgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.backgroundView.layer setShadowOpacity:0.8];
    [self.backgroundView.layer setShadowRadius:3.0];
    [self.backgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.picBackgroundView.layer setCornerRadius:20.0f];
    [self.picBackgroundView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.picBackgroundView.layer setBorderWidth:1.5f];
    [self.picBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.picBackgroundView.layer setShadowOpacity:0.8];
    [self.picBackgroundView.layer setShadowRadius:3.0];
    [self.picBackgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.statsView.layer setCornerRadius:20.0f];
    [self.statsView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.statsView.layer setBorderWidth:1.5f];
    [self.statsView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.statsView.layer setShadowOpacity:0.8];
    [self.statsView.layer setShadowRadius:3.0];
    [self.statsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.usernameLabel.text = [Session getInstance].username;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundView release];
    [_usernameLabel release];
    [_picBackgroundView release];
    [_pictureImageView release];
    [_statsView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundView:nil];
    [self setUsernameLabel:nil];
    [self setPicBackgroundView:nil];
    [self setPictureImageView:nil];
    [self setStatsView:nil];
    [super viewDidUnload];
}
- (IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
