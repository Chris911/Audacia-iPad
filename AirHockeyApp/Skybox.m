//
//  Skybox.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-10.
//
//

#import "Skybox.h"
#import "Texture2DUtil.h"

@interface Skybox ()
{
    GLuint      texture[1];
}
@end

@implementation Skybox

- (id) initWithSize:(float) size
{
    if((self = [super init])) {
        glGenTextures(1, &texture[0]);
        glBindTexture(GL_TEXTURE_2D, texture[0]);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
                
        [Texture2DUtil load2DTextureFromName:@"skybox"];
        
        self.v1 = Vector3DMake(-size, size, -size);
        self.v2 = Vector3DMake(-size, -size, -size);
        self.v3 = Vector3DMake(size, -size, -size);
        self.v4 = Vector3DMake(size, size, -size);
        
        self.v5 = Vector3DMake(-size, size, size);
        self.v6 = Vector3DMake(-size, -size, size);
        self.v7 = Vector3DMake(size, -size, size);
        self.v8 = Vector3DMake(size, size, size);

        
    }
    return self;
}

- (void) render
{
    glEnable(GL_TEXTURE_2D);
    glCullFace(GL_BACK);
    glEnable(GL_CULL_FACE);

    //glDisable(GL_LIGHTING);
    [self renderBottom];
    [self renderSideA];
    [self renderSideB];
    [self renderSideC];
    [self renderSideD];
    //glEnable(GL_LIGHTING);
    glDisable(GL_CULL_FACE);
    glCullFace(GL_FRONT);
    glDisable(GL_TEXTURE_2D);

}

- (void) renderBottom
{
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    GLfloat botVertices[] = {
        self.v1.x,self.v1.y,self.v1.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v3.x,self.v3.y,self.v3.z,
        
        self.v3.x,self.v3.y,self.v3.z,
        self.v4.x,self.v4.y,self.v4.z,
        self.v1.x,self.v1.y,self.v1.z,
    };
    
    GLfloat botTex[] = {
        0.25, 0.75,
        0.25, 0.5,
        0.5,  0.5,
        
        0.5, 0.5,
        0.5, 0.75,
        0.25, 0.75
    };
    
    glNormal3f(0, 0, 1);
    
    glVertexPointer(3, GL_FLOAT, 0, botVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, botTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    if(glGetError() != 0)
        NSLog(@"%u",glGetError());
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);

}

- (void) renderSideA
{
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    GLfloat botVertices[] = {
        self.v5.x,self.v5.y,self.v5.z,
        self.v1.x,self.v1.y,self.v1.z,
        self.v4.x,self.v4.y,self.v4.z,
        
        self.v4.x,self.v4.y,self.v4.z,
        self.v8.x,self.v8.y,self.v8.z,
        self.v5.x,self.v5.y,self.v5.z,
    };
    
    GLfloat botTex[] = {
        0,1,
        0,0,
        1,0,
        
        1,0,
        1,1,
        0,1
    };
    
    glNormal3f(0, -1, 0);
    
    glVertexPointer(3, GL_FLOAT, 0, botVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, botTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

- (void) renderSideB
{
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    GLfloat botVertices[] = {
        self.v8.x,self.v8.y,self.v8.z,
        self.v4.x,self.v4.y,self.v4.z,
        self.v3.x,self.v3.y,self.v3.z,
        
        self.v3.x,self.v3.y,self.v3.z,
        self.v7.x,self.v7.y,self.v7.z,
        self.v8.x,self.v8.y,self.v8.z,
    };
    
    GLfloat botTex[] = {
        0,1,
        0,0,
        1,0,
        
        1,0,
        1,1,
        0,1
    };
    
    glNormal3f(1, 0, 0);
    
    glVertexPointer(3, GL_FLOAT, 0, botVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, botTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

- (void) renderSideC
{
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    GLfloat botVertices[] = {
        self.v6.x,self.v6.y,self.v6.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v3.x,self.v3.y,self.v3.z,
        
        self.v3.x,self.v3.y,self.v3.z,
        self.v7.x,self.v7.y,self.v7.z,
        self.v6.x,self.v6.y,self.v6.z,
    };
    
    GLfloat botTex[] = {
        0,1,
        0,0,
        1,0,
        
        1,0,
        1,1,
        0,1
    };
    
    glNormal3f(0, 1, 0);
    
    glVertexPointer(3, GL_FLOAT, 0, botVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, botTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

- (void) renderSideD
{
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, matAmbient);
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, matDiffuse);
    glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse);
    
    GLfloat botVertices[] = {
        self.v6.x,self.v6.y,self.v6.z,
        self.v2.x,self.v2.y,self.v2.z,
        self.v1.x,self.v1.y,self.v1.z,
        
        self.v1.x,self.v1.y,self.v1.z,
        self.v5.x,self.v5.y,self.v5.z,
        self.v6.x,self.v6.y,self.v6.z,
    };
    
    GLfloat botTex[] = {
        0,1,
        0,0,
        1,0,
        
        1,0,
        1,1,
        0,1
    };
    
    glNormal3f(1, 0, 0);
    
    glVertexPointer(3, GL_FLOAT, 0, botVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glBindTexture(GL_TEXTURE_2D, texture[0]);
    glTexCoordPointer(2, GL_FLOAT, 0, botTex);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glDrawArrays(GL_TRIANGLES, 0, 2*3);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

@end
