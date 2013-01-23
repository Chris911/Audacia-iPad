//
//  RenderingTree.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import "RenderingTree.h"
#import "NodeCube.h"
#import "NodeTable.h"

@implementation RenderingTree

@synthesize tree;

- (id) init
{
    if((self = [super init])) {
        tree = [[NSMutableArray alloc]init];
    }
    return self;
}

// Render all of the tree objects
- (void) render
{
   for(Node* node in self.tree)
   {
       [node render];
   }
}

// Add node to rendering tree
- (void) addNodeToTree:(Node*) node
{
    if(node != nil){
        int countBeforeAdding = [tree count];
        [tree addObject:node];

        // count of nodes before is lower than actual count
        if(countBeforeAdding < [tree count]){
            NSLog(@"node of type : %@ added",node.type);
        } else {
            NSLog(@"error adding node of type : %@",node.type);
        }
    }
}

// Defines position when adding the node.  Mainly used
// when adding an object via drag-and-drop
- (void) addNodeToTreeWithInitialPosition:(Node*) node:(Vector3D)pos
{
    node.position = pos;
    [tree addObject:node];
}

// Select node using its position
// FIXME: only works in the default 2D Plane
- (BOOL) selectNodeByPosition:(Vector3D) position
{
    BOOL nodeWasSelected = NO;
    
    // The bigger the value, the easier it is to select an object
    int offset = 8;
    
    // New selection pass, make sure
    // no other nodes are still selected
    [self deselectAllNodes];
    
    for(Node* node in self.tree)
    {
        // bounding box check, FIXME: selection not optimal
        if(node.isSelectable
           && (node.position.x <= position.x + offset
           && node.position.x >= position.x - offset
           && node.position.y <= position.y + offset
           && node.position.y >= position.y - offset)) {
               node.isSelected = YES;
               NSLog(@"Selected Type:%@",node.type);
               // FIXME: This only works for SINGLE OBJECT selection
               nodeWasSelected = YES;
        }
    }
    return nodeWasSelected;
}

// Remove selected nodes
- (BOOL) removeSelectedNodes
{
    return YES;
}

// Selection utils
- (void) deselectAllNodes
{
    for(Node* node in self.tree)
    {
        node.isSelected = NO;
    }
}

// Select all nodes of the rendering tree
- (void) selectAllNodes
{
    for(Node* node in self.tree)
    {
        node.isSelected = YES;
    }
}

// Transforms on selected nodes
- (void) rotateSelectedNodes:(Rotation3D)rotation
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.angle += rotation.x; // might not be the good axis
        }
    }
}

// Scale node that are currently selected
- (void) scaleSelectedNodes:(float) deltaScale
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {

            node.scaleFactor += deltaScale/30;
            if(node.scaleFactor >= 4) {
                node.scaleFactor = 4;
            } else if(node.scaleFactor <= 0.5) {
                node.scaleFactor = 0.5f;
            }
        }
    }
}

// Return YES if any node was selected
- (BOOL) translateSelectedNodes:(CGPoint) deltaPoint
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.position = Vector3DMake(deltaPoint.x, deltaPoint.y, node.position.z);
            return YES;
        }
    }
    return NO;
}

- (int) getNumberOfNodes
{
    return [tree count];
}

//  Make sure all active nodes (that have been released
// from the user's touch) are in the Zone limits
- (void) replaceNodesInBounds
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            [node checkIfInBounds];
        }
    }
}


@end
