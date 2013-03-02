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
    @try {
        NSString *twitterURL = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/user_timeline.json?include_entities=true&include_rts=true&screen_name=audacity_team&count=10"];
        NSURL *fullURL = [NSURL URLWithString:twitterURL];
        
        NSError *error  = nil;
        NSData *dataURL = [NSData dataWithContentsOfURL:fullURL options:0 error:&error];
        //NSLog(@"%@", error);
        
        NSArray *result = [NSJSONSerialization JSONObjectWithData:dataURL options:NSJSONReadingMutableContainers error:&error];
        
        return result;
    }
    @catch (NSException *exception) {
        NSLog(@"[Twitter] Exception with Data");
        return nil;
    }
}

+ (void) postTweet
{

}

@end
