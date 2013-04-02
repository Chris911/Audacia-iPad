//
//  CreditsViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-04-02.
//
//

#import <UIKit/UIKit.h>

@interface CreditsViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIView *creditView;
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIView *placeHolderView;
@property (retain, nonatomic) IBOutlet UIImageView *placeHolderImageView;

- (IBAction)backPressed:(id)sender;

@end
