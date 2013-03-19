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
@synthesize profileImage;

NSString* DEFAULT_USERNAME = @"Sam";
NSString* DEFAULT_PASSWORD = @"123456789";

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
    session.password = DEFAULT_PASSWORD;
    session.isAuthenticated = YES;
    session.Camp = leftCamp;
    session.profileImage = [UIImage imageNamed:@"anonymous-icon.jpg"];
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
