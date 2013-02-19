//
//  RenderingTree.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import "RenderingTree.h"
#import "NodeTable.h"
#import "NodePommeau.h"
#import "NodePuck.h"

@implementation RenderingTree

@synthesize tree;
@synthesize multipleNodesSelected;

- (id) init
{
    if((self = [super init])) {
        self.tree = [[NSMutableArray alloc]init];
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
            //NSLog(@"node of type : %@ added",node.type);
        } else {
            NSLog(@"error adding node of type : %@",node.type);
        }
    }
}

// Defines position when adding the node.  Mainly used
// when adding an object via drag-and-drop
- (void) addNodeToTreeWithInitialPosition:(Node*)node :(Vector3D)pos
{
    node.position = pos;
    [tree addObject:node];
}

// Add a stick to the table while checking for constraints
// on this game element
- (BOOL) addStickToTreeWithInitialPosition:(Vector3D)pos
{
    BOOL isAddingLegal = NO;
    int stickCount = [self getStickCount];

    // if there is 2 sticks on the table, don't add a new one
    if (stickCount < 2) {
        NodePommeau *pom = [[[NodePommeau alloc]init]autorelease];
        pom.position = pos;
        [tree addObject:pom];
        isAddingLegal = YES;
    } else {
        NSLog(@"Table already has 2 sticks");
    }
    return isAddingLegal;
}

// Add a puck to the table while checking for constraints
// on this game element
- (BOOL) addPuckToTreeWithInitialPosition:(Vector3D)pos
{
    BOOL isAddingLegal = NO;
    int puckCount = [self getPuckCount];
    
    if(puckCount == 0) {
        NodePuck *puck = [[[NodePuck alloc]init]autorelease];
        puck.position = pos;
        [tree addObject:puck];
        isAddingLegal = YES;
    } else {
        NSLog(@"Table already has 1 puck");
    }
    return  isAddingLegal;
}

#pragma mark - Selecting nodes
// Select node using its position
// FIXME: only works in the default 2D Plane
- (BOOL) selectNodeByPosition:(Vector3D) position
{    
    
    // New selection pass, make sure
    // no other nodes are still selected
    if(!self.multipleNodesSelected){
        [self deselectAllNodes];
    }
    
    NSLog(@"SELX: %f, SELY: %f",position.x, position.y);
    
    for(int i = [self.tree count]-1; i > 0; i--) //FIXME: Inverted selection order, may cause problems but fixes table selection
    {
        Node *node = [self.tree objectAtIndex:i];
        // bounding box check, FIXME: selection not optimal
        int offset = GLOBAL_SIZE_OFFSET * node.scaleFactor;
        
        if(node.position.x <= position.x + offset
           && node.position.x >= position.x - offset
           && node.position.y <= position.y + offset
           && node.position.y >= position.y - offset) {
                node.isSelected = YES;
                NSLog(@"Selected Type:%@",node.type);
                // FIXME: This only works for SINGLE OBJECT selection
                return YES; 
        }
    }
    return NO;
}


// Multiple nodes selection, using a zone (the begin and end points of the elastic rect)
- (BOOL) selectNodesByZone:(CGPoint)beginPoint :(CGPoint)endPoint
{
    [self deselectAllNodes];
    
    BOOL nodeWasSelected = NO;
    
    for(int i = [self.tree count]-1; i > 0; i--) 
    {
        Node *node = [self.tree objectAtIndex:i];
        
        // Invert if the rectangle isn't started from upper left and ended to lower right.
        if(beginPoint.x > endPoint.x){
            CGPoint temp = beginPoint;
            beginPoint = CGPointMake(endPoint.x, beginPoint.y);
            endPoint = CGPointMake(temp.x, endPoint.y);
        }
        
        if(endPoint.y > beginPoint.y){
            CGPoint temp = beginPoint;
            beginPoint = CGPointMake(beginPoint.x, endPoint.y);
            endPoint = CGPointMake(endPoint.x, temp.y);
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
    int nbNodes = [self.tree count];
    for(int i = nbNodes-1; i > 0; i--)
    {
        NSLog(@"Count bef:%i",[self.tree count]);

        Node *node = [self.tree objectAtIndex:i];
        if(node.isSelected && node.isRemovable) {
            [self.tree removeObject:node];
            NSLog(@"Count aft:%i",[self.tree count]);
        }
    }
    return YES;
}

// Copy selected nodes
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



#pragma mark - Transformation on nodes
// rotate a single node
- (void) rotateSingleNode:(Rotation3D)rotation
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.angle += rotation.x; // might not be the good axis
        }
    }
}

