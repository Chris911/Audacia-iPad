//
//  NodeMurret.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "NodeMurret.h"

@implementation NodeMurret

@synthesize model;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"MURRET";
        self.xmlType = @"Murret";

        NSString *path = [[NSBundle mainBundle] pathForResource:@"murret" ofType:@"obj"];
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

-(id)copyWithZone:(NSZone *)zone
{
    // We'll ignore the zone for now
    NodeMurret *copyObj = [[NodeMurret alloc] init];
    copyObj.position = Vector3DMake(self.position.x + 10, self.position.y, self.position.z);
    copyObj.scaleFactor = self.scaleFactor;
    copyObj.angle = self.angle;
    copyObj.isSelected = NO;
    
    return copyObj;
}

@end
