//
//  AppDemoAppDelegate.m
//  AppDemo
//

#import "AppDemoAppDelegate.h"
#import "MenuViewController.h"
#import "EAGLViewController.h"
#import "LoginViewController.h"
#import "NetworkUtils.h"

@implementation AppDemoAppDelegate

@synthesize window = _window;
@synthesize eaglViewController = _eaglViewController;
@synthesize loginViewController = _loginViewController;
@synthesize webClient;

- (void) afficherVueAnimee
{
    self.window.rootViewController = self.eaglViewController;
}

- (void) afficherMenu
{    
//    [UIView transitionWithView:self.window duration:1.0 options:(UIViewAnimationOptionTransitionCrossDissolve) animations:^{
//        self.window.rootViewController = self.menuViewController;
//    } completion:nil];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.rootViewController = self.loginViewController;
    
    if([NetworkUtils isNetworkAvailable]){
       self.webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
    } else {
        [NetworkUtils showNetworkUnavailableAlert];
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    if(self.webClient == nil && [NetworkUtils isNetworkAvailable]){
        self.webClient = [[[WebClient alloc] initWithDefaultServer]autorelease];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_eaglViewController release];
    [webClient release];
    [super dealloc];
}

@end
