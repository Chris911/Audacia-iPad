//
//  NodeTable.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//
//

#import "Scene.h"
#import "NodeTable.h"
#import "NodeTableEdge.h"

@interface NodeTable()
{
    NodeTableEdge *edges[8];
}

@end

@implementation NodeTable 

const int NB_OF_TRIANGLES = 8;
const int NB_OF_TABLE_EDGES = 8;
const GLfloat TABLE_DEPTH = 0;

GLfloat topColors[(2+NB_OF_TRIANGLES)*4];
GLfloat borderColors[(2+NB_OF_TABLE_EDGES)*4];


- (id) init
{
    if((self = [super init])) {
        
        self.type = @"TABLE";
        self.isSelectable = NO;
        
        [self initTableEdges];
        [self initColors];
    }
    return self;
}

- (void) render
{
    // Renders the table's edges
    for (int i = 0; i < NB_OF_TABLE_EDGES; i++) {
        [edges[i] render];
    }
    
    GLfloat topVertices[] = {
        //            * Table's surface *
        0,0,TABLE_DEPTH,
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH,
        edges[1].position.x,edges[1].position.y,TABLE_DEPTH,
        edges[2].position.x,edges[2].position.y,TABLE_DEPTH,
        edges[4].position.x,edges[4].position.y,TABLE_DEPTH,
        edges[7].position.x,edges[7].position.y,TABLE_DEPTH,
        edges[6].position.x,edges[6].position.y,TABLE_DEPTH,
        edges[5].position.x,edges[5].position.y,TABLE_DEPTH,
        edges[3].position.x,edges[3].position.y,TABLE_DEPTH,
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH,
    };
    
    GLfloat borderVertices[] = {
        //            * Table's border *
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH,
        edges[1].position.x,edges[1].position.y,TABLE_DEPTH,
        edges[2].position.x,edges[2].position.y,TABLE_DEPTH,
        edges[4].position.x,edges[4].position.y,TABLE_DEPTH,
        edges[7].position.x,edges[7].position.y,TABLE_DEPTH,
        edges[6].position.x,edges[6].position.y,TABLE_DEPTH,
        edges[5].position.x,edges[5].position.y,TABLE_DEPTH,
        edges[3].position.x,edges[3].position.y,TABLE_DEPTH,
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH,
    };
    
    glPushMatrix();
    
    // Draw the top surface
    glVertexPointer(3, GL_FLOAT, 0, topVertices);
    glColorPointer(4, GL_FLOAT, 0, topColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glDrawArrays(GL_TRIANGLE_FAN, 0, 2+NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    // Draw the border
    glVertexPointer(3, GL_FLOAT, 0, borderVertices);
    glColorPointer(4, GL_FLOAT, 0, borderColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glLineWidth(5.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 2+NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glPopMatrix();
}

- (void) initColors
{
    for (int i = 0; i < (2+NB_OF_TRIANGLES)*4; i += 4) {
        topColors[i] = 1;
        topColors[i+1] = 0;
        topColors[i+2] = 0;
        topColors[i+3] = 1;
    }
    
    for (int i = 0; i < (2+NB_OF_TRIANGLES)*4; i += 4) {
        borderColors[i] = 1;
        borderColors[i+1] = 1;
        borderColors[i+2] = 0;
        borderColors[i+3] = 1;
    }
}

- (void) initTableEdges
{
    /* F*cking stupid table placement inherited from Projet2 (done by me :D)
     0-----1------2
     |     |      |
     |     |      |
     3---centre---4
     |     |      |
     |     |      |
     5-----6------7
     */
    
    edges[0] = [[[NodeTableEdge alloc]initWithCoords:-70 :50]autorelease];
    edges[1] = [[[NodeTableEdge alloc]initWithCoords:0 :50]autorelease];
    edges[2] = [[[NodeTableEdge alloc]initWithCoords:70 :50]autorelease];
    edges[3] = [[[NodeTableEdge alloc]initWithCoords:-70 :0]autorelease];
    edges[4] = [[[NodeTableEdge alloc]initWithCoords:70 :0]autorelease];
    edges[5] = [[[NodeTableEdge alloc]initWithCoords:-70 :-50]autorelease];
    edges[6] = [[[NodeTableEdge alloc]initWithCoords:0 :-50]autorelease];
    edges[7] = [[[NodeTableEdge alloc]initWithCoords:70 :-50]autorelease];
    
    [[Scene getInstance].renderingTree addNodeToTree:edges[0]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[1]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[2]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[3]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[4]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[5]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[6]];
    [[Scene getInstance].renderingTree addNodeToTree:edges[7]];

}

@end
