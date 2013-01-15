//
//  NodeCube.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-15.
//
//

#import "NodeCube.h"

@implementation NodeCube

@synthesize model;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"CUBE";
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"cube" ofType:@"obj"];
        OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        Vertex3D position = Vertex3DMake(0.0, 0.0, -50.0);
        theObject.currentPosition = position;
        self.model = theObject;
        [theObject release];
    }
    return self;
}

- (void) render
{
    [model drawSelf];
}

- (void) setRotation:(Rotation3D)rot
{
    self.model.currentRotation = rot;
}

@end
