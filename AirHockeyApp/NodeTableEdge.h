//
//  NodeTableEdge.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-17.
//
//

#import "Node.h"

@interface NodeTableEdge : Node

// Constuctor with coordinates
- (id) initWithCoords:(float)x :(float)y;

// Render the node
- (void)render;

@end
