//
//  NodeTableEdge.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-17.
//
//

#import "NodeTableEdge.h"

@implementation NodeTableEdge

const int NB_OF_TRIANGLE = 2;
const int EDGE_SIZE = 3;
GLfloat edgeColor[NB_OF_TRIANGLE*3*4];
GLfloat nodeHeight = 0.0f;

- (id) initWithCoordsAndIndex:(float)x :(float)y :(int)index
{
    if((self = [super init])) {
        self.type = @"EDGE";
        self.isSelectable = YES;
        
        self.index = index;
        self.position = Vector3DMake(x, y, nodeHeight);
        self.lastPosition = Vector3DMake(x, y, nodeHeight);
        
        [self initTriangleColors];
    }
    return self;
}

- (void)render
{
    if(self.index == 1 || self.index == 6){
        self.position = Vector3DMake(0, self.position.y, nodeHeight);
    } else if (self.index == 3 || self.index == 4){
        self.position = Vector3DMake(self.position.x, 0, nodeHeight);
    }
    
    GLfloat vertices[] = {
        // Triangle 1
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        
        // Triangle 2
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
    };
    
    glPushMatrix();
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, edgeColor);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3*NB_OF_TRIANGLE);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
    
    self.lastPosition = self.position;
}

- (void) initTriangleColors
{
    for (int i = 0; i < NB_OF_TRIANGLE*3*4; i += 4) {
        edgeColor[i] = 0;
        edgeColor[i+1] = 0;
        edgeColor[i+2] = 1;
        edgeColor[i+3] = 1;
    }
}

@end
