//
//  Session.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-28.
//
//

#import "Session.h"

@implementation Session

@synthesize username;
@synthesize password;
@synthesize isAuthenticated;

NSString* DEFAULT_USERNAME = @"Guest";

static Session *session = NULL;

// Singleton of a rendering tree
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        session = [[Session alloc]init];
        session.username = DEFAULT_USERNAME;
        session.password = @"";
        session.isAuthenticated = NO;
    }
}

+ (Session *)getInstance
{
    [self initialize];
    return (session);
}

- (void) dealloc
{
    [super dealloc];
    [username release];
    [password release];
    [session release];
}

@end
