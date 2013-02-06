//
//  MapsViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-06.
//
//
#import "AppDemoAppDelegate.h"
#import "Map.h" 
#import "MapContainer.h"    
#import "WebClient.h"   
#import "MapsViewController.h"
#import "NetworkUtils.h"    

@interface MapsViewController ()

@end

@implementation MapsViewController

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
    [_ScrollView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
- (IBAction)fetchPressed:(id)sender {
    [self load];
}

- (IBAction)returnPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void) addMapsToView
{
    int y = 20;
    for(Map* m in [MapContainer getInstance].maps){
        UIImageView *iview = [[UIImageView alloc]
                              initWithFrame:CGRectMake(300, y, 400, 300)];
        [iview setImage:m.image];
        iview.opaque = YES;
        [self.ScrollView addSubview:iview];
        [iview release];
        
        y += 320;
    }
}

- (void) load
{
    NSArray *viewsToRemove = [self.ScrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    if([NetworkUtils isNetworkAvailable]){
        // Start the maps fetching on a background thread
        [self performSelectorInBackground:@selector(loadNewMaps) withObject:nil];
        [delegate.webClient fetchAllMapsFromDatabase];
        
    } else { // Internet not connected, display error
        //self.mapsTextView.text = @"Vous n'etes pas connecte a Internet!";
    }
}

- (void) loadNewMaps
{
    // While a new maps array isn't ready in the MapContainer, block the background thread.
    while (![MapContainer getInstance].isMapsInfosLoaded) {}
    
    [self performSelectorOnMainThread:@selector(fetchAllImages) withObject:nil waitUntilDone:YES];
    while(![MapContainer  allMapImagesLoaded]){}
    
    [self performSelectorOnMainThread:@selector(mapsDataFetchingDone) withObject:nil waitUntilDone:YES];
}

- (void)mapsDataFetchingDone
{
    // Safety check on the maps loaded attribute
    if ([MapContainer getInstance].isMapsInfosLoaded){
        [self addMapsToView];
    }
    
    // Reset to NO so we can load a new map array when the user switches views.
    [MapContainer getInstance].maps = nil;
    [MapContainer getInstance].isMapsInfosLoaded = NO;
}

- (void) fetchAllImages
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    for(Map* m in [MapContainer getInstance].maps){
        [delegate.webClient fetchMapImageWithName:m];
    }
}

@end