// Rotate multiple nodes
- (void) rotateMultipleNodes:(CGPoint)currentPoint :(CGPoint)lastPoint;
{
    float normalizedDirection = currentPoint.x - lastPoint.x;
    if(normalizedDirection == 0){
        normalizedDirection = 1;
    }
    
    Vector3D positions[[self.tree count]]; // max number of selected nodes is all of them...
    int selectedNodes = 0;

    // Find selected nodes positions
    for(Node* node in self.tree) {
        if(node.isSelected) {
            positions[selectedNodes] = node.position;
            selectedNodes ++;
        }
    }

    // Find the origin point (median of all points)
    float medianX = 0.0f;
    float medianY = 0.0f;
    for(int i = 0; i < selectedNodes; i++) {
        medianX += positions[i].x;
        medianY += positions[i].y;
    }

    CGPoint origin = CGPointMake(medianX/selectedNodes, medianY/selectedNodes);
    
    for(Node* node in self.tree) {
        if(node.isSelected) {
            
            float angle = (normalizedDirection/3) * 3.1416/180; // deg to rad and normalized (+ or -)
            float x = origin.x + ((node.position.x - origin.x) * cos(angle)) - ((node.position.y - origin.y) * sin(angle)) ;
            float y = origin.y + ((node.position.y - origin.y) * cos(angle)) + ((node.position.x - origin.x) * sin(angle)) ;
            
            node.position = Vector3DMake(x, y, node.position.z);
        }
    }
}

- (void) rotateBySliderSingleNode:(float) deltaAngle
{
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.angle = deltaAngle; 
        }
    }
}

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

- (void) scaleBySliderSelectedNodes:(float) deltaScale
{
    for(Node* node in self.tree)
    {
        // Check if node is selected AND scalable (Puck and Stick shouldn't scale according to SRS)
        if(node.isSelected && node.isScalable) {
            
            node.scaleFactor =deltaScale;
            if(node.scaleFactor >= 4) {
                node.scaleFactor = 4;
            } else if(node.scaleFactor <= 0.5) {
                node.scaleFactor = 0.5f;
            }
        }
    }
}


// Moves a single node.  DeltaPoint should be already
// normalized
- (BOOL) translateSingleNode:(CGPoint) deltaPoint
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

// Translate multiple nodes, according to the currently clicked node
- (BOOL) translateMultipleNodes:(CGPoint) deltaPoint
{
    Vector3D hitPosition = Vector3DMake(0, 0, 0);
    int offset = 8;
    for(Node* node in self.tree)
    {
        if(node.isSelected && // Pick the node being clicked to calculate offset
           node.position.x <= deltaPoint.x + offset
           && node.position.x >= deltaPoint.x - offset
           && node.position.y <= deltaPoint.y + offset
           && node.position.y >= deltaPoint.y - offset) {
            hitPosition = node.position;
        }
    }
    
    CGPoint deltaPos = CGPointMake(deltaPoint.x -  hitPosition.x, deltaPoint.y - hitPosition.y);
    
    for(Node* node in self.tree)
    {
        if(node.isSelected) {
            node.position = Vector3DMake(node.position.x + deltaPos.x,
                                         node.position.y + deltaPos.y,
                                         node.position.z);
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

- (Node*) getSingleSelectedNode;
{
    for(Node* node in self.tree)
    {
        if(node.isSelected)
            return node;
    }
    
    return nil;
}

- (Node*) getTable
{
    for(Node* node in self.tree) {
        if([node.type isEqualToString:@"TABLE"]) {
            return node;
        }
    }
    return nil;
}

#pragma mark - Table validation functions
- (int) getPuckCount
{
    int puckCount = 0;
    for(Node* node in self.tree) {
        if([node.type isEqualToString:@"PUCK"]) {
            puckCount ++;
        }
    }
    return puckCount;
}

- (int) getStickCount
{
    int stickCount = 0;
    for(Node* node in self.tree) {
        if([node.type isEqualToString:@"POMMEAU"]) {
            stickCount ++;
        }
    }
    return stickCount;
}

- (BOOL) isTableValid
{
    if([self getPuckCount] == 1 && [self getStickCount] == 2){
        return YES;
    }
    return NO;
}

#pragma mark - dealloc functions
- (void) dealloc
{
    [tree release];
    [super dealloc];
}
@end
