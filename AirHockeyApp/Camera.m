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


- (void) setCamera
{
    if(!self.isPerspective) {
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        // Orthogonal Mode
        glOrthof(self.orthoCenter.x - self.orthoWidth/2,
                 self.orthoCenter.x + self.orthoWidth/2,
                 self.orthoCenter.y - self.orthoHeight/2,
                 self.orthoCenter.y + self.orthoHeight/2,
                 -100, 100);
        glMatrixMode(GL_MODELVIEW);
    }
}


- (void) assignWorldPosition:(CGPoint)screenPos
{
    CGPoint cg_worldPos = [self convertFromScreenToWorld:screenPos];
    self.worldPosition = Vector3DMake(cg_worldPos.x + self.orthoCenter.x, cg_worldPos.y + self.orthoCenter.y, -1); // ignore Z
}


- (void) orthoTranslate:(CGPoint)newPosition:(CGPoint)lastPosition
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
    if(factor > 1){ // zoom in, pinch in
        if(self.orthoWidth < LARGEUR_FENETRE + 100 && self.orthoHeight < HAUTEUR_FENETRE + 75){
            self.orthoWidth += factor*8;
            self.orthoHeight += factor*6;
        }
        
    } else { // Zoom out
        if(self.orthoWidth > LARGEUR_FENETRE - 100 && self.orthoHeight > HAUTEUR_FENETRE - 75){
            self.orthoWidth -= factor*4;
            self.orthoHeight -= factor*3;
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

-(CGPoint) calculateVelocity:(CGPoint) lastTouch:(CGPoint) currentTouch
{
    return CGPointMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
}


#pragma mark - Replace camera animation
- (void) replaceCamera
{
    while(![self replaceCameraToOrigin:YES]) {
        // Block
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
    float xIncrement = 0.0001f;
    float yIncrement = 0.0001f;
    float zoomIncrementX = 0.0003f;
    float zoomIncrementY = 0.0003f;

    
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


#pragma mark - Reset camera
- (void) resetCamera
{
    // Perspective attributes
    self.centerPosition = Vector3DMake(0, 0, 0);
    self.currentPosition = Vector3DMake(0, 0, 0);
    self.eyePosition = Vector3DMake(0, 0, 0);
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



@end
