//
//  RenderingTree.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import "RenderingTree.h"

@implementation RenderingTree

@synthesize tree;

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
- (void) rotateSelectedNodes:(float) deltaAngle
{
}
- (void) scaleSelectedNodes:(float) deltaScale
{
}
- (void) translateSelectedNodes:(CGPoint*) deltaPoint
{
}

@end
