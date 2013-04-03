//
//  ReachabilityTest.m
//  AirHockeyApp
//
//  Created by Chris on 13-04-02.
//
//

#import "ReachabilityTest.h"
#import "NetworkUtils.h"

@implementation ReachabilityTest

- (void)setUp
{
    [super setUp];
    // Set-up code here.

}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testReachability
{
    STAssertTrue([NetworkUtils isNetworkAvailable], @"Network should be available");
}




@end
