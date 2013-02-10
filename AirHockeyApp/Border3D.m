//
//  Border3D.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-30.
//
//

#import "Border3D.h"
#import "Texture2DUtil.h"   
@interface Border3D ()
{
    GLuint      texture[1];
}
@end

@implementation Border3D


- (id) initWithStartAndEndPoints:(Vector3D)startPt :(Vector3D)endPt
{
    if((self = [super init])) {
        self.begPt = startPt;
        self.endPt = endPt;
        
        glGenTextures(1, &texture[0]);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        
        [Texture2DUtil load2DTextureFromName:@"border"];

    }
    return self;
}

- (void) drawVertices
{
    GLfloat sideVertices[] = {

        // Sides
        self.v1.x,self.v1.y,self.v1.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v3.x,self.v3.y,self.v3.z,
        
        self.v3.x,self.v3.y,self.v3.z,
        self.v4.x,self.v4.y,self.v4.z,
        self.v1.x,self.v1.y,self.v1.z,
        
        self.v4.x,self.v4.y,self.v4.z,
        self.v3.x,self.v3.y,self.v3.z,
        self.v5.x,self.v5.y,self.v5.z,
        
        self.v4.x,self.v4.y,self.v4.z,
        self.v5.x,self.v5.y,self.v5.z,
        self.v6.x,self.v6.y,self.v6.z,
        
        self.v8.x,self.v8.y,self.v8.z,
        self.v7.x,self.v7.y,self.v7.z,
        self.v6.x,self.v6.y,self.v6.z,

        self.v6.x,self.v6.y,self.v6.z,
        self.v7.x,self.v7.y,self.v7.z,
        self.v5.x,self.v5.y,self.v5.z,

        self.v1.x,self.v1.y,self.v1.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v8.x,self.v8.y,self.v8.z,

        self.v8.x,self.v8.y,self.v8.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v7.x,self.v7.y,self.v7.z,

//        // Top
//        self.v8.x,self.v8.y,self.v8.z,
//        self.v1.x,self.v1.y,self.v1.z,
//        self.v6.x,self.v6.y,self.v6.z,
//        
//        self.v6.x,self.v6.y,self.v6.z,
//        self.v1.x,self.v1.y,self.v1.z,
//        self.v4.x,self.v4.y,self.v4.z,
        
        //Bottom
        self.v7.x,self.v7.y,self.v7.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v5.x,self.v5.y,self.v5.z,
        
        self.v5.x,self.v5.y,self.v5.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v3.x,self.v3.y,self.v3.z

    };
    
    glVertexPointer(3, GL_FLOAT, 0, sideVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glDrawArrays(GL_TRIANGLES, 0, 10*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    
    GLfloat topVertices[] = {
        // Top
        self.v8.x,self.v8.y,self.v8.z,
        self.v1.x,self.v1.y,self.v1.z,
        self.v6.x,self.v6.y,self.v6.z,
        
        self.v6.x,self.v6.y,self.v6.z,
        self.v1.x,self.v1.y,self.v1.z,
        self.v4.x,self.v4.y,self.v4.z,
    };
    
    GLfloat topTex[] = {
        // Top
        1,0,
        0,0,
        0,1,
        1,1,
    };
    
    // Light normals and material
    glNormal3f(0, 0, 1);
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    // Texture Binding
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, topTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);

    glVertexPointer(3, GL_FLOAT, 0, topVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glNormal3f(0, 0, 0);

}

- (void) setNewPosition:(Vector3D)begPt :(Vector3D)endPt :(BOOL)isVertical
{
    int zValue = 2;
    int yValue = 1;
    int xValue = 1;
    
    self.begPt = begPt;
    self.endPt = endPt;
    
    if(!isVertical){
        self.v1 = Vector3DMake(self.begPt.x, self.begPt.y - yValue , zValue);
        self.v2 = Vector3DMake(self.begPt.x, self.begPt.y - yValue , -zValue);
        
        self.v3 = Vector3DMake(self.endPt.x, self.endPt.y - yValue , -zValue);
        self.v4 = Vector3DMake(self.endPt.x, self.endPt.y - yValue , zValue);
        self.v5 = Vector3DMake(self.endPt.x, self.endPt.y + yValue , -zValue);
        self.v6 = Vector3DMake(self.endPt.x, self.endPt.y + yValue , zValue);
        
        self.v7 = Vector3DMake(self.begPt.x, self.begPt.y + yValue , -zValue);
        self.v8 = Vector3DMake(self.begPt.x, self.begPt.y + yValue , zValue);
        
    } else {
        self.v1 = Vector3DMake(self.begPt.x - xValue, self.begPt.y, zValue);
        self.v2 = Vector3DMake(self.begPt.x - xValue, self.begPt.y, -zValue);
        self.v3 = Vector3DMake(self.endPt.x - xValue, self.endPt.y, -zValue);
        self.v4 = Vector3DMake(self.endPt.x - xValue, self.endPt.y, zValue);
        
        self.v5 = Vector3DMake(self.endPt.x + xValue, self.endPt.y , -zValue);
        self.v6 = Vector3DMake(self.endPt.x + xValue, self.endPt.y , zValue);
        self.v7 = Vector3DMake(self.begPt.x + xValue, self.begPt.y , -zValue);
        self.v8 = Vector3DMake(self.begPt.x + xValue, self.begPt.y , zValue);
    }
}

@end
