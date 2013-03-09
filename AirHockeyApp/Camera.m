//
//  Camera.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-31.
//  Camera used to move around in the GL World
//  Also serves as an touch point converter to
//  keep the gl objects positions unchanged.
//  Modified from AppDemo project

#import "Camera.h"
#import <GLKit/GLKit.h>

@implementation Camera

@synthesize currentPosition;
@synthesize centerPosition;
@synthesize eyePosition;
@synthesize up;
@synthesize worldPosition;
@synthesize isPerspective;
@synthesize zoomFactor;
@synthesize orthoCenter;
@synthesize orthoHeight;
@synthesize orthoWidth;
@synthesize windowHeight;
@synthesize windowWidth;
@synthesize eyeToCenterDistance;
@synthesize theta;
@synthesize phi;

- (id) init
{
    if((self = [super init])) {
        [self resetCamera];
    }
    return self;
}
//float radius = 150;
#pragma mark - Reset camera
- (void) resetCamera
{
    // Perspective attributes
    self.currentPosition = Vector3DMake(0, 0, 0);
    
    self.centerPosition = Vector3DMake(0, 0, 0);
    self.eyePosition = Vector3DMake(0, 0, 0);
    self.up = Vector3DMake(0, 1, 0); // Camera orientend on Y axis
    eyeToCenterDistance = 160;
    self.phi = 40;
    self.theta = 90;
    
    // Ortho attributes
    self.isPerspective = YES;
    self.zoomFactor = CGPointMake(1, 1);
    
    self.orthoCenter = CGPointMake(0, 0);
    
    self.orthoHeight = HAUTEUR_FENETRE;
    self.orthoWidth = LARGEUR_FENETRE;
    
    self.windowHeight = HAUTEUR_ECRAN;
    self.windowWidth = LARGEUR_ECRAN;
    
    self.worldPosition = Vector3DMake(self.orthoCenter.x, self.orthoCenter.y,-1); //Z Ignored
}

- (void) setCamera
{
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    if(!self.isPerspective) { // Orthogonal Mode
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        
        // Orthogonal Mode
        glOrthof(self.orthoCenter.x - self.orthoWidth/2,
                 self.orthoCenter.x + self.orthoWidth/2,
                 self.orthoCenter.y - self.orthoHeight/2,
                 self.orthoCenter.y + self.orthoHeight/2,
                 -1000, 1000);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
    } else { // Perspective Mode
    
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluPerspective(60, self.windowWidth/ self.windowHeight, 0.1f, 1000);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        
        [self orbitAroundCenter];
        [self assginCamPosition];
    }
}

// Use a screenPosition and convert it to the current world position (inlcudes zoom and pan differences)
- (void) assignWorldPosition:(CGPoint)screenPos
{
    CGPoint cg_worldPos = [self convertFromScreenToWorld:screenPos];
    self.worldPosition = Vector3DMake(cg_worldPos.x + self.orthoCenter.x, cg_worldPos.y + self.orthoCenter.y, -1); // ignore Z
}

// Translate position when in ortho mode
- (void) orthoTranslate:(CGPoint)newPosition :(CGPoint)lastPosition
{
    CGPoint convertedNewPos = [self convertFromScreenToWorld:newPosition];
    CGPoint convertedLastPos = [self convertFromScreenToWorld:lastPosition];
    
    GLfloat deltaX = (convertedNewPos.x - convertedLastPos.x)/2;
    GLfloat deltaY = (convertedNewPos.y - convertedLastPos.y)/2;
    
    self.orthoCenter = CGPointMake(self.orthoCenter.x+deltaX, self.orthoCenter.y+deltaY);
    
    // Bound check
    if(self.orthoCenter.x > 50){
        self.orthoCenter = CGPointMake(50, self.orthoCenter.y);
    }
    if(self.orthoCenter.y > 50){
        self.orthoCenter = CGPointMake(self.orthoCenter.x, 50);
    }
    if(self.orthoCenter.x < -50){
        self.orthoCenter = CGPointMake(-50, self.orthoCenter.y);
    }
    if(self.orthoCenter.y < -50){
        self.orthoCenter = CGPointMake(self.orthoCenter.x, -50);
    }
    
    [self applyOrthoTransfromation];
}

// Apply a new world position as a 3D Vector according to ortho position
- (void) applyOrthoTransfromation
{
    self.worldPosition = Vector3DMake(self.orthoCenter.x, self.orthoCenter.y, -1); // Z ignored
}

