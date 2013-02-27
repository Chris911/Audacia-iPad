//
//  NetworkUtils.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-24.
//  Edited from http://stackoverflow.com/questions/8812459/easiest-way-to-detect-a-connection-on-ios
//

#import "NetworkUtils.h"

@implementation NetworkUtils

+ (BOOL)isNetworkAvailable
{
    BOOL available = NO;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"[NetworkUtil] NOT Connected to internet");
    } else {
        available = YES;
        NSLog(@"[NetworkUtil] Connected to internet");
    }
    return available;
}

+ (void)showNetworkUnavailableAlert
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connection Warning"
                                                      message:@"Please make sure you are connected to internet"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"OK", nil];
    [message show];
    [message release];
}
@end
