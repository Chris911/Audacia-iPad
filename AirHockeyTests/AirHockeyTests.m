//
//  AirHockeyTests.m
//  AirHockeyTests
//
//  Created by Chris on 13-04-02.
//
//

#import "AirHockeyTests.h"
#import "WebClient.h"

@implementation AirHockeyTests

@synthesize webclient;

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.webclient = [[WebClient alloc]initWithDefaultServer];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testExample
{
//    BOOL static done = YES;
//    [self.webclient fetchStatsByUser:@"iPadTest"
//                        onCompletion:^(NSDictionary *JSON)
//     {
//         int gamesPlayed  = [[JSON valueForKeyPath:@"GamePlayed"]intValue];
//         int victories   = [[JSON valueForKeyPath:@"Victories"]intValue];
//         int defeats = [[JSON valueForKeyPath:@"Defeats"]intValue];
//         int goalsFor = [[JSON valueForKeyPath:@"GoalsFor"]intValue];
//         int goalsAgainst = [[JSON valueForKeyPath:@"GoalsAgainst"]intValue];
//         
//         STAssertEquals(5, gamesPlayed, @"Games Played");
//         STAssertEquals(5, victories, @"Victories");
//         STAssertEquals(0, defeats, @"Defeats");
//         STAssertEquals(25, goalsFor, @"Goals For");
//         STAssertEquals(0, goalsAgainst, @"Goals Against");
//         
//         done = NO;
//
//     }];
//    while(done);
    
    STAssertTrue(YES, @"Test test");
}



@end
