//
//  BetaViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-14.
//
//

#import "BetaViewController.h"
#import "AppDemoAppDelegate.h"
#import "MenuViewController.h"

@interface BetaViewController ()

@end

@implementation BetaViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
