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
    Vector3D velocity;
    float alpha;
}

@end

@implementation Particle

@synthesize position;
@synthesize isActive;

- (id) init
{
    if((self = [super init])) {
        self.isActive = NO;
        scale = Vector3DMake(1, 1, 1);
        alpha = 1.0f;
        angle = 0.0f;
        
        velocity = [self makeRandomVectorWithRange:15:-15];
        velocity = Vector3DMake(velocity.x*0.1f, velocity.y*0.1f, 0);
    }
    return self;
}


- (void) render
{
    if(self.isActive){
        
        glPushMatrix();
        self.position = Vector3DAdd(self.position, velocity);
        glTranslatef(self.position.x, self.position.y, 2);
        glRotatef(angle, 0, 0, 1);
        glRotatef(angle, 1, 0, 0);


        glScalef(scale.x, scale.y, scale.z);
        
        GLfloat verticesBuffer[] = {
            -1,1,0,
            -1,-1,0,
             1,-1,0,
            
             1,-1,0,
             1,1,0,
             -1,1,0
        };
        
        GLfloat colorsBuffer[] = {
            1,0,0,alpha,
            1,0,0,alpha,
            1,0,0,alpha,
            1,0,0,alpha,
            1,0,0,alpha,
            1,0,0,alpha,
        };
        
        glVertexPointer(3, GL_FLOAT, 0, verticesBuffer);
        glColorPointer(4, GL_FLOAT, 0, colorsBuffer);

        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_COLOR_ARRAY);
        
        glDrawArrays(GL_TRIANGLES, 0, 3*2);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
        
        alpha = alpha - 0.01f;
        angle += arc4random()%5;
        glPopMatrix();
    }
}

- (Vector3D) makeRandomVectorWithRange:(int)maxValue:(int)minValue
{
    float rndValue1 = (((float)arc4random()/0x100000000)*(maxValue-minValue)+minValue);
    float rndValue2 = (((float)arc4random()/0x100000000)*(maxValue-minValue)+minValue);
    return Vector3DMake(rndValue1, rndValue2, 0);
}

@end
