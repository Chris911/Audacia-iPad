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
    NodeCube* cube = [[[NodeCube alloc]init]autorelease];
    
    if([self addNodeToTree:cube]){
        NSLog(@"Node of type: %@ added to tree",cube.type);
    } else {
        NSLog(@"Failed to add Node of type: %@ to tree",cube.type);
    }
    
    NodeTable* table = [[[NodeTable alloc]init]autorelease];
    
    if([self addNodeToTree:table]){
        NSLog(@"Node of type: %@ added to tree",table.type);
    } else {
        NSLog(@"Failed to add Node of type: %@ to tree",table.type);
    }
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
- (BOOL) addNodeToTree:(Node*) node
{
    if(node != nil){
        int countBeforeAdding = [tree count];
        [tree addObject:node];

        // count of nodes before is lower than actual count
        if(countBeforeAdding < [tree count]){
            return YES;
        }
        return NO;
    }
    return NO;
}

// Defines position when adding the node.  Mainly used
// when adding an object via drag-and-drop
- (void) addNodeToTreeWithInitialPosition:(Node*) node:(Vector3D)pos
{
    node.position = pos;
    [tree addObject:node];
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

- (void) translateSelectedNodes:(CGPoint*) deltaPoint
{
    
}

- (int) getNumberOfNodes
{
    return [tree count];
}


@end
