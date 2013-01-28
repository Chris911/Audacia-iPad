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
        AFGDataXMLRequestOperation *operation = [AFGDataXMLRequestOperation XMLDocumentRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://legalindexes.indoff.com/sitemap.xml"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *XMLDocument) {
            NSLog(@"XMLDocument: %@", XMLDocument);
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *XMLDocument) {
            NSLog(@"Failure! :%@",response);
        }];
        // Just start the operation on a background thread
        [operation start];
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [_downloadSelectedMap release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDownloadSelectedMap:nil];
    [super viewDidUnload];
}
- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)testUpload:(id)sender
{
    //WebClient* webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
    //[webClient uploadImageData:@"Test"]
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
