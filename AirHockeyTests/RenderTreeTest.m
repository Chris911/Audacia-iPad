//
//  RenderTreeTest.m
//  AirHockeyApp
//
//  Created by Chris on 13-04-03.
//
//

#import "RenderTreeTest.h"
#import "Scene.h"
#import "RenderingTree.h"

@implementation RenderTreeTest

- (void)setUp
{
    [super setUp];
    // Set-up code here.
    [Scene loadDefaultElements];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

- (void)testRenderingTree
{
    STAssertEquals([[Scene getInstance].renderingTree getNumberOfNodes], 12, @"Number of nodes");
}

@end
