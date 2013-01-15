//
//  AppDemoAppDelegate.h
//  AppDemo
//

#import <UIKit/UIKit.h>

@class MenuViewController;
@class EAGLViewController;

@interface AppDemoAppDelegate : NSObject <UIApplicationDelegate>

- (void) afficherVueAnimee;
- (void) afficherMenu;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MenuViewController *menuViewController;
@property (nonatomic, retain) IBOutlet EAGLViewController *eaglViewController;


@end
