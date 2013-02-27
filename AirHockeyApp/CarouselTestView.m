//
//  CarouselTestView.m
//  AirHockeyApp
//
//  Created by Chris on 13-02-01.
//
//

#import "AppDemoAppDelegate.h"
#import "NetworkUtils.h"   
#import "CarouselTestView.h"
#import "MapContainer.h"
#import "Map.h"
#import "WebClient.h"
#import "EAGLViewController.h"

#define SWITCH_TYPE_SHEET 0
#define EDIT_MAP_SHEET    1

@interface CarouselTestView () <UIActionSheetDelegate>
{
    int currentIndex;
}

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation CarouselTestView

@synthesize carousel;
@synthesize wrap;
@synthesize items;
@synthesize starsImageDict;

- (void)setUp
{
    //set up data
    wrap = YES;
    carousel.type = iCarouselTypeInvertedCylinder;
    self.items = [MapContainer getInstance].maps;
    
    //Initialize dictionnary
    starsImageDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                      @"Stars-1.png",[NSNumber numberWithInt:0],
                      @"Stars-1.png",[NSNumber numberWithInt:1],
                      @"Stars-2.png",[NSNumber numberWithInt:2],
                      @"Stars-3.png",[NSNumber numberWithInt:3],
                      @"Stars-4.png",[NSNumber numberWithInt:4],
                      @"Stars-5.png",[NSNumber numberWithInt:5],
                       nil];
    
    //Add observer for fetch map event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchMapFinished)
                                                 name:@"FetchMapEventFinished"
                                               object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self dismissModalViewControllerAnimated:YES];
    [MapContainer getInstance].maps = nil;
}

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
    [carousel release];
    [items release];
    [starsImageDict release];
    [_loadingIndicator release];
    [_hiddenView release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    carousel.type = iCarouselTypeInvertedCylinder;
}

- (void)viewDidUnload
{
    [self setLoadingIndicator:nil];
    [self setHiddenView:nil];
    [super viewDidUnload];
    self.carousel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)insertItem
{
    NSInteger index = MAX(0, carousel.currentItemIndex);
    [items insertObject:[NSNumber numberWithInt:carousel.numberOfItems] atIndex:index];
    [carousel insertItemAtIndex:index animated:YES];
}

- (IBAction)removeItem
{
    if (carousel.numberOfItems > 0)
    {
        NSInteger index = carousel.currentItemIndex;
        [carousel removeItemAtIndex:index animated:YES];
        [items removeObjectAtIndex:index];
    }
}

#pragma mark -
#pragma mark iCarousel methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [items count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *titleLabel = nil;
    UILabel *authorLabel = nil;
    //UILabel *ratingLabel = nil;
    UIImageView *ratingImageView = nil;
    Map* map = [self.items objectAtIndex:index];

    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 512.0f, 384.0f)] autorelease];
        //view.contentMode = UIViewContentModeScaleAspectFit;
        //view.contentMode = UIViewContentModeCenter;
        CGRect frame = view.frame;
        frame.origin.y += 225;
        titleLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.font = [titleLabel.font fontWithSize:40];
        titleLabel.tag = 1;
        [view addSubview:titleLabel];
        
        frame.origin.y += 35;
        authorLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
        authorLabel.backgroundColor = [UIColor clearColor];
        authorLabel.textAlignment = UITextAlignmentCenter;
        authorLabel.font = [authorLabel.font fontWithSize:20];
        authorLabel.tag = 2;
        [view addSubview:authorLabel];
        
//        frame.origin.y += 30;
//        ratingLabel = [[[UILabel alloc] initWithFrame:frame] autorelease];
//        ratingLabel.backgroundColor = [UIColor clearColor];
//        ratingLabel.textAlignment = UITextAlignmentCenter;
//        ratingLabel.font = [ratingLabel.font fontWithSize:20];
//        ratingLabel.tag = 3;
//        [view addSubview:ratingLabel];
    }
    else
    {
        //get a reference to the label in the recycled view
        titleLabel = (UILabel *)[view viewWithTag:1];
        authorLabel = (UILabel *)[view viewWithTag:2];
        //ratingLabel = (UILabel *)[view viewWithTag:3];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    view.contentMode = UIViewContentModeScaleAspectFit;
    titleLabel.text = map.name;
    authorLabel.text = [NSString stringWithFormat:@"Par: %@", map.authorName];
    //ratingLabel.text = [NSString stringWithFormat:@"Rating: %i/5", map.rating];
    //ratingLabel.text = [starsImageDict objectForKey:[NSNumber numberWithInt:map.rating]];
    
    ratingImageView = [[[UIImageView alloc]initWithFrame:CGRectMake(198.5, 10, 115.0f, 20.0f)] autorelease];
    NSString* imagePath = [starsImageDict objectForKey:[NSNumber numberWithInt:map.rating]];
    ((UIImageView *)ratingImageView).image = [UIImage imageNamed:imagePath];
    [view addSubview:ratingImageView];

    //Assign image to view but first resize image in background thread
    [self useImage:map.image :(UIImageView *)view];
    
    return view;
}

- (NSUInteger)numberOfPlaceholdersInCarousel:(iCarousel *)carousel
{
    //note: placeholder views are only displayed on some carousels if wrapping is disabled
    return 2;
}

