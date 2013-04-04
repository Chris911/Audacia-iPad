//
//  AuthTest.m
//  AirHockeyApp
//
//  Created by Chris on 13-04-03.
//
//

#import "AuthTest.h"
#import "Session.h"

@implementation AuthTest

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    [Session resetSession];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testAuth
{
    STAssertFalse([Session getInstance].isAuthenticated, @"User is not authenticated");
    STAssertEquals([Session getInstance].username, @"Guest", @"Username to Guest");
}

@end
