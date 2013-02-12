//
//  LoginViewController.h
//  AirHockeyApp
//
//  Created by Chris on 13-02-11.
//
//

#import <Foundation/Foundation.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (retain, nonatomic) IBOutlet UIView *loginBoxView;
@property (retain, nonatomic) IBOutlet UIImageView *iceView;
@property (retain, nonatomic) IBOutlet UIImageView *topView;
@property (retain, nonatomic) IBOutlet UIImageView *bottomView;
@property (retain, nonatomic) IBOutlet UITextField *usernameTextBox;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextBox;
@property (retain, nonatomic) IBOutlet UITextField *serverTextBox;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UIButton *continueAnonButton;
@property (retain, nonatomic) IBOutlet UILabel *teamAudacityLabel;

- (IBAction)pressedLoginButton:(id)sender;
- (IBAction)pressedContinueAnonButton:(id)sender;
- (IBAction)pressedValidateButton:(id)sender;

@end
