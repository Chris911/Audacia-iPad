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
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundView:nil];
    [self setUsernameLabel:nil];
    [super viewDidUnload];
}
- (IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
