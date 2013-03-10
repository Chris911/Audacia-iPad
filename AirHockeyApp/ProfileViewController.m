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
#import "AppDemoAppDelegate.h"
#import "WebClient.h"
#import "ProfileMapsTableCell.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
{
    NSArray* mapsTableData;
}

@synthesize starsImageDict;

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
    
    //Initialize dictionnary
    self.starsImageDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                      @"Stars-1.png",[NSNumber numberWithInt:0],
                      @"Stars-1.png",[NSNumber numberWithInt:1],
                      @"Stars-2.png",[NSNumber numberWithInt:2],
                      @"Stars-3.png",[NSNumber numberWithInt:3],
                      @"Stars-4.png",[NSNumber numberWithInt:4],
                      @"Stars-5.png",[NSNumber numberWithInt:5],
                      nil];
    
    //Add observer for fetch map event
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(fetchProfileFinished)
                                          name:@"FecthingProfileFinished"
                                          object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(reloadTableData)
                                          name:@"FetchingImageFinished"
                                          object:nil];
    self.hiddenView.hidden = NO;
    self.spinner.hidden = NO;
    [self.spinner startAnimating];
    
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate.webClient fetchMapsByUser:[Session getInstance].username :self];
    [delegate.webClient fetchProfilePicture:[Session getInstance].username :self];
    
    [self.backgroundView.layer setCornerRadius:20.0f];
    [self.backgroundView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.backgroundView.layer setBorderWidth:2.5f];
    [self.backgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.backgroundView.layer setShadowOpacity:0.8];
    [self.backgroundView.layer setShadowRadius:1.0];
    [self.backgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
//    [self.picBackgroundView.layer setCornerRadius:20.0f];
//    [self.picBackgroundView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
//    [self.picBackgroundView.layer setBorderWidth:1.5f];
//    [self.picBackgroundView.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.picBackgroundView.layer setShadowOpacity:0.8];
//    [self.picBackgroundView.layer setShadowRadius:3.0];
//    [self.picBackgroundView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
//    [self.statsView.layer setCornerRadius:20.0f];
//    [self.statsView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
//    [self.statsView.layer setBorderWidth:1.5f];
//    [self.statsView.layer setShadowColor:[UIColor blackColor].CGColor];
//    [self.statsView.layer setShadowOpacity:0.8];
//    [self.statsView.layer setShadowRadius:1.0];
//    [self.statsView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    self.usernameLabel.text = [Session getInstance].username;
    
    //mapsTableData = [[NSArray alloc]init];
    
    //mapsTableData = [[NSArray alloc]initWithObjects:@"Egg Benedict", @"Mushroom Risotto", @"Full Breakfast", @"Hamburger", @"Ham and Egg Sandwich", @"Creme Brelee", @"White Chocolate Donut", @"Starbucks Coffee", @"Vegetable Curry", @"Instant Noodle with Egg", @"Noodle with BBQ Pork", @"Japanese Noodle with Pork", @"Green Tea", @"Thai Shrimp Cake", @"Angry Birds Cake", @"Ham and Cheese Panini", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_backgroundView release];
    [_usernameLabel release];
    [_picBackgroundView release];
    [_pictureImageView release];
    [_statsView release];
    [_mapsTableView release];
    [_hiddenView release];
    [_spinner release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundView:nil];
    [self setUsernameLabel:nil];
    [self setPicBackgroundView:nil];
    [self setPictureImageView:nil];
    [self setStatsView:nil];
    [self setMapsTableView:nil];
    [self setHiddenView:nil];
    [self setSpinner:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)pressedCameraButton:(id)sender
{
    [self startCameraControllerFromViewController: self
                                    usingDelegate: self];
}

- (void) assignUsersMaps:(NSArray*)maps
{
    mapsTableData = [[NSArray alloc] initWithArray:maps];
}

- (void) assignProfileImage:(UIImage*)image
{
    self.pictureImageView.image = image;
}

- (void) fetchProfileFinished
{
    [self fetchAllImages];
}

- (void) fetchAllImages
{
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    for(Map* m in mapsTableData){
        [delegate.webClient fetchMapImageWithName:m];
    }
}

- (void) reloadTableData
{
    [self.mapsTableView reloadData];
    [self stopAnimation];
}

- (void) stopAnimation
{
    self.hiddenView.hidden = YES;
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Use front facing camera
    cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self dismissModalViewControllerAnimated:YES];
    [[picker parentViewController] dismissModalViewControllerAnimated: NO];
    [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info
{    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        // UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
        self.pictureImageView.image = imageToSave;
        
        // Upload image to server
        AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
        [delegate.webClient uploadProfilePicture:imageToSave :[Session getInstance].username];

    }
        
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
    self.pictureImageView.image = img;
    [[picker parentViewController] dismissModalViewControllerAnimated: YES];
    [self dismissModalViewControllerAnimated:YES];
    [picker release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [mapsTableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ProfileMapsTableCell";
    
    ProfileMapsTableCell *cell = (ProfileMapsTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProfileMapsTableCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if([mapsTableData count]>0)
    {
        Map* map = [mapsTableData objectAtIndex:indexPath.row];
        cell.mapNameLabel.text = map.name;
        cell.lastModifiedLabel.text = map.timeStamp;
        NSString* imagePath = [starsImageDict objectForKey:[NSNumber numberWithInt:map.rating]];
        cell.ratingImageView.image = [UIImage imageNamed:imagePath];
        [self useImage:map.image :cell.mapImageView];
    }
    return cell;
}

- (void)useImage:(UIImage *)image :(UIImageView *) view
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create a graphics image context
    CGSize newSize = CGSizeMake(128, 96);
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 105;
}
@end
