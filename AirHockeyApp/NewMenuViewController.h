//
//  NewMenuViewController.h
//  AirHockeyApp
//
//  Created by Chris on 13-02-13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@interface NewMenuViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextField *twitterLabel;
@property (retain, nonatomic) IBOutlet UIView *twitterBackgroundView;
@property (retain, nonatomic) IBOutlet UITextField *twitterLabel2;
@property (retain, nonatomic) IBOutlet UIView *controllerView;
@property (retain, nonatomic) IBOutlet UITextView *infoTextView;
@property (retain, nonatomic) IBOutlet UILabel *connexionStatusLabel;
@property (retain, nonatomic) IBOutlet UIButton *joystickButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIImageView *controllerViewBackgroundImage;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (retain, nonatomic) IBOutlet UIButton *soundButton;

- (IBAction)editionModePressed:(id)sender;
- (IBAction)profileModePressed:(id)sender;
- (IBAction)controlerModePressed:(id)sender;
- (IBAction)mapviewerModePressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
- (IBAction)soundPressed:(id)sender;
- (IBAction)joystickButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;


@end
