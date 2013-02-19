//
//  NodePuck.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "NodePuck.h"

@implementation NodePuck

@synthesize model;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"PUCK";
        self.xmlType = @"Puck";

        NSString *path = [[NSBundle mainBundle] pathForResource:@"puck" ofType:@"obj"];
        OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        Vertex3D position = Vertex3DMake(0, 0, 2.0);
        self.model = theObject;
        self.position = position;
        self.isCopyable = NO;
        self.isScalable = NO;
        self.model.currentPosition = self.position;
        [theObject release];
    }
    return self;
}

- (void) render
{
    // Bounding box visible if selected
    if(self.isSelected){
        int offset = GLOBAL_SIZE_OFFSET * self.scaleFactor;
        
        GLfloat Vertices[] = {
            self.position.x - offset, self.position.y + offset, self.position.z,
            self.position.x - offset, self.position.y - offset, self.position.z,
            self.position.x + offset, self.position.y - offset, self.position.z,
            self.position.x + offset, self.position.y + offset, self.position.z,
        };
        
        glVertexPointer(3, GL_FLOAT, 0, Vertices);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        if(glGetError() != 0)
            NSLog(@"%u",glGetError());
        
        glDrawArrays(GL_LINE_LOOP, 0, 4);
        glDisableClientState(GL_VERTEX_ARRAY);
    }
    
    // Update the 3D Model Position
    self.model.currentPosition = self.position;
    
    // Save the current transformation by pushing it on the stack
	glPushMatrix();
    
	// Translate to the current position
	glTranslatef(self.model.currentPosition.x, self.model.currentPosition.y, self.model.currentPosition.z);
    
	// Rotate to the current rotation in Z
    glRotatef(90, 1.0, 0, 0);
	glRotatef(self.angle, 0.0, 0.0, 1.0);
    
    // Scale the model
    glScalef(2.0f, 2.0f, 2.0f);
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
