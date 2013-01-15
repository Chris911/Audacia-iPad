//
//  Node.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//  DESC: Interface for OpenGL nodes
//

#import <Foundation/Foundation.h>
#import "EAGLView.h"
#import "OpenGLWaveFrontCommon.h"

@interface Node : NSObject
@property (nonatomic,retain) NSString* type;
@property (nonatomic,retain) NSString* hash;
@property (nonatomic) Vector3D position;
@property (nonatomic) float angle;
@property (nonatomic) float scaleFactor;

@property BOOL isSelected;
@property BOOL isVisible;
@property BOOL isSelectable;
@property BOOL isWaveFrontObject;

// Constructor
- (id) init;

//Render tree
- (void) render;

- (void) setRotation:(Rotation3D)rotation;
- (void) setPosition:(Vector3D)  position;
- (void) setScaling :(float)     scaleFactor;

@end
