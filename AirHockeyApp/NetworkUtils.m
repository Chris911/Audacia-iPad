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
        NSLog(@"NOT Connected to internet");
    } else {
        available = YES;
        NSLog(@"Connected to internet");
    }
    return available;
}

+ (void)showNetworkUnavailableAlert
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Connexion Internet"
                                                      message:@"Vous devez etre connecté a Internet pour utiliser cette fonctionnalité"
                                                     delegate:nil
                                            cancelButtonTitle:nil
                                            otherButtonTitles:@"Ok", nil];
    [message show];
    [message release];
}
@end
