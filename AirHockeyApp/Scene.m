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

#import "NodeTable.h"   
#import "NodeCube.h"
#import "NodeBooster.h"
#import "NodePommeau.h"
#import "NodePuck.h"
#import "NodePortal.h"

@implementation Scene

@synthesize renderingTree;

static Scene *scene = NULL;

// Singleton of a rendering tree
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        scene = [[Scene alloc]init];
        RenderingTree* tempTree = [[RenderingTree alloc]init];
        scene.renderingTree = tempTree;
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
    [scene.renderingTree addNodeToTree:table];
    
    // Very important to add the edges AFTER the table
    // (inherited from Projet2 XML's structure)
    [table addEdgesToTree];
    
    NodePuck* puck = [[[NodePuck alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:puck :Vector3DMake(0, 0, puck.position.z)];
    
    NodePortal* portal = [[[NodePortal alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(-20, -30, portal.position.z)];
    
    NodePommeau* pommeau1 = [[[NodePommeau alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:pommeau1 :Vector3DMake(-50, 0, pommeau1.position.z)];
    
    NodePommeau* pommeau2 = [[[NodePommeau alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:pommeau2 :Vector3DMake(50, 0, pommeau2.position.z)];
    
    NodeBooster* booster = [[[NodeBooster alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(20, 30, booster.position.z)];
}

+ (void) replaceOutOfBoundsElements
{
    [scene.renderingTree replaceNodesInBounds];
}

- (void)dealloc
{
    self.renderingTree = nil;
    [renderingTree release];
    [scene release];
    [super dealloc];
}

@end