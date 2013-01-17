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
        [self loadBaseObjects];
    }
    return self;
}

// Loads objects that are always present in the scene,
// whatever the context might be (ex : the table)
- (void)loadBaseObjects
{
//    NodeCube* cube = [[[NodeCube alloc]init]autorelease];
//    
//    if([self addNodeToTree:cube]){
//        NSLog(@"Node of type: %@ added to tree",cube.type);
//    } else {
//        NSLog(@"Failed to add Node of type: %@ to tree",cube.type);
//    }
    
    //NodeTable* table = [[[NodeTable alloc]init]autorelease];
    //[self addNodeToTree:table];
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
            NSLog(@"node added");
        } else {
            NSLog(@"error adding node");
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
// Temporary since it only works in a 2D Plane
- (void) selectNodeByPosition:(Vector3D) position
{
    // The bigger the value, the easiest it is to select an object
    int offset = 8;
    
    // New selection pass, make sure
    // no other nodes are still selected
    [self deselectAllNodes];
    
    for(Node* node in self.tree)
    {
        // bounding box check, not optimal
        if(node.isSelectable
           && (node.position.x <= position.x + offset
           && node.position.x >= position.x - offset
           && node.position.y <= position.y + offset
           && node.position.y >= position.y - offset)) {
            node.isSelected = YES;
            NSLog(@"Selected Type:%@",node.type);
        }
    }
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
        // FIXME: Change to isSelected
        if(YES) {
            [node setRotation:rotation];
        }
    }
}

- (void) scaleSelectedNodes:(float) deltaScale
{
    
}

- (void) translateSelectedNodes:(CGPoint) deltaPoint
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.position = Vector3DMake(deltaPoint.x, deltaPoint.y, 0);
        }
    }
}

- (int) getNumberOfNodes
{
    return [tree count];
}


@end
