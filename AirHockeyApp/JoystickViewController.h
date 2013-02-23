//
//  JoystickViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-21.
//
//

#import <UIKit/UIKit.h>

@interface JoystickViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIView *joystickView;
- (IBAction)exitPressed:(id)sender;

@end
