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

#import "Map.h"
#import "XMLUtil.h"
#import "Scene.h"
#import "AFNetworking.h"
#import "NetworkUtils.h"
#import "MapContainer.h"    
#import "AFGDataXMLRequestOperation.h"

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
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchesBegan:withEvent:");
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self dismissModalViewControllerAnimated:YES];
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
    [_loadingIndicator release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDownloadSelectedMap:nil];
    [self setMapsTextView:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}
- (IBAction)goBack:(id)sender
{
    [MapContainer removeMapsInContainers];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)testUpload:(id)sender
{
    [self load];
}

- (void) load
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    if([NetworkUtils isNetworkAvailable]){
        
        // Start the maps fetching on a background thread
        [self.loadingIndicator startAnimating];
        [self performSelectorInBackground:@selector(loadNewMaps) withObject:nil];
        [delegate.webClient fetchAllMapsFromDatabase];
        
    } else { // Internet not connected, display error
        self.mapsTextView.text = @"Vous n'etes pas connecte a Internet!";
    }
}

- (void) loadNewMaps
{
    // While a new maps array isn't ready in the MapContainer, block the background thread.
    while (![MapContainer getInstance].isMapsInfosLoaded) {
        
    }
    // Stop the spinner
    [self.loadingIndicator stopAnimating];
    
    // Relaunch the UI modification on the main thread OR IT WILL CRASH (iOS specific, can't modify
    // the UI on a background thread)
    [self performSelectorOnMainThread:@selector(mapsDataFetchingDone) withObject:nil waitUntilDone:NO];
}

- (void)mapsDataFetchingDone
{
    // Safety check on the maps loaded attribute
    if ([MapContainer getInstance].isMapsInfosLoaded){
        [mapsTextView setText:@""];
        for(Map *map in [MapContainer getInstance].maps) {
            NSString *mapIdString = [NSString stringWithFormat:@"Id: %i",map.mapId];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:mapIdString]];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:@"\n"]];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:map.name]];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:@" Rating : "]];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:[NSString stringWithFormat:@"%d", map.rating]]];
            [mapsTextView setText:[mapsTextView.text stringByAppendingString:@"\n\n"]];
        }
        
        // Reset to NO so we can load a new map array when the user switches views.
        [MapContainer getInstance].isMapsInfosLoaded = NO;
        [MapContainer removeMapsInContainers];
    }
}

@end
