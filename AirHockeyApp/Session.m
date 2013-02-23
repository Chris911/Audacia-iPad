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
@synthesize Camp;
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
        [self resetToDefault];
    }
}

+ (Session *)getInstance
{
    [self initialize];
    return (session);
}

+ (void) resetSession
{
    [self resetToDefault];
}

+ (void) resetToDefault
{
    session.username = DEFAULT_USERNAME;
    session.password = @"";
    session.isAuthenticated = NO;
    session.Camp = @"none";
}

- (void) dealloc
{
    [super dealloc];
    [username release];
    [password release];
    [session release];
    [Camp release];
}

@end
