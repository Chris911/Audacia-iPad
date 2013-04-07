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
@property BOOL multipleNodesSelected;

// Add node to rendering tree
- (void) addNodeToTree:(Node*)node ;
- (void) addNodeToTreeWithInitialPosition:(Node*)node :(Vector3D) pos;
- (BOOL) addStickToTreeWithInitialPosition:(Vector3D)pos;
- (BOOL) addPuckToTreeWithInitialPosition:(Vector3D)pos;

// Select node using its position
- (BOOL) selectNodeByPosition:(Vector3D) position;
- (BOOL) selectNodesByZone:(CGPoint)beginPoint :(CGPoint)endPoint;

// Modify tree
- (BOOL) removeSelectedNodes;
- (BOOL) copySelectedNodes;
- (void) emptyRenderingTree;

// Selection utils
- (void) deselectAllNodes;
- (void) selectAllNodes;

// Transforms on selected nodes
- (void) rotateSingleNode:(Rotation3D) deltaAngle;
- (void) rotateMultipleNodes:(CGPoint) currentPoint :(CGPoint)lastPoint;
- (void) scaleSelectedNodes:(float) deltaScale;
- (BOOL) translateSingleNode:(CGPoint) deltaPoint;
- (BOOL) translateMultipleNodes:(CGPoint) deltaPoint;

// Slider functions
- (void) scaleBySliderSelectedNodes:(float) deltaScale;
- (void) rotateBySliderSingleNode:(float) deltaAngle;

// Rendering functions
- (void) render;

// RenderingTree util functions
- (int) getNumberOfNodes;
- (void) replaceNodesInBounds;
- (BOOL) checkIfAnyNodeClicked:(Vector3D)click;
- (Node*) getSingleSelectedNode;

// Table validation functions
- (int) getPuckCount;
- (int) getStickCount;
- (BOOL) isTableValid;
- (void) placeSticksOnGoodX_Axis;
- (Node*) getTable;


@end
