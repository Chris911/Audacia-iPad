//
//  NodeTableEdge.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-17.
//
//

#import "Node.h"

@interface NodeTableEdge : Node
@property (nonatomic) Vector3D lastPosition;
@property (nonatomic) int index;
@property float goalSize;

// Constuctor with coordinates
- (id) initWithCoordsAndIndex:(float)x :(float)y :(int)index;

// Render the node
- (void)render;

@end
