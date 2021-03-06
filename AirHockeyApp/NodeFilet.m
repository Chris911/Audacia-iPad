//
//  NodeFilet.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "NodeFilet.h"

@implementation NodeFilet

@synthesize model;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"FILET";
        self.xmlType = @"but";

        NSString *path = [[NSBundle mainBundle] pathForResource:@"filet" ofType:@"obj"];
        OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        Vertex3D position = Vertex3DMake(0, 0, 20.0);
        self.model = theObject;
        self.position = position;
        self.model.currentPosition = self.position;
        [theObject release];
    }
    return self;
}

- (void) render
{
    // Update the 3D Model Position
    self.model.currentPosition = self.position;
    
    // Save the current transformation by pushing it on the stack
	glPushMatrix();
    
	// Translate to the current position
	glTranslatef(self.model.currentPosition.x, self.model.currentPosition.y, self.model.currentPosition.z);
    
	// Rotate to the current rotation in Z
	glRotatef(self.angle, 0.0, 0.0, 1.0);
    
    // Scale the model
    glScalef(self.scaleFactor, self.scaleFactor, self.scaleFactor);
    
    // Draw the .obj Model
    [model drawSelf];
    
    glPopMatrix();
    
}

- (void) setRotation:(Rotation3D)rot
{
    self.model.currentRotation = rot;
}

- (void) dealloc
{
    [model release];
    [super dealloc];
}

@end
