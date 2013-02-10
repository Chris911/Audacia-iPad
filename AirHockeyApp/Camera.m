//
//  Camera.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-31.
//  Camera used to move around in the GL World
//  Also serves as an touch point converter to
//  keep the gl objects positions unchanged.

#import "Camera.h"

//@interface Camera ()
//{
//    float curveFactor;
//}
//@end

@implementation Camera

@synthesize currentPosition;
@synthesize centerPosition;
@synthesize eyePosition;
@synthesize orientation;
@synthesize worldPosition;
@synthesize isPerspective;
@synthesize zoomFactor;
@synthesize orthoCenter;
@synthesize orthoHeight;
@synthesize orthoWidth;
@synthesize windowHeight;
@synthesize windowWidth;

- (id) init
{
    if((self = [super init])) {
        [self resetCamera];
    }
    return self;
}

#pragma mark - Reset camera
- (void) resetCamera
{
    // Perspective attributes
    self.currentPosition = Vector3DMake(0, 0, 0);
    
    self.centerPosition = Vector3DMake(0, 0, 0);
    self.eyePosition = Vector3DMake(0, 0, 50);
    self.orientation = Vector3DMake(0, 1, 0); // Camera orientend on Y axis
    
    // Ortho attributes
    self.isPerspective = NO;
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
                 -100, 100);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();

//        gluLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
//                  self.centerPosition.x, self.centerPosition.y, self.centerPosition.z,
//                  self.orientation.x, self.orientation.y, self.orientation.z);
        
    } else { // Perspective Mode
    
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluPerspective(45.0f, 4/3, 1, 1000);
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        gluLookAt(self.eyePosition.x, self.eyePosition.y, self.eyePosition.z,
                  self.centerPosition.x, self.centerPosition.y, self.centerPosition.z,
                  self.orientation.x, self.orientation.y, self.orientation.z);
        
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


#pragma mark - Replace camera animation
- (void) replaceCamera
{
    while(![self replaceCameraToOrigin:YES]) {
        // Block while animating
    }
}


- (BOOL) replaceCameraToOrigin:(BOOL)animated
{
    if(animated)
    {
        [self animateCameraBackToOrigin];

        if(self.orthoCenter.x > -2 && self.orthoCenter.x < 2
           && self.orthoCenter.y > -2 && self.orthoCenter.y < 2
           && ((self.orthoWidth > LARGEUR_FENETRE - 4 && self.orthoWidth < LARGEUR_FENETRE + 4)
           && (self.orthoHeight > HAUTEUR_FENETRE - 3 && self.orthoHeight < HAUTEUR_FENETRE + 3))){
            
            // Reset the coordinates
            self.orthoCenter = CGPointMake(0, 0);
            self.orthoWidth = LARGEUR_FENETRE;
            self.orthoHeight = HAUTEUR_FENETRE;
            
            return YES; //Animation finished
        }
        return NO; // Animation not finished
        
    } else {
        self.orthoCenter = CGPointMake(0, 0);
    }
    
    return YES;
}


- (void) animateCameraBackToOrigin
{
    float xIncrement = 0.01f;
    float yIncrement = 0.01f;
    float zoomIncrementX = 0.03f;
    float zoomIncrementY = 0.03f;

    
    float newXpos = 0;
    float newYpos = 0;
    float newZoomX = 0;
    float newZoomY = 0;
    
    if(self.orthoCenter.x < 2){
        newXpos = self.orthoCenter.x + xIncrement;
    } else if(self.orthoCenter.x > 2){
        newXpos = self.orthoCenter.x - xIncrement;
    }
    
    if(self.orthoCenter.y < 2){
        newYpos = self.orthoCenter.y + yIncrement;
    } else if(self.orthoCenter.y > 2){
        newYpos = self.orthoCenter.y - yIncrement;
    }
    
    if(self.orthoWidth < LARGEUR_FENETRE - 4){
        newZoomX = self.orthoWidth + zoomIncrementX;
    } else if(self.orthoWidth > LARGEUR_FENETRE + 4){
        newZoomX = self.orthoWidth - zoomIncrementX;
    }
    
    if(self.orthoHeight < HAUTEUR_FENETRE - 3){
        newZoomY = self.orthoHeight + zoomIncrementY;
    } else if(self.orthoHeight > HAUTEUR_FENETRE + 3){
        newZoomY = self.orthoHeight - zoomIncrementY;
    }
    
    if(newZoomX != 0) {
        self.orthoWidth = newZoomX;
    } else if(newZoomY != 0) {
        self.orthoHeight = newZoomY;
    }

    self.orthoCenter = CGPointMake(newXpos,newYpos);
}
@end
