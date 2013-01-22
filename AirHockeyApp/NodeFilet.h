//
//  NodeFilet.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "Node.h"
#import "OpenGLWaveFrontObject.h"

@interface NodeFilet : Node

@property (nonatomic, retain) OpenGLWaveFrontObject *model;

- (id) init;
- (void) render;

@end
