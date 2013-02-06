//
//  CarouselTestView.h
//  AirHockeyApp
//
//  Created by Chris on 13-02-01.
//
//

#import <UIKit/UIKit.h>
#import "iCarousel.h"

@interface CarouselTestView : UIViewController <iCarouselDataSource, iCarouselDelegate>

@property (nonatomic, retain) IBOutlet iCarousel *carousel;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (retain, nonatomic) IBOutlet UIView *hiddenView;
- (IBAction)pressedSwitchButton:(id)sender;
- (IBAction)pressedBack:(id)sender;
- (IBAction)pressedRefresh:(id)sender;

@end
