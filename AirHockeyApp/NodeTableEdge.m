//
//  NodeTableEdge.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-17.
//
//

#import "NodeTableEdge.h"

@implementation NodeTableEdge
@synthesize goalSize;

const int NB_OF_TRIANGLE = 8;
const int EDGE_SIZE = 2.1f;

const int NODE_1_AND_6_LIMIT_Y = 40;
const int NODE_3_AND_4_LIMIT_X = 55;

GLfloat edgeColor[NB_OF_TRIANGLE*3*4];
GLfloat selectedEdgeColor[NB_OF_TRIANGLE*3*4];
GLfloat nodeHeight = 5.2;

- (id) initWithCoordsAndIndex:(float)x :(float)y :(int)index
{
    if((self = [super init])) {
        self.type = @"EDGE";
        self.xmlType = @"pointControle";
        self.isRemovable = NO;
        
        self.isCopyable = NO;
        self.isScalable = NO;
        self.index = index;
        self.goalSize = 5.0f;
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
    
    glDisable(GL_LIGHTING);
//    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
//    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, matDiffuse);
//    float ambient[] = { 1.0, 1, 1, 1 };
//    float specular[] = { 1, 0, 1, 1 };
//    
//    glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
//    glLightfv(GL_LIGHT0, GL_SPECULAR, specular);
    
    if(self.index != 3 && self.index != 4){
        [self renderCorner];
    } else if(self.index == 3){ // Left Goal
        [self renderleftGoal];
    } else if(self.index == 4){ // Right Goal
        [self renderRightGoal];
    }
    glEnable(GL_LIGHTING);

    self.lastPosition = self.position;
}

// Color array initialization (TEMPORARY)
- (void) initTriangleColors
{
    for (int i = 0; i < NB_OF_TRIANGLE*3*4; i += 4) {
        edgeColor[i] = 0.4f;
        edgeColor[i+1] = 0.4f;
        edgeColor[i+2] = 0.4f;
        edgeColor[i+3] = 1;
    }
    
    for (int i = 0; i < NB_OF_TRIANGLE*3*4; i += 4) {
        selectedEdgeColor[i] = 1;
        selectedEdgeColor[i+1] = 1;
        selectedEdgeColor[i+2] = 0.4f;
        selectedEdgeColor[i+3] = 1;
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

- (void)renderCorner
{
    GLfloat vertices[] = {
        // Triangle 1
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        
        // Triangle 2
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        
        // Triangle 3
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        
        // Triangle 4
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        
        // Triangle 5
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        
        // Triangle 6
        self.position.x + EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        self.position.x + EDGE_SIZE, self.position.y + EDGE_SIZE,-nodeHeight,
        
        // Triangle 7
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,-nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
        
        // Triangle 8
        self.position.x - EDGE_SIZE, self.position.y + EDGE_SIZE,-nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,-nodeHeight,
        self.position.x - EDGE_SIZE, self.position.y - EDGE_SIZE,nodeHeight,
    };
    
    glDisable(GL_TEXTURE_2D);
    glPushMatrix();
    
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    if(!self.isSelected){
        glColorPointer(4, GL_FLOAT, 0, edgeColor);
    } else {
        glColorPointer(4, GL_FLOAT, 0, selectedEdgeColor);
    }
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3*NB_OF_TRIANGLE);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);
}

- (void) renderleftGoal
{
    float height = 10;
    GLfloat vertices[] = {
        // Triangle 1
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x - EDGE_SIZE -1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        
        // Triangle 2
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x + EDGE_SIZE +1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        
        // Triangle 5
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize ,nodeHeight +1,
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize ,-nodeHeight/height,
        self.position.x + EDGE_SIZE +1, self.position.y + EDGE_SIZE*goalSize ,nodeHeight +1,
        
        // Triangle 6
        self.position.x + EDGE_SIZE +1, self.position.y + EDGE_SIZE*goalSize,nodeHeight +1,
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize,-nodeHeight/height,
        self.position.x + EDGE_SIZE +1, self.position.y + EDGE_SIZE*goalSize,-nodeHeight/height,
    };
    
    GLfloat redColor[] = {
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1,
        1,0,0,1
    };
    
    glDisable(GL_TEXTURE_2D);
    glPushMatrix();
        
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, redColor);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3*4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);

}

- (void) renderRightGoal
{
    float height = 10;
    GLfloat vertices[] = {
        // Triangle 1
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x - EDGE_SIZE -1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        
        // Triangle 2
        self.position.x + EDGE_SIZE +1, self.position.y - EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x + EDGE_SIZE +1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,nodeHeight+1,
        
        // Triangle 7
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,nodeHeight +1,
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,-nodeHeight/height,
        self.position.x - EDGE_SIZE -1, self.position.y - EDGE_SIZE*goalSize,nodeHeight +1,
        
        // Triangle 8
        self.position.x - EDGE_SIZE -1, self.position.y + EDGE_SIZE*goalSize,-nodeHeight/height,
        self.position.x - EDGE_SIZE -1, self.position.y - EDGE_SIZE*goalSize,-nodeHeight/height,
        self.position.x - EDGE_SIZE -1, self.position.y - EDGE_SIZE*goalSize,nodeHeight +1,
    };
    
    GLfloat blueColor[] = {
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1,
        0,0,1,1
    };
    
    glDisable(GL_TEXTURE_2D);
    glPushMatrix();
        
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glColorPointer(4, GL_FLOAT, 0, blueColor);

    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 3*4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);
}

@end