// Zoom according to a pinch factor.  Makes sure we don't zoom too much
- (void) orthoZoom:(float) factor
{
    // Important : 4 and 3 represents the screen ratio of the iPad (4:3 , 1024:768)
    if(factor > 1){ // zoom out, pinch out
        if(self.orthoWidth < LARGEUR_FENETRE + 100 && self.orthoHeight < HAUTEUR_FENETRE + 75){
            self.orthoWidth += factor*4;
            self.orthoHeight += factor*3;
        }
    } else { // Zoom in
        if(self.orthoWidth > LARGEUR_FENETRE - 100 && self.orthoHeight > HAUTEUR_FENETRE - 75){
            self.orthoWidth -= factor*8;
            self.orthoHeight -= factor*6;
        }
    }
}

#pragma mark - Screen conversion

// Takes a screen coordinate point and convert it to predefined world coords
// Also take in account the zoom factor, represented here in the fact that we
// use orthoWidth/Height to convert the actual frustum for future position handling
- (CGPoint)convertFromScreenToWorld:(CGPoint)pos
{
    pos = CGPointMake((pos.x * (self.orthoWidth/LARGEUR_ECRAN) - self.orthoWidth/2) ,
                      -(pos.y * (self.orthoHeight/HAUTEUR_ECRAN) - self.orthoHeight/2));
    return pos;
}

// return a fully converted point, considering the orthoCenter offset and screen ratio
- (CGPoint) convertToWorldPosition:(CGPoint)pos
{
    CGPoint cg_worldPos = [self convertFromScreenToWorld:pos];
     return (CGPointMake(cg_worldPos.x + self.orthoCenter.x, cg_worldPos.y + self.orthoCenter.y));
}

-(CGPoint) calculateVelocity:(CGPoint)lastTouch :(CGPoint)currentTouch
{
    return CGPointMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
}

#pragma mark - Zooming methods
- (void) zoomInFromRect:(CGPoint)begin :(CGPoint)end
{
    // Invert if the rectangle isn't started from upper left and ended to lower right.
    if(begin.x > end.x){
        CGPoint temp = begin;
        begin = CGPointMake(end.x, begin.y);
        end = CGPointMake(temp.x, end.y);
    }
    
    if(end.y > begin.y){
        CGPoint temp = begin;
        begin = CGPointMake(begin.x, end.y);
        end = CGPointMake(end.x, temp.y);
    }
    
    float centerX = (end.x + begin.x)/2;
    float centerY = (begin.y + end.y)/2;
    
    float dimensionX = abs(end.x - begin.x);
    float dimensionY = abs(end.y - begin.y);
    
    if(dimensionX < dimensionY){
        dimensionY = dimensionX/4*3;
    } else{
        dimensionX = dimensionY/3*4;
    }
    
    self.orthoCenter = CGPointMake(centerX, centerY);
    self.orthoWidth = dimensionX;
    self.orthoHeight = dimensionY;
    
    // Limit zoom
    if(self.orthoWidth > LARGEUR_FENETRE + 100 || self.orthoHeight > LARGEUR_FENETRE + 75){
        self.orthoWidth = LARGEUR_FENETRE + 100;
        self.orthoHeight = HAUTEUR_FENETRE + 75;
    } else if(self.orthoWidth < LARGEUR_FENETRE - 100 || self.orthoHeight < LARGEUR_FENETRE - 75) {
        self.orthoWidth = LARGEUR_FENETRE - 100;
        self.orthoHeight = HAUTEUR_FENETRE - 75;
    }
    
    [self applyOrthoTransfromation];
}

#pragma mark - Perspective Cam methods

- (void) assginCamPosition
{
    gluLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
              self.centerPosition.x, self.centerPosition.y, self.centerPosition.z,
              self.up.x, self.up.y, self.up.z);
}

- (void) strafeXY:(CGPoint)delta
{
    self.eyePosition = Vector3DMake(self.eyePosition.x + delta.x/3, self.eyePosition.y - delta.y/3, self.eyePosition.z);
    self.centerPosition = Vector3DMake(self.centerPosition.x + delta.x/3, self.centerPosition.y - delta.y/3, self.centerPosition.z);
    
//    if (self.eyePosition.x > limit/2) {
//        self.eyePosition = Vector3DMake(limit/2, self.eyePosition.y,self.eyePosition.z);
//        self.centerPosition = Vector3DMake(limit/2, self.centerPosition.y,self.centerPosition.z);
//    }
//    if (self.eyePosition.x < -limit/2) {
//        self.eyePosition = Vector3DMake( - limit/2, self.eyePosition.y,self.eyePosition.z);
//        self.centerPosition = Vector3DMake(- limit/2, self.centerPosition.y,self.centerPosition.z);
//    }
//    if (self.centerPosition.y > limit) {
//        self.eyePosition = Vector3DMake(self.eyePosition.x, self.eyePosition.y,self.eyePosition.z);
//        self.centerPosition = Vector3DMake(self.centerPosition.x, limit,self.centerPosition.z);
//    }
//    if (self.eyePosition.y < -limit) {
//        self.eyePosition = Vector3DMake( self.eyePosition.x, -limit,self.eyePosition.z);
//        self.centerPosition = Vector3DMake(self.centerPosition.x, self.centerPosition,self.centerPosition.z);
//    }
    
    [self assignUpVector];

}

