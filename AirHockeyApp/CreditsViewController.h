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
@property (retain, nonatomic) NSString* totalGoals;
@property (retain, nonatomic) NSString* totalGames;
@property BOOL statsAreSet;

- (IBAction)backPressed:(id)sender;

@end
