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

#import "XMLUtil.h"
#import "Scene.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "AFGDataXMLRequestOperation.h"

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
    
    if([self isNetworkAvailable]){
    
    //[XMLUtil savePartyWithFileName:[Scene getInstance].renderingTree :@"test"];
    //RenderingTree* newTestTree = [XMLUtil loadRenderingTreeFromFileName:@"test"];
    
    AFGDataXMLRequestOperation *operation = [AFGDataXMLRequestOperation XMLDocumentRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://legalindexes.indoff.com/sitemap.xml"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *XMLDocument) {
        NSLog(@"XMLDocument: %@", XMLDocument);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *XMLDocument) {
        NSLog(@"Failure!");
    }];
    // Just start the operation on a background thread
    [operation start];
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

- (BOOL)isNetworkAvailable
{
    BOOL available = NO;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"NOT Connected to internet");
    } else {
        available = YES;
        NSLog(@"Connected to internet");
    }
    return available;
}

@end