- (void) orbitAroundCenter
{
    float radTheta = (self.theta) * 3.1416/180;
    float radPhi = self.phi * 3.1416/180;
    self.eyePosition = Vector3DMake(self.centerPosition.x + eyeToCenterDistance * cosf(radTheta) * sinf(radPhi),
                                    self.centerPosition.y + -eyeToCenterDistance * sinf(radTheta) * sinf(radPhi),
                                    self.centerPosition.z + eyeToCenterDistance  * cosf(radPhi));
    
    [self assignUpVector];
}

- (void) assignUpVector
{
    Vector3D invertCenter = Vector3DMake(-self.centerPosition.x, -self.centerPosition.y, -self.centerPosition.z);
    Vector3D tempUp = Vector3DAdd(self.eyePosition, invertCenter);
    Vector3DNormalize(&tempUp);
    
    Vector3D right = Vector3DCrossProduct(tempUp, Vector3DMake(0, 0, 1));
    Vector3DNormalize(&right);
    
    self.up = Vector3DCrossProduct(right, tempUp);
}


// Move both the camera position (eye) and the point it is looking at (center) axis X and Z
- (void) perspectiveZoom:(float)delta
{
    if(delta > 1){ // zoom out, pinch out
        eyeToCenterDistance -= delta*2;
        self.eyePosition = Vector3DMake(self.eyePosition.x , self.eyePosition.y, self.eyePosition.z - (delta*2));
    } else { // Zoom in
        eyeToCenterDistance += delta*3;
        self.eyePosition = Vector3DMake(self.eyePosition.x , self.eyePosition.y, self.eyePosition.z + (delta*2));
    }
    
    if(eyeToCenterDistance < 50){
        eyeToCenterDistance = 50;
    } else if(eyeToCenterDistance > 200){
        eyeToCenterDistance = 200;
    }
}

#pragma mark - Replace camera animation
- (void) replaceCamera
{
    self.orthoCenter = CGPointMake(0, 0);
}

// Converts a touch point according to the current
// ModelView matrix and projection matrix via an UnProject call
// reference from : http://casualdistractiongames.wordpress.com/
- (void) convertScreenToWorldProj:(CGPoint)touch
{    
    Vector3D final = [self unproject:touch];
    self.worldPosition = Vector3DMake(final.x, final.y, 0); // Z ignored    
}

- (Vector3D) unproject:(CGPoint)touch
{
    // Projection Matrix
    GLfloat     projMat[16];
    glGetFloatv(GL_PROJECTION_MATRIX, projMat);
    GLKMatrix4 pMat = GLKMatrix4MakeWithArray(projMat);
    
    // ModelView Matrix
    GLfloat     modelMat[16];
    glGetFloatv(GL_MODELVIEW_MATRIX, modelMat);
    GLKMatrix4 mMat = GLKMatrix4MakeWithArray(modelMat);
    
    GLKVector3 window_coord = GLKVector3Make(touch.x,touch.y, 0.0f);
    
    bool result;
    
    int viewport[4];
    viewport[0] = 0.0f;
    viewport[1] = 0.0f;
    viewport[2] = 1024;
    viewport[3] = 768;
    touch.y = 768 - touch.y;
    
    // Z Plane (far)
    GLKVector3 near_pt = GLKMathUnproject(window_coord, mMat, pMat, &viewport[0], &result);
    window_coord = GLKVector3Make(touch.x,touch.y, 1.0f);
    
    // Z Plane (near)
    GLKVector3 far_pt = GLKMathUnproject(window_coord, mMat, pMat, &viewport[0], &result);
    float z_magnitude = fabs(far_pt.z-near_pt.z);
    float near_pt_factor = fabs(near_pt.z)/z_magnitude;
    float far_pt_factor = fabs(far_pt.z)/z_magnitude;
    GLKVector3 final_pt = GLKVector3Add( GLKVector3MultiplyScalar(near_pt, far_pt_factor), GLKVector3MultiplyScalar(far_pt, near_pt_factor));
    Vector3D final = Vector3DMake(final_pt.x, final_pt.y, 0);
    return final;
}

@end
