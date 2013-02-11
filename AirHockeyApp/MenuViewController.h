//
//  MenuViewController.h
//  AppDemo
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

@property (retain, nonatomic) IBOutlet UILabel *UsernameLabel;
- (IBAction) afficherVueAnimee;
- (IBAction)testCaseButtonPressed:(id)sender;
- (IBAction)usernameChanged:(id)sender;
- (IBAction)passwordChanged:(id)sender;
- (IBAction)showConnectionView:(id)sender;
- (IBAction)toggleSound:(id)sender;
- (IBAction)showCarouselView:(id)sender;
- (IBAction)showLoginView:(id)sender;

@property (retain, nonatomic) IBOutlet UIView *ConnectionView;
@property (retain, nonatomic) IBOutlet UITextField *UserNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *PasswordTextField;

@end
