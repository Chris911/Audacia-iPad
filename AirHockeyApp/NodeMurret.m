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
@synthesize CoeffRebond;

- (id) init
{
    if((self = [super init])) {
        self.isWaveFrontObject = YES;
        self.type = @"MURRET";
        self.xmlType = @"murret";

        NSString *path = [[NSBundle mainBundle] pathForResource:@"mur" ofType:@"obj"];
        OpenGLWaveFrontObject *theObject = [[OpenGLWaveFrontObject alloc] initWithPath:path];
        Vertex3D position = Vertex3DMake(0, 0, 20.0);
        self.model = theObject;
        self.position = position;
        self.model.currentPosition = self.position;
        self.CoeffRebond = 1.0f;
        [theObject release];
    }
    return self;
}

- (void) render
{
    // Bounding box visible if selected
    if(self.isSelected){
        glDisable(GL_LIGHTING);

        int offset = GLOBAL_SIZE_OFFSET * self.scaleFactor;
        
        GLfloat Vertices[] = {
            self.position.x - offset, self.position.y + offset, self.position.z,
            self.position.x - offset, self.position.y - offset, self.position.z,
            self.position.x + offset, self.position.y - offset, self.position.z,
            self.position.x + offset, self.position.y + offset, self.position.z,
            
        };        
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        glVertexPointer(3, GL_FLOAT, 0, Vertices);
        glColorPointer(4, GL_FLOAT, 0, selectionColor);
        
        if(glGetError() != 0)
            NSLog(@"%u",glGetError());
        
        glDrawArrays(GL_LINE_LOOP, 0, 4);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);

        glEnable(GL_LIGHTING);
    }

    // Update the 3D Model Position
    self.model.currentPosition = self.position;
    
    // Save the current transformation by pushing it on the stack
	glPushMatrix();
    glDisable(GL_BLEND);
    //glBlendFunc(GL_ONE, GL_SRC_ALPHA);    
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
    glEnable(GL_BLEND);
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

- (void) dealloc
{
    [model release];
    //[self.xmlType release];
    //[self.type release];
    [super dealloc];
}

@end
