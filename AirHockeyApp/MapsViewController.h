//
//  MapsViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-06.
//
//

#import <UIKit/UIKit.h>

@interface MapsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIScrollView *ScrollView;
- (IBAction)fetchPressed:(id)sender;
- (IBAction)returnPressed:(id)sender;

@end
