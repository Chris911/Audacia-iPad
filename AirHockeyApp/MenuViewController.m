//
//  MenuViewController.m
//  AppDemo
//

#import "MenuViewController.h"
#import "EAGLViewController.h"
#import "AppDemoAppDelegate.h"
#import "BetaViewController.h"

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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)afficherVueAnimee
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate afficherVueAnimee];
}

- (IBAction)testCaseButtonPressed:(id)sender
{
    BetaViewController* beta_vc = [[[BetaViewController alloc]init]autorelease];
    beta_vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentModalViewController:beta_vc animated:YES];
}

- (void)dealloc {
    [super dealloc];
}
@end
