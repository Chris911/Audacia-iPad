//
//  RenderingTree.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import "RenderingTree.h"
#import "NodeCube.h"

@implementation RenderingTree

@synthesize tree;

- (id) init
{
    if((self = [super init])) {
        tree = [[NSMutableArray alloc]init];
        [self loadBaseObjects];
    }
    return self;
}

- (void)loadBaseObjects
{
    NodeCube* cube = [[[NodeCube alloc]init]autorelease];
    [self addNodeToTree:cube];
}

- (void) render
{
   for(Node* node in self.tree)
   {
       [node render];
   }
}

// Add node to rendering tree
// Return YES if success
- (BOOL) addNodeToTree:(Node*) node
{
    [tree addObject:node];
    return YES;
}

// Select node using its position
- (BOOL) selectNodeByPosition:(Vector3D) position
{
    return YES;
}

// Remove selected nodes
- (BOOL) removeSelectedNodes
{
    return YES;
}

// Selection utils
- (void) deselectAllNodes
{
}
- (void) selectAllNodes
{
}

// Transforms on selected nodes
- (void) rotateSelectedNodes:(Rotation3D)rotation
{
    for(Node* node in self.tree)
    {
        // FIXME: Change to isSelected
        if(YES) {
            [node setRotation:rotation];
        }
    }
}

- (void) scaleSelectedNodes:(float) deltaScale
{
    
}

- (void) translateSelectedNodes:(CGPoint*) deltaPoint
{
    
}

@end
