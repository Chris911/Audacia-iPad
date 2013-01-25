//
//  NetworkUtils.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-24.
//
//

#import "Node.h"
#import "Reachability.h"

@interface NetworkUtils : Node

+ (BOOL)isNetworkAvailable;
+ (void)showNetworkUnavailableAlert;

@end
