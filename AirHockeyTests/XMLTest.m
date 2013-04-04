//
//  XMLTest.m
//  AirHockeyApp
//
//  Created by Chris on 13-04-03.
//
//

#import "XMLTest.h"
#import "Scene.h"
#import "RenderTreeTest.h"
#import "XMLUtil.h"
#import "OpenGLWaveFrontCommon.h"

@implementation XMLTest

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

// Save XML and reload checking info for 1 node
- (void)testXml
{
    Vector3D position = Vector3DMake(0, 0, 0);
    for(Node* node in [Scene getInstance].renderingTree.tree)
    {
        if([node.type isEqualToString:@"POMMEAU"])
        {
            position = node.position;
            break;
        }
    }
    if(position.x == 0)
    {
        STAssertTrue(NO, @"XML Test Failed");
    }
    // Generate XML Doc
    GDataXMLDocument* XMLDoc = [XMLUtil getRenderingTreeXmlData:[Scene getInstance].renderingTree];
    
    //Load XML
    RenderingTree* tree = [XMLUtil loadRenderingTreeFromGDataXMLDocument:XMLDoc];
    for(Node* node in tree.tree)
    {
        if([node.type isEqualToString:@"POMMEAU"])
        {
            STAssertEquals(node.position, position, @"Node Position");
            return;
        }
    }
    STAssertTrue(NO, @"XML Test Failed");
}


@end
