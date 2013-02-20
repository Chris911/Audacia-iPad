//
//  ProfileViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-20.
//
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *backgroundView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
- (IBAction)backPressed:(id)sender;

@end
