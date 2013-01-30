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
#import "NetworkUtils.h"
#import "AFGDataXMLRequestOperation.h"

@interface BetaViewController ()

@end

@implementation BetaViewController

@synthesize mapsTextView;

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
    
//    if([NetworkUtils isNetworkAvailable]){
//        AFGDataXMLRequestOperation *operation = [AFGDataXMLRequestOperation XMLDocumentRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://legalindexes.indoff.com/sitemap.xml"]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *XMLDocument) {
//            NSLog(@"XMLDocument: %@", XMLDocument);
//            
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *XMLDocument) {
//            NSLog(@"Failure! :%@",response);
//        }];
//        // Just start the operation on a background thread
//        [operation start];
//    } 
}

// No keyboard
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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
    [mapsTextView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDownloadSelectedMap:nil];
    [self setMapsTextView:nil];
    [super viewDidUnload];
}
- (IBAction)goBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)testUpload:(id)sender
{
    WebClient* webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
    [webClient fetchAllMapsFromDatabase];
}

- (void)mapsDataFetchingDone:(NSMutableArray*)allMaps
{
    for(MapContainer *map in allMaps) {
        NSString *mapIdString = [NSString stringWithFormat:@"Id: @%i",map.mapId];
        [mapsTextView setText:[mapsTextView.text stringByAppendingString:mapIdString]];
        
        [mapsTextView setText:[mapsTextView.text stringByAppendingString:map.name]];
    }
}

@end
