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

@interface CarouselTestView () <UIActionSheetDelegate>

@property (nonatomic, assign) BOOL wrap;
@property (nonatomic, retain) NSMutableArray *items;

@end

@implementation CarouselTestView

@synthesize carousel;
@synthesize wrap;
@synthesize items;

- (void)setUp
{
    //set up data
    wrap = YES;
    carousel.type = iCarouselTypeCoverFlow;
    self.items = [MapContainer getInstance].maps;
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

- (void)dealloc
{
    //it's a good idea to set these to nil here to avoid
    //sending messages to a deallocated viewcontroller
    carousel.delegate = nil;
    carousel.dataSource = nil;
    
    [carousel release];
    [items release];
    [super dealloc];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
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
    Map* map = [self.items objectAtIndex:index];

    //create new view if no view is available for recycling
    if (view == nil)
    {
        view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 512.0f/2, 384.0f/2)] autorelease];
        ((UIImageView *)view).image = map.image;
        view.contentMode = UIViewContentModeScaleAspectFit;
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
    }
    else
    {
        //get a reference to the label in the recycled view
        titleLabel = (UILabel *)[view viewWithTag:1];
        authorLabel = (UILabel *)[view viewWithTag:2];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    titleLabel.text = map.name;
    authorLabel.text = @"By author";
    ((UIImageView *)view).image = map.image;

    
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
        view = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0f, 200.0f)] autorelease];
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
    if (buttonIndex >= 0)
    {
        //map button index to carousel type
        iCarouselType type = buttonIndex;
        
        //carousel can smoothly animate between types
        [UIView beginAnimations:nil context:nil];
        carousel.type = type;
        [UIView commitAnimations];
    }
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
    [sheet release];
}

- (IBAction)pressedBack:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pressedRefresh:(id)sender {
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
    while (![MapContainer getInstance].isMapsLoaded) {
        
    }
    [self performSelectorOnMainThread:@selector(mapsDataFetchingDone) withObject:nil waitUntilDone:NO];
}

- (void)mapsDataFetchingDone
{
    // Safety check on the maps loaded attribute
    if ([MapContainer getInstance].isMapsLoaded){

        self.items = [MapContainer getInstance].maps;
        for(int i = 0; i < [[MapContainer getInstance].maps count]; i++){
            [self.carousel insertItemAtIndex:i animated:YES];
        }
    }
    
    // Reset to NO so we can load a new map array when the user switches views.
    [MapContainer getInstance].isMapsLoaded = NO;

}

@end
