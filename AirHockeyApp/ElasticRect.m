//
//  ElasticRect.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-02.
//
//

#import "ElasticRect.h"
#import "OpenGLWaveFrontCommon.h"

@implementation ElasticRect

@synthesize beginPosition;
@synthesize endPosition;
@synthesize dimension;
@synthesize isActive;

GLfloat colors[] = {
    0,1,1,1,
    1,0,1,1,
    1,1,0,1,
    0,1,0,1
};

- (id) init
{
    if((self = [super init])) {
        [self reset];
    }
    return self;
}

- (void) reset
{
    self.beginPosition = CGPointMake(0, 0);
    self.endPosition = CGPointMake(0, 0);
    self.dimension = CGPointMake(0, 0);
    self.isActive = NO;
}

- (void) modifyRect:(CGPoint)curentPoint:(CGPoint)lastPoint
{
    float deltaX = curentPoint.x - lastPoint.x;
    float deltaY = curentPoint.y - lastPoint.y;
    
    self.dimension = CGPointMake(self.dimension.x + deltaX, self.dimension.y + deltaY);
}

- (void) render
{
    glPushMatrix();
    int zvalue = 4;
    GLfloat vertices[] = {
        self.beginPosition.x,self.beginPosition.y,zvalue,
        self.beginPosition.x,self.endPosition.y,zvalue,
        self.endPosition.x,self.endPosition.y,zvalue,
        self.endPosition.x,self.beginPosition.y,zvalue,
    };
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    glLineWidth(2.0f);

    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

    
    glPopMatrix();
}

@end
