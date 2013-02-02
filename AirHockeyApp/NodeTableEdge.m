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

const int NODE_1_AND_6_LIMIT_Y = 25;
const int NODE_3_AND_4_LIMIT_X = 50;

GLfloat edgeColor[NB_OF_TRIANGLE*3*4];
GLfloat nodeHeight = 4.1f;

- (id) initWithCoordsAndIndex:(float)x :(float)y :(int)index
{
    if((self = [super init])) {
        self.type = @"EDGE";
        self.xmlType = @"PointControle";
        self.isRemovable = NO;
        
        self.isCopyable = NO;
        self.isScalable = NO;
        self.index = index;
        self.position = Vector3DMake(x, y, nodeHeight);
        self.lastPosition = Vector3DMake(x, y, nodeHeight);
        
        [self initTriangleColors];
    }
    return self;
}

// Render a NodeTableEdge
- (void)render
{
    // Test if node out of its bounds
    [self checkIfOutOfBounds];
    
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
    glDisable(GL_TEXTURE_2D);
    glPushMatrix();
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, edgeColor);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3*NB_OF_TRIANGLE);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);

    
    self.lastPosition = self.position;
}

// Color array initialization (TEMPORARY)
- (void) initTriangleColors
{
    for (int i = 0; i < NB_OF_TRIANGLE*3*4; i += 4) {
        edgeColor[i] = 0;
        edgeColor[i+1] = 0;
        edgeColor[i+2] = 1;
        edgeColor[i+3] = 1;
    }
}

// Make sure that the node stays within some arbitrary limits
- (void) checkIfOutOfBounds
{
    // Check if the node can be moved either vertically or horizontally (Node 1 and 6 Vert., Node 3 and 4 Hor.)
    if(self.index == 1 || self.index == 6){
        self.position = Vector3DMake(0, self.position.y, nodeHeight);
    } else if (self.index == 3 || self.index == 4){
        self.position = Vector3DMake(self.position.x, 0, nodeHeight);
    }
    
    // Check if the node is inside the edition surface (in X and Y) 
    if(self.position.x >= TABLE_LIMIT_X) {
        self.position = Vector3DMake(TABLE_LIMIT_X,self.position.y,self.position.z);
    } else if(self.position.x <= -TABLE_LIMIT_X) {
        self.position = Vector3DMake(-TABLE_LIMIT_X,self.position.y,self.position.z);
    }
    
    if(self.position.y >= TABLE_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,TABLE_LIMIT_Y,self.position.z);
    } else if(self.position.y <= -TABLE_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,-TABLE_LIMIT_Y,self.position.z);
    }
    
    // Check that the table proportions don't get too funky
    if(self.index == 1 && self.position.y <= NODE_1_AND_6_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,NODE_1_AND_6_LIMIT_Y,self.position.z);
        
    } else if(self.index == 6 && self.position.y >= -NODE_1_AND_6_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,-NODE_1_AND_6_LIMIT_Y,self.position.z);
        
    } else if(self.index == 3 && self.position.x >= -NODE_3_AND_4_LIMIT_X) {
        self.position = Vector3DMake(-NODE_3_AND_4_LIMIT_X,self.position.y,self.position.z);
        
    } else if(self.index == 4 && self.position.x <= NODE_3_AND_4_LIMIT_X) {
        self.position = Vector3DMake(NODE_3_AND_4_LIMIT_X,self.position.y,self.position.z);
        
    } else if(self.index == 4 && self.position.x <= NODE_3_AND_4_LIMIT_X) {
        self.position = Vector3DMake(NODE_3_AND_4_LIMIT_X,self.position.y,self.position.z);
        
    }
}

@end