- (UIView *)carousel:(iCarousel *)carousel placeholderViewAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil)
    {
        //don't do anything specific to the index within
        //this `if (view == nil) {...}` statement because the view will be
        //recycled and used with other index values later
        view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 600.0f, 600.0f)] autorelease];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        view.contentMode = UIViewContentModeCenter;
        
        label = [[[UILabel alloc] initWithFrame:view.bounds] autorelease];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:50.0f];
        label.tag = 1;
        [view addSubview:label];
    }
    else
    {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = (index == 0)? @"[": @"]";
    
    return view;
}

#pragma mark -
#pragma mark UIActionSheet methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(actionSheet.tag == SWITCH_TYPE_SHEET)
    {
        if (buttonIndex >= 0)
        {
            //map button index to carousel type
            iCarouselType type = buttonIndex;
            
            //carousel can smoothly animate between types
            [UIView beginAnimations:nil context:nil];
            carousel.type = type;
            [UIView commitAnimations];
        }
    } else if (actionSheet.tag == EDIT_MAP_SHEET)
    {
        if (buttonIndex == 0)
        {
            [self.loadingIndicator startAnimating];
            [self.hiddenView setHidden:NO];
            Map* map = [self.items objectAtIndex:currentIndex];
            NSLog(@"[Carousel] Editing map");
            AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
            [delegate.webClient fetchMapXML:map.name];
        }
    }
}

- (void)fetchMapFinished
{
    [self.loadingIndicator stopAnimating];
    [self.hiddenView setHidden:YES];
    
    // remove previous SHIT
    for(int i = self.carousel.numberOfItems; i > 0; i--){
        [self.carousel removeItemAtIndex:i animated:NO];
    }
    
    [MapContainer getInstance].maps = nil;
    [Scene getInstance].loadingCustomTree = YES;
    EAGLViewController* glvc = [[[EAGLViewController alloc]init]autorelease];
    [self presentModalViewController:glvc animated:NO];
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"[Carousel] Selected item at index: %i",index);
    currentIndex = index;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Would you like to edit this map?"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Yes",@"No",nil];
    sheet.tag = EDIT_MAP_SHEET;
    [sheet showInView:self.view];
    [sheet release];
}

- (CATransform3D)carousel:(iCarousel *)_carousel itemTransformForOffset:(CGFloat)offset baseTransform:(CATransform3D)transform
{
    //implement 'flip3D' style carousel
    transform = CATransform3DRotate(transform, M_PI / 8.0f, 0.0f, 1.0f, 0.0f);
    return CATransform3DTranslate(transform, 0.0f, 0.0f, offset * carousel.itemWidth);
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    //customize carousel display
    switch (option)
    {
        case iCarouselOptionWrap:
        {
            //normally you would hard-code this to YES or NO
            return wrap;
        }
        case iCarouselOptionSpacing:
        {
            //add a bit of spacing between the item views
            return value * 1.05f;
        }
        case iCarouselOptionFadeMax:
        {
            if (carousel.type == iCarouselTypeCustom)
            {
                //set opacity based on distance from camera
                return 0.0f;
            }
            return value;
        }
        default:
        {
            return value;
        }
    }
}

- (IBAction)pressedSwitchButton:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Carousel Type"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Linear", @"Rotary", @"Inverted Rotary", @"Cylinder", @"Inverted Cylinder", @"Wheel", @"Inverted Wheel", @"CoverFlow", @"CoverFlow2", @"Time Machine", @"Inverted Time Machine", @"Custom", nil];
    [sheet showInView:self.view];
    sheet.tag = SWITCH_TYPE_SHEET;
    [sheet release];
}

- (IBAction)pressedBack:(id)sender
{    
    // remove previous SHIT
    for(int i = self.carousel.numberOfItems; i > 0; i--){
        [self.carousel removeItemAtIndex:i animated:NO];
    }
    
    [MapContainer getInstance].maps = nil;
    //[[MapContainer getInstance] release];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pressedRefresh:(id)sender {
    [self load];
}

- (void)load
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    
    if([NetworkUtils isNetworkAvailable]){
        [self.loadingIndicator startAnimating];
        [self.hiddenView setHidden:NO];
        //[MapContainer removeMapsInContainers];
        // Start the maps fetching on a background thread
        [self performSelectorInBackground:@selector(loadNewMaps) withObject:nil];
        [delegate.webClient fetchAllMapsFromDatabase];
        
    } else { // Internet not connected, display error
        //self.mapsTextView.text = @"Vous n'etes pas connecte a Internet!";
    }
}

- (void)loadNewMaps
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
        //FIXME : Needs memory checking OR error handling, rapid refresh will crash
        self.items = [MapContainer getInstance].maps;
        
        // remove previous 
        for(int i = self.carousel.numberOfItems; i > 0; i--){
            [self.carousel removeItemAtIndex:i animated:NO];
        }
        
        for(int i = 0; i < [[MapContainer getInstance].maps count]; i++){
            [self.carousel insertItemAtIndex:i animated:NO];
        }
    }
    
    // Reset to NO so we can load a new map array when the user switches views.
    [MapContainer getInstance].maps = nil;
    [MapContainer getInstance].isMapsInfosLoaded = NO;
    [self.loadingIndicator stopAnimating];
    [self.hiddenView setHidden:YES];


}

- (void)fetchAllImages
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    for(Map* m in [MapContainer getInstance].maps){
        [delegate.webClient fetchMapImageWithName:m];
    }
}

- (void)useImage:(UIImage *)image :(UIImageView *) view
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create a graphics image context
    CGSize newSize = CGSizeMake(512, 384);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    view.image = newImage;
    
    [pool release];
}

@end
