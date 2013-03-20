//
//  Scene.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//  DESC: IServes as an interface to the almighty rendring tree
//  Singleton Class.  

#import "Scene.h"
#import "RenderingTree.h"
#import "XMLUtil.h"

#import "NodeTable.h"   
#import "NodeBooster.h"
#import "NodePommeau.h"
#import "NodePuck.h"
#import "NodePortal.h"

@implementation Scene

@synthesize renderingTree;
@synthesize loadingCustomTree;
@synthesize treeDoc;

static Scene *scene = NULL;

// Singleton of a rendering tree
+ (void)initialize
{
    if(scene == nil)
    {
        //initialized = YES;
        scene = [[Scene alloc]init];
        RenderingTree* tempTree = [[RenderingTree alloc]init];
        scene.renderingTree = tempTree;
        scene.loadingCustomTree = NO;
        [tempTree release];
    }
}

+ (Scene *)getInstance
{
    [self initialize];
    return (scene);
}

+ (void) loadDefaultElements
{
    NodeTable* table = [[[NodeTable alloc]init]autorelease];
    [table initDefaultTableValues];
    [scene.renderingTree addNodeToTree:table];
    
    // Very important to add the edges AFTER the table
    // (inherited from Projet2 XML's structure)
    [table addEdgesToTree];

    NodePuck* puck = [[[NodePuck alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:puck :Vector3DMake(0, 0, puck.position.z)];
    
    NodePortal* portal = [[[NodePortal alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(-20, -30, portal.position.z)];
    
    NodePommeau* pommeau1 = [[[NodePommeau alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:pommeau1 :Vector3DMake(-40, 0, pommeau1.position.z)];
    
    NodePommeau* pommeau2 = [[[NodePommeau alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:pommeau2 :Vector3DMake(40, 0, pommeau2.position.z)];
    
    NodeBooster* booster = [[[NodeBooster alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(20, 30, booster.position.z)];
}

// Use a prebuilt tree acquired from an XML file to eventually load the table
+ (void) loadCustomTree:(RenderingTree*) tree
{
    scene.renderingTree = tree;
}

// Reload tree when loading a custom tree from XML. Mainly for textures
+ (void) loadTreeFromXMLDoc
{
    scene.renderingTree = [XMLUtil loadRenderingTreeFromGDataXMLDocument:scene.treeDoc];
}

// Replaces elements out of the zone limits, defined in the Constants.h file
+ (void) replaceOutOfBoundsElements
{
    [scene.renderingTree replaceNodesInBounds];
}

// Check if, when drag and dropping, the position the user is
// placing the new node is within the zone limits
+ (BOOL) checkIfAddingLocationInBounds:(CGPoint)location
{
    if(location.x <= TABLE_LIMIT_X && location.x >= -TABLE_LIMIT_X
       && location.y <= TABLE_LIMIT_Y && location.y >= -TABLE_LIMIT_Y) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    [renderingTree release];
    [scene release];
    scene = nil;
    [super dealloc];
}

@end