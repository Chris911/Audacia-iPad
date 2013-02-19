//
//  NodePortal.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "Node.h"
#import "OpenGLWaveFrontObject.h"

@interface NodePortal : Node <NSCopying>

@property (nonatomic, retain) OpenGLWaveFrontObject *model;
@property (nonatomic) float Gravite;

- (id) init;
- (void) render;

@end
