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
    CGPoint limits[4];
    GLfloat topColors[40];
    GLfloat borderColors[40];
}
@end

@implementation NodeTable 

- (id) init
{
    if((self = [super init])) {
        
        self.type = @"TABLE";
        self.isRemovable = NO;
        
        [self initTableEdges];
        [self initColors];
    }
    return self;
}

// Render the table, edges, and borders (close to a composite pattern)
- (void) render
{
    // Update Edges positions to correct the table's symetry
    [self updateEdgesPositions];
    
    // Renders the table's Edges (call the rendering func on children nodes)
    for (int i = 0; i < NB_OF_TABLE_EDGES; i++) {
        [edges[i] render];
    }
    glDisable(GL_TEXTURE_2D);
    glPushMatrix();
    
    // Draw the top surface 
    [self drawTopSurface];
    
    // Draw the borders
    [self drawBorders];
    
    // Draw the limits
    [self drawLimits];
    
    glPopMatrix();
    glEnable(GL_TEXTURE_2D);

}

#pragma mark - Secondary Initialization functions
// TEMP : initialize GL color buffers
- (void) initColors
{
    for (int i = 0; i < (2+NB_OF_TRIANGLES)*4; i += 4) {
        topColors[i] = 0.9;
        topColors[i+1] = 0.9;
        topColors[i+2] = 1;
        topColors[i+3] = 1;
    }
    
    for (int i = 0; i < (2+NB_OF_TRIANGLES)*4; i += 4) {
        borderColors[i] = 1;
        borderColors[i+1] = 0;
        borderColors[i+2] = 0;
        borderColors[i+3] = 1;
    }
}

// Creates and position the table's edges in a required order
- (void) initTableEdges
{
    /* F*cking stupid table placement inherited from Projet2 (done by me :D)
     0-----1------2
     |     |      |
     3---center---4
     |     |      |
     5-----6------7
     */
    
    int initialX = 54;
    int initialY = 36;
    
    // Initialize all of the 8 table edges
    edges[0] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   -initialX   :initialY   :0]autorelease];
    edges[1] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   0           :initialY   :1]autorelease];
    edges[2] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   initialX    :initialY   :2]autorelease];
    edges[3] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   -initialX   :0          :3]autorelease];
    edges[4] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   initialX    :0          :4]autorelease];
    edges[5] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   -initialX   :-initialY  :5]autorelease];
    edges[6] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   0           :-initialY  :6]autorelease];
    edges[7] = [[[NodeTableEdge alloc]initWithCoordsAndIndex:   initialX    :-initialY  :7]autorelease];
    
    // Initialize the zone limits
    limits[0] = CGPointMake(-TABLE_LIMIT_X, TABLE_LIMIT_Y);
    limits[1] = CGPointMake(-TABLE_LIMIT_X, -TABLE_LIMIT_Y);
    limits[2] = CGPointMake(TABLE_LIMIT_X, -TABLE_LIMIT_Y);
    limits[3] = CGPointMake(TABLE_LIMIT_X, TABLE_LIMIT_Y);
}

#pragma mark - Pseudo Update Functions
// Add all edges in the RenderingTree hierarchicaly
- (void) addEdgesToTree
{
    for (int i = 0; i < NB_OF_TABLE_EDGES; i++) {
        [[Scene getInstance].renderingTree addNodeToTree:edges[i]];
    }
}

// Required to update the symetry of the table's edges
- (void) updateEdgesPositions
{
    // Top Corners
    if(edges[0].lastPosition.x != edges[0].position.x || edges[0].lastPosition.y != edges[0].position.y) {
        edges[2].position = Vector3DMake(-edges[0].position.x, edges[0].position.y, edges[2].position.z);
        
    } else if(edges[2].lastPosition.x != edges[2].position.x || edges[2].lastPosition.y != edges[2].position.y) {
        edges[0].position = Vector3DMake(-edges[2].position.x, edges[2].position.y, edges[0].position.z);
    }
    
    // Vertical Middle Edges
    if(edges[1].lastPosition.y != edges[1].position.y) {
        edges[6].position = Vector3DMake(edges[6].position.x, -edges[1].position.y, edges[6].position.z);
        
    } else if(edges[6].lastPosition.y != edges[6].position.y) {
        edges[1].position = Vector3DMake(edges[1].position.x, -edges[6].position.y, edges[1].position.z);
    }
    
    // Bottom Corners
    if(edges[5].lastPosition.x != edges[5].position.x || edges[5].lastPosition.y != edges[5].position.y) {
        edges[7].position = Vector3DMake(-edges[5].position.x, edges[5].position.y, edges[7].position.z);
        
    } else if(edges[7].lastPosition.x != edges[7].position.x || edges[7].lastPosition.y != edges[7].position.y) {
        edges[5].position = Vector3DMake(-edges[7].position.x, edges[7].position.y, edges[5].position.z);
    }
    
    // Horizontal Middle Edges
    if(edges[3].lastPosition.y != edges[3].position.y) {
        edges[4].position = Vector3DMake(-edges[3].position.x, edges[4].position.y, edges[4].position.z);
         
    } else if(edges[4].lastPosition.y != edges[4].position.y) {
        edges[3].position = Vector3DMake(-edges[4].position.x, edges[3].position.y, edges[3].position.z);
    }
}

#pragma mark - OpenGL Drawing Statements
// Draw the top surface 
- (void) drawTopSurface
{
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
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH
    };
    
    glVertexPointer(3, GL_FLOAT, 0, topVertices);
    glColorPointer(4, GL_FLOAT, 0, topColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 2+NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

// Draw the borders of the table.  Currently only a line
- (void) drawBorders
{
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
        edges[0].position.x,edges[0].position.y,TABLE_DEPTH
    };
    
    glVertexPointer(3, GL_FLOAT, 0, borderVertices);
    glColorPointer(4, GL_FLOAT, 0, borderColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glLineWidth(6.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 2+NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

// Draw the limits of the table
- (void) drawLimits
{
    GLfloat limitsVertices[] = {
        //            * Zone Limits *
        limits[0].x,limits[0].y,TABLE_DEPTH,
        limits[1].x,limits[1].y,TABLE_DEPTH,
        limits[2].x,limits[2].y,TABLE_DEPTH,
        limits[3].x,limits[3].y,TABLE_DEPTH,
    };
    
    glVertexPointer(3, GL_FLOAT, 0, limitsVertices);
    glColorPointer(4, GL_FLOAT, 0, borderColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glLineWidth(8.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

@end
