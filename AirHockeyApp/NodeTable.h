//
//  NodeTable.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//
//

#import "Node.h"
#import "Border3D.h"

@interface NodeTable : Node
@property float CoeffFriction;
@property float CoeffRebond;

- (id) init;
- (void) render;

// Table's specific methods
- (void) addEdgesToTree;
- (void) initDefaultTableValues;
- (void) initTableEdgesFromXML:(NSArray*)newEdges;

@end
