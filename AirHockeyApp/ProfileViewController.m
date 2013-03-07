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

@interface ProfileViewController ()

@end

@implementation ProfileViewController

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
    // Do any additional setup after loading the view from its nib.
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
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundView:nil];
    [self setUsernameLabel:nil];
    [self setPicBackgroundView:nil];
    [self setPictureImageView:nil];
    [self setStatsView:nil];
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

@end
