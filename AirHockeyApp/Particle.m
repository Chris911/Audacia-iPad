//
//  Particles.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-03.
//
//

#import "Particle.h"
#include <stdlib.h>

@interface Particle ()
{
    float angle;
    Vector3D scale;
}

@end

@implementation Particle

@synthesize position;
@synthesize alpha;
@synthesize velocity;
@synthesize angle;

- (id) initWithCenterPosition:(CGPoint)point
{
    if((self = [super init])) {
        self.alpha = 1.0f;
        self.angle = self.angle * 3.1416/180;
        self.position = Vector3DMake(point.x * cosf(angle), point.y*cosf(angle), 2);
        
        self.velocity = [self makeRandomVectorWithRange:26:-25];
        scale = [self makeRandomVectorWithRange:1.5:0.5];
        self.velocity = Vector3DMake(velocity.x*0.1f, velocity.y*0.1f, 0);
    }
    return self;
}


- (void) render
{
    glPushMatrix();
    self.position = Vector3DAdd(self.position, self.velocity);
    
    glTranslatef(self.position.x, self.position.y, self.position.z);
    glRotatef(self.angle, 1, 1, 1);
    glScalef(scale.x, scale.y, scale.z);
    
    GLfloat verticesBuffer[] = {
        -1,1,0,
        -1,-1,0,
         1,-1,0,
        
         1,-1,0,
         1,1,0,
         -1,1,0,
        
        -1,1,0,
        -1,-1,0,
        0,0,1,
        
        -1,-1,0,
        1,-1,0,
        0,0,1,
        
        1,-1,0,
        1,1,0,
        0,0,1,
        
        1,1,0,
        -1,1,0,
        0,0,1,
    };
    
    float r = arc4random() % 255;
    float g = arc4random() % 255;
    float b = arc4random() % 255;
    
    GLfloat colorsBuffer[] = {
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
        r/255,g/255,b/255,self.alpha,
    };
    glVertexPointer(3, GL_FLOAT, 0, verticesBuffer);
    glColorPointer(4, GL_FLOAT, 0, colorsBuffer);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_LINE_LOOP, 0, 3*5); // Line loop 
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    self.alpha = self.alpha - 0.2f;
    angle += arc4random()%5;

    glPopMatrix();

}

- (Vector3D) makeRandomVectorWithRange:(int)maxValue : (int)minValue 
{
    float rndValue1 = (((float)arc4random()/0x100000000)*(maxValue-minValue)+minValue);
    float rndValue2 = (((float)arc4random()/0x100000000)*(maxValue-minValue)+minValue);
    return Vector3DMake(rndValue1, rndValue2, 0);
}

@end
