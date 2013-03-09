//
//  NodePortal.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-22.
//
//

#import "NodePortal.h"

@implementation NodePortal

@synthesize model;
@synthesize Gravite;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"PORTAL";
        self.xmlType = @"Portal";

        NSString *path = [[NSBundle mainBundle] pathForResource:@"portal" ofType:@"obj"];
        OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        Vertex3D position = Vertex3DMake(0, 0, 1.0);
        self.model = theObject;
        self.position = position;
        self.model.currentPosition = self.position;
        self.Gravite = 1.0f;
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
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glColor4f(1, 1, 1, 0.5f);
    
	// Translate to the current position
	glTranslatef(self.model.currentPosition.x, self.model.currentPosition.y, self.model.currentPosition.z);
    
	// Rotate to the current rotation in Z
    glRotatef(90, 1.0, 0, 0);
	glRotatef(self.angle, 0.0, 1.0, 0.0);
    
    // Scale the model
    glScalef(3.0f, 3.0f, 3.0f);
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
    NodePortal *copyObj = [[NodePortal alloc] init];
    copyObj.position = Vector3DMake(self.position.x + 10, self.position.y, self.position.z);
    copyObj.scaleFactor = self.scaleFactor;
    copyObj.angle = self.angle;
    copyObj.isSelected = NO;
    
    return copyObj;
}

- (void) dealloc
{
    [model release];
    //[self.xmlType release];
    //[self.type release];
    [super dealloc];
}

@end
