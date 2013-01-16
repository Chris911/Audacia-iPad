//
//  NodeTable.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//
//

#import "NodeTable.h"

@implementation NodeTable

const int NB_OF_TRIANGLES = 8;
const GLfloat TABLE_DEPTH = 0;
GLfloat colors[NB_OF_TRIANGLES*3*4];

- (id) init
{
    if((self = [super init])) {
        self.type = @"TABLE";
        [self initCircleColors];
    }
    return self;
}

- (void) render
{
    GLfloat vertices[] = {
        // -------------- Rectangle 1 --------------
        // Triangle 1 
        -70,50,-TABLE_DEPTH,
        0,50,-TABLE_DEPTH,
        0,0,-TABLE_DEPTH,

        // Triangle 2
        0,0,-TABLE_DEPTH,
        -70,0,-TABLE_DEPTH,
        -70,50,-TABLE_DEPTH,

        // -------------- Rectangle 2 --------------
        // Triangle 3 
        70,50,-TABLE_DEPTH,
        0,50,-TABLE_DEPTH,
        0,0,-TABLE_DEPTH,
        
        // Triangle 4
        0,0,-TABLE_DEPTH,
        70,0,-TABLE_DEPTH,
        70,50,-TABLE_DEPTH,
        
        // -------------- Rectangle 3 --------------
        // Triangle 5 
        -70,-50,-TABLE_DEPTH,
        0,-50,-TABLE_DEPTH,
        0,0,-TABLE_DEPTH,
        
        // Triangle 6
        0,0,-TABLE_DEPTH,
        -70,0,-TABLE_DEPTH,
        -70,-50,-TABLE_DEPTH,
        
        // -------------- Rectangle 4 --------------
        // Triangle 7 
        70,-50,-TABLE_DEPTH,
        0,-50,-TABLE_DEPTH,
        0,0,-TABLE_DEPTH,
        
        // Triangle 8
        0,0,-TABLE_DEPTH,
        70,0,-TABLE_DEPTH,
        70,-50,-TABLE_DEPTH,
    };
    
    glPushMatrix();
    //glDisable(GL_BLEND);
    glEnable(GL_BLEND_SRC_ALPHA);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, colors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glDrawArrays(GL_TRIANGLES, 0, 3*NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
}

- (void) initCircleColors
{
    for (int i = 0; i < NB_OF_TRIANGLES*3*4; i += 4) {
        colors[i] = 1;
        colors[i+1] = 0;
        colors[i+2] = 0;
        colors[i+3] = 1;
    }
}

@end
