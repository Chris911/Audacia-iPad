//
//  BetaViewController.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-14.
//
//

#import <UIKit/UIKit.h>
#import "WebClient.h"

@interface BetaViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIButton *downloadSelectedMap;
@property (retain, nonatomic) IBOutlet UITextView *mapsTextView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

- (IBAction)goBack:(id)sender;
- (IBAction)testUpload:(id)sender;

@end
