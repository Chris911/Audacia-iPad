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

- (IBAction)editionModePressed:(id)sender;
- (IBAction)profileModePressed:(id)sender;
- (IBAction)controlerModePressed:(id)sender;
- (IBAction)mapviewerModePressed:(id)sender;
- (IBAction)logoutPressed:(id)sender;
- (IBAction)soundPressed:(id)sender;

@end
