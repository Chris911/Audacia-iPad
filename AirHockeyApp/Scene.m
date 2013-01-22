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
    
    NodeCube* cube = [[[NodeCube alloc]init]autorelease];
    [scene.renderingTree addNodeToTreeWithInitialPosition:cube :Vector3DMake(-20, 10, cube.position.z)];
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