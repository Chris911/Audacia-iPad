//
//  NodeBooster.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "Node.h"
#import "OpenGLWaveFrontObject.h"

@interface NodeBooster : Node <NSCopying>

@property (nonatomic, retain) OpenGLWaveFrontObject *model;
@property (nonatomic) float Acceleration;

- (id) init;
- (void) render;

@end
