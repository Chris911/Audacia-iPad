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
@property (nonatomic,retain)Border3D* border1;

- (id) init;
- (void) render;

// Table's specific methods
- (void) addEdgesToTree;


@end
