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
- (IBAction)pressedSwitchButton:(id)sender;

@end
