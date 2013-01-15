//
//  NodeCube.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-15.
//
//

#import "Node.h"
#import "OpenGLWaveFrontObject.h"

@interface NodeCube : Node

@property (nonatomic, retain) OpenGLWaveFrontObject *model;

- (id) init;
- (void) render;
@end
