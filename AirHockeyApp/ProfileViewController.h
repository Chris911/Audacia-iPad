//
//  ProfileViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-20.
//
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,
                                                    UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate,
                                                    UIGestureRecognizerDelegate>

@property (retain, nonatomic) IBOutlet UIView *backgroundView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UIView *picBackgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *pictureImageView;
@property (retain, nonatomic) IBOutlet UIView *statsView;
- (IBAction)backPressed:(id)sender;

- (IBAction)pressedCameraButton:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *mapsTableView;
@property (retain, nonatomic) IBOutlet UIView *hiddenView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (retain, nonatomic) NSDictionary *starsImageDict;

@property (retain, nonatomic) IBOutlet UIButton *doneDeletingButton;
- (IBAction)pressedDoneEditingButton:(id)sender;

- (void) assignUsersMaps:(NSArray*)maps;
- (void) assignProfileImage:(UIImage*)image;

@property (retain, nonatomic) IBOutlet UILabel *gamesPlayedLabel;
@property (retain, nonatomic) IBOutlet UILabel *victoriesLabel;
@property (retain, nonatomic) IBOutlet UILabel *defeatsLabel;
@property (retain, nonatomic) IBOutlet UILabel *goalsForLabel;
@property (retain, nonatomic) IBOutlet UILabel *goalsAgainsLabel;


@end
