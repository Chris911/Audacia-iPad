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
#import "Texture2DUtil.h"

@interface NodeTable()
{
    NodeTableEdge *edges[8];
    CGPoint     limits[4];
    GLfloat     topColors[40];
    GLfloat     borderColors[40];
    Border3D    *borders[8];
    GLuint      texture[1];

}
@end

@implementation NodeTable
@synthesize CoeffFriction;
@synthesize CoeffRebond;

- (id) init
{
    if((self = [super init])) {
        
        self.type = @"TABLE";
        self.isRemovable = NO;
        self.isCopyable = NO;
        self.isScalable = NO;

        self.CoeffRebond = 0.87f;
        self.CoeffFriction = 1.0f;
        
        [self initTableEdges];
        [self initColors];
        
        glGenTextures(1, &texture[0]);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

        [Texture2DUtil load2DTextureFromNamePVRTC:@"table" :512];
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
    glEnable(GL_TEXTURE_2D);
    glPushMatrix();
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    
    // Draw the top surface 
    [self drawTopSurface];
    
    glCullFace(GL_BACK);
    glDisable(GL_CULL_FACE);
    glDisable(GL_TEXTURE_2D);

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
    [self initTableLimits];
    
    // Initialize the 3D borders
    [self initTable3DBorders];

}

- (void) initTableEdgesFromXML:(NSArray*)newEdges
{
    if([newEdges count] != 8)
    {
        //This should not happen and if it does the table will be invalid
        NSLog(@"ERROR: Invalid number of edges in table");
        return;
    }
    
    for(int i=0; i<[newEdges count]; i++)
    {
        edges[i] = newEdges[i];
    }
    
    // Initialize the zone limits
    [self initTableLimits];
    
    // Initialize the 3D borders
    [self initTable3DBorders];
}

- (void) initTableLimits
{
    limits[0] = CGPointMake(-TABLE_LIMIT_X, TABLE_LIMIT_Y);
    limits[1] = CGPointMake(-TABLE_LIMIT_X, -TABLE_LIMIT_Y);
    limits[2] = CGPointMake(TABLE_LIMIT_X, -TABLE_LIMIT_Y);
    limits[3] = CGPointMake(TABLE_LIMIT_X, TABLE_LIMIT_Y);
}

- (void) initTable3DBorders
{
    borders[0] = [[Border3D alloc]initWithStartAndEndPoints:edges[0].position :edges[1].position];
    borders[1] = [[Border3D alloc]initWithStartAndEndPoints:edges[1].position :edges[2].position];
    borders[2] = [[Border3D alloc]initWithStartAndEndPoints:edges[2].position :edges[4].position];
    borders[3] = [[Border3D alloc]initWithStartAndEndPoints:edges[4].position :edges[7].position];
    borders[4] = [[Border3D alloc]initWithStartAndEndPoints:edges[6].position :edges[7].position];
    borders[5] = [[Border3D alloc]initWithStartAndEndPoints:edges[5].position :edges[6].position];
    borders[6] = [[Border3D alloc]initWithStartAndEndPoints:edges[3].position :edges[5].position];
    borders[7] = [[Border3D alloc]initWithStartAndEndPoints:edges[0].position :edges[3].position];
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
    
    // Prevent weird shapes
    int offset = 30;
    if(edges[0].position.x > -offset){
        edges[0].position = Vector3DMake(-offset, edges[0].position.y, edges[0].position.z);
    }
    
    if(edges[0].position.y < offset){
        edges[0].position = Vector3DMake(edges[0].position.x, offset, edges[0].position.z);
    }
    
    if(edges[2].position.x < offset){
        edges[2].position = Vector3DMake(offset, edges[2].position.y, edges[2].position.z);
    }
    
    if(edges[2].position.y < offset){
        edges[2].position = Vector3DMake(edges[2].position.x, offset, edges[2].position.z);
    }
    
    if(edges[5].position.x > -offset){
        edges[5].position = Vector3DMake(-offset, edges[5].position.y, edges[5].position.z);
    }
    
    if(edges[5].position.y > -offset){
        edges[5].position = Vector3DMake(edges[5].position.x, -offset, edges[5].position.z);
    }
    
    if(edges[7].position.x < offset){
        edges[7].position = Vector3DMake(offset, edges[7].position.y, edges[7].position.z);
    }
    
    if(edges[7].position.y > -offset){
        edges[7].position = Vector3DMake(edges[7].position.x, -offset, edges[7].position.z);
    }
    
    
}

#pragma mark - OpenGL Drawing Statements
// Draw the top surface 
- (void) drawTopSurface
{
    GLfloat topVertices[] = {
        //            * Table's surface *
        0,0,TABLE_HEIGHT,
        edges[0].position.x,edges[0].position.y,TABLE_HEIGHT,
        edges[1].position.x,edges[1].position.y,TABLE_HEIGHT,
        edges[2].position.x,edges[2].position.y,TABLE_HEIGHT,
        edges[4].position.x,edges[4].position.y,TABLE_HEIGHT,
        edges[7].position.x,edges[7].position.y,TABLE_HEIGHT,
        edges[6].position.x,edges[6].position.y,TABLE_HEIGHT,
        edges[5].position.x,edges[5].position.y,TABLE_HEIGHT,
        edges[3].position.x,edges[3].position.y,TABLE_HEIGHT,
        edges[0].position.x,edges[0].position.y,TABLE_HEIGHT
    };
    
    GLfloat topTextures[] = {
        //            * Table's surface *
        0.5, 0.25,        //mid
        0, 0.5,           //0
        0.5, 0.5,         //1
        1, 0.5,           //2
        1, 0.25,         //4
        1, 0,           //7
        0.5, 0,         //6
        0,0,            //5
        0,0.25,          //3
        0,0.5             //0
    };
    glNormal3f(0.0f, 0.0f, 1.0f);
    
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    // Texture Binding
    glBindTexture(GL_TEXTURE_2D, texture[0]);

    glVertexPointer(3, GL_FLOAT, 0, topVertices);
    glTexCoordPointer(2, GL_FLOAT, 0, topTextures);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    if(glGetError() != 0)
        NSLog(@"%u",glGetError());
    
    glDrawArrays(GL_TRIANGLE_FAN, 0, 2+NB_OF_TRIANGLES);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
}

// Draw the borders of the table.  Currently only a line
- (void) drawBorders
{
    BOOL vertical = YES;
    BOOL horizontal = NO;
    
    [borders[0] setNewPosition:edges[0].position :edges[1].position:horizontal];
    [borders[0] drawVertices];
    
    [borders[1] setNewPosition:edges[1].position :edges[2].position:horizontal];
    [borders[1] drawVertices];
    
    [borders[2] setNewPosition:edges[2].position :edges[4].position:vertical];
    [borders[2] drawVertices];
    
    [borders[3] setNewPosition:edges[4].position :edges[7].position:vertical];
    [borders[3] drawVertices];
    
    [borders[4] setNewPosition:edges[6].position :edges[7].position:horizontal];
    [borders[4] drawVertices];
    
    [borders[5] setNewPosition:edges[5].position :edges[6].position:horizontal];
    [borders[5] drawVertices];
    
    [borders[6] setNewPosition:edges[3].position :edges[5].position:vertical];
    [borders[6] drawVertices];
    
    [borders[7] setNewPosition:edges[0].position :edges[3].position:vertical];
    [borders[7] drawVertices];
    
}

// Draw the limits of the table
- (void) drawLimits
{
    GLfloat limitsVertices[] = {
        //            * Zone Limits *
        limits[0].x,limits[0].y,TABLE_HEIGHT,
        limits[1].x,limits[1].y,TABLE_HEIGHT,
        limits[2].x,limits[2].y,TABLE_HEIGHT,
        limits[3].x,limits[3].y,TABLE_HEIGHT,
    };
    
    glVertexPointer(3, GL_FLOAT, 0, limitsVertices);
    glColorPointer(4, GL_FLOAT, 0, borderColors);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glLineWidth(4.0f);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);
}

- (void) dealloc
{
    [super dealloc];
    [self.xmlType release];
    [self.type release];
    for (int i = 0; i < 8; i++) {
        [borders[i] release];
    }
}

@end
