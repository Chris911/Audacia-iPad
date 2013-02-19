//
//  NodePommeau.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "Node.h"
#import "OpenGLWaveFrontObject.h"

@interface NodePommeau : Node

@property (nonatomic, retain) OpenGLWaveFrontObject *model;
@property (nonatomic, retain) NSString* Camp;

- (id) init;
- (void) render;

@end
