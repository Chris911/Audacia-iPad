//
//  RenderingTree.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import <Foundation/Foundation.h>
#import "Node.h"

@interface RenderingTree : NSObject

@property (nonatomic, retain) NSMutableArray* tree;

// Add node to rendering tree
- (void) addNodeToTree:(Node*) node;
- (void) addNodeToTreeWithInitialPosition:(Node*) node:(Vector3D)pos;

// Select node using its position
- (BOOL) selectNodeByPosition:(Vector3D) position;

// Remove selected nodes
- (BOOL) removeSelectedNodes;

// Selection utils
- (void) deselectAllNodes;
- (void) selectAllNodes;

// Transforms on selected nodes
- (void) rotateSelectedNodes:(Rotation3D) deltaAngle;
- (void) scaleSelectedNodes:(float) deltaScale;
- (BOOL) translateSelectedNodes:(CGPoint) deltaPoint;

// Rendering functions
- (void) render;

// RenderingTree util functions
- (int) getNumberOfNodes;
- (void) replaceNodesInBounds;

@end
