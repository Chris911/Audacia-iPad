//
//  TwitterInterface.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-27.
//
//

#import "TwitterInterface.h"
#import "AFNetworking.h"    
#import <Twitter/Twitter.h>

@implementation TwitterInterface

+ (NSArray*)fetchTweets
{
    NSString *twitterURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/user_timeline.json?screen_name=DavidAlbertson"];
    NSURL *fullURL = [NSURL URLWithString:twitterURL];
    
    NSError *error = nil;
    NSData *dataURL = [NSData dataWithContentsOfURL:fullURL options:0 error:&error];
    NSArray *result=[NSJSONSerialization JSONObjectWithData:dataURL options:NSJSONReadingMutableContainers error:&error];

    return result;
}

+ (void) postTweet
{

}

@end
