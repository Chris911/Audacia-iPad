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
#import "NodePommeau.h"
#import "NodePuck.h"

@implementation RenderingTree

@synthesize tree;
@synthesize multipleNodesSelected;

- (id) init
{
    if((self = [super init])) {
        tree = [[NSMutableArray alloc]init];
        self.multipleNodesSelected = NO;
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

#pragma mark - Adding nodes to the tree
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

// Add a stick to the table while checking for constraints
// on this game element
- (void) addStickToTreeWithInitialPosition:(Vector3D)pos
{
    int stickCount = 0;
    for(Node* node in self.tree) {
        if([node.type isEqualToString:@"POMMEAU"]) {
            stickCount ++;
        }
    }

    // if there is 2 sticks on the table, don't add a new one
    if (stickCount < 2) {
        NodePommeau *pom = [[[NodePommeau alloc]init]autorelease];
        pom.position = pos;
        [tree addObject:pom];
    } else {
        NSLog(@"Table already has 2 sticks");
    }
}

// Add a puck to the table while checking for constraints
// on this game element
- (void) addPuckToTreeWithInitialPosition:(Vector3D)pos
{
    int puckCount = 0;
    for(Node* node in self.tree) {
        if([node.type isEqualToString:@"PUCK"]) {
            puckCount ++;
        }
    }
    
    if(puckCount == 0) {
        NodePuck *puck = [[[NodePuck alloc]init]autorelease];
        puck.position = pos;
        [tree addObject:puck];
    } else {
        NSLog(@"Table already has 1 puck");
    }
}

#pragma mark - Selecting nodes
// Select node using its position
// FIXME: only works in the default 2D Plane
- (BOOL) selectNodeByPosition:(Vector3D) position
{
    BOOL nodeWasSelected = NO;
    
    // The bigger the value, the easier it is to select an object
    int offset = 8;
    
    // New selection pass, make sure
    // no other nodes are still selected
    if(!self.multipleNodesSelected){
        [self deselectAllNodes];
    }
    
    for(int i = [self.tree count]-1; i > 0; i--) //FIXME: Inverted selection order, may cause problems but fixes table selection
    {
        Node *node = [self.tree objectAtIndex:i];
        // bounding box check, FIXME: selection not optimal
        if(node.position.x <= position.x + offset
           && node.position.x >= position.x - offset
           && node.position.y <= position.y + offset
           && node.position.y >= position.y - offset) {
                node.isSelected = YES;
                NSLog(@"Selected Type:%@",node.type);
                // FIXME: This only works for SINGLE OBJECT selection
                nodeWasSelected = YES;
                return YES; 
        }
    }
    return nodeWasSelected;
}

- (BOOL) selectNodesByZone:(CGPoint)beginPoint:(CGPoint)endPoint
{
    [self deselectAllNodes];
    
    BOOL nodeWasSelected = NO;
    
    for(int i = [self.tree count]-1; i > 0; i--) //FIXME: Inverted selection order, may cause problems but fixes table selection
    {
        Node *node = [self.tree objectAtIndex:i];
        
        // Invert if the rectangle isn't started from upper left and ended to lower right.
        if(beginPoint.x > endPoint.x){
            beginPoint = CGPointMake(-beginPoint.x, beginPoint.y);
            endPoint = CGPointMake(-endPoint.x, endPoint.y);
        }
        
        if(endPoint.y > beginPoint.y){
            beginPoint = CGPointMake(beginPoint.x, -beginPoint.y);
            endPoint = CGPointMake(endPoint.x, -endPoint.y);
        }
        
        //Always according to this figure after correction :
        //  B ------ *
        //  |  Node  |
        //  * ------ E
        
        if(node.position.x <= endPoint.x
           && node.position.x >= beginPoint.x
           && node.position.y >= endPoint.y
           && node.position.y <= beginPoint.y) {
            
            if(![node.type isEqualToString:@"EDGE"] && ![node.type isEqualToString:@"TABLE"]){
                node.isSelected = YES;
                NSLog(@"Selected Type:%@",node.type);
                nodeWasSelected = YES;
            }
            self.multipleNodesSelected = YES;
        }
    }
    
    return nodeWasSelected;
}

// Select all nodes of the rendering tree
- (void) selectAllNodes
{
    for(Node* node in self.tree)
    {
        node.isSelected = YES;
    }
}

// Remove selected nodes
- (BOOL) removeSelectedNodes
{
    // Need regular for loop here for sync problem.
    for(int i = 0; i < [self.tree count]; i++)
    {
        Node *node = [self.tree objectAtIndex:i];
        if(node.isSelected && node.isRemovable) {
            [self.tree removeObject:node];
        }
    }
    return YES;
}

// Remove selected nodes
- (BOOL) copySelectedNodes
{
    // Need regular for loop here for sync problem.
    for(int i = 0; i < [self.tree count]; i++)
    {
        Node *node = [self.tree objectAtIndex:i];
        if(node.isSelected && node.isCopyable) {
            [self.tree addObject:[node copy]];
        }
    }
    [self replaceNodesInBounds];
    return YES;
}

- (void) emptyRenderingTree
{
    [self.tree removeAllObjects];
}

// Selection utils
- (void) deselectAllNodes
{
    for(Node* node in self.tree)
    {
        node.isSelected = NO;
    }
    self.multipleNodesSelected = NO;
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

#pragma mark - Transformation on nodes
// Scale node that are currently selected
- (void) scaleSelectedNodes:(float) deltaScale
{
    for(Node* node in self.tree)
    {
        // Check if node is selected AND scalable (Puck and Stick shouldn't scale according to SRS)
        if(node.isSelected && node.isScalable) {

            node.scaleFactor += deltaScale/30;
            if(node.scaleFactor >= 4) {
                node.scaleFactor = 4;
            } else if(node.scaleFactor <= 0.5) {
                node.scaleFactor = 0.5f;
            }
        }
    }
}
// Move selected nodes.  DeltaPoint should be already
// normalized
- (BOOL) translateSelectedNodes:(CGPoint) deltaPoint
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.position = Vector3DMake(deltaPoint.x, deltaPoint.y, node.position.z);
            
        }
    }
    return NO;
}

#pragma mark - Utility functions
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
        [node checkIfInBounds];
    }
}

- (BOOL) checkIfAnyNodeClicked:(Vector3D)click
{
    BOOL anyNodeHit = NO;
    int offset = 8;
    for(int i = [self.tree count]-1; i > 0; i--) //FIXME: Inverted selection order, may cause problems but fixes table selection
    {
        
        Node *node = [self.tree objectAtIndex:i];
        // bounding box check, FIXME: selection not optimal
        if(node.position.x <= click.x + offset
           && node.position.x >= click.x - offset
           && node.position.y <= click.y + offset
           && node.position.y >= click.y - offset) {
            anyNodeHit = YES;
        }
    }
    return anyNodeHit;
}



@end
