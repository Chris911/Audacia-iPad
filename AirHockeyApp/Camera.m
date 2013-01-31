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
                
        // Perspective attributes
        self.centerPosition = Vector3DMake(0, 0, 0);
        self.currentPosition = Vector3DMake(0, 0, 0);
        self.eyePosition = Vector3DMake(0, 0, 0);
        self.orientation = Vector3DMake(0, 1, 0); // Camera orientend on Y axis
        
        // Ortho attributes
        self.isPerspective = NO;
        self.zoomFactor = 1.0f;
        
        self.orthoCenter = CGPointMake(0, 0);
        
        self.orthoHeight = HAUTEUR_FENETRE;
        self.orthoWidth = LARGEUR_FENETRE;
        
        self.windowHeight = HAUTEUR_ECRAN;
        self.windowWidth = LARGEUR_ECRAN;
        
        self.worldPosition = Vector3DMake(self.orthoCenter.x, self.orthoCenter.y,-1); //Z Ignored
        
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
    
    self.orthoCenter = CGPointMake(self.orthoCenter.x-deltaX, self.orthoCenter.y-deltaY);
    self.worldPosition = Vector3DMake(self.orthoCenter.x, self.orthoCenter.y, -1); // Z ignored    
}

#pragma mark - Screen conversion
// Takes a screen coordinate point and convert it to predefined world coords
- (CGPoint)convertFromScreenToWorld:(CGPoint)pos
{
    pos = CGPointMake((pos.x * (LARGEUR_FENETRE/1024) - LARGEUR_FENETRE/2) ,
                      -(pos.y * (HAUTEUR_FENETRE/HAUTEUR_ECRAN) - HAUTEUR_FENETRE/2));
    return pos;
}

-(CGPoint) calculateVelocity:(CGPoint) lastTouch:(CGPoint) currentTouch
{
    return CGPointMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
}

#pragma mark - animations
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
           && self.orthoCenter.y > -2 && self.orthoCenter.y < 2){
            self.orthoCenter = CGPointMake(0, 0);
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
    float xIncrement = 0.0005f;
    float yIncrement = 0.0005f;
    
    float newXpos = 0;
    float newYpos = 0;
    
    if(self.orthoCenter.x < 2){
        newXpos = self.orthoCenter.x + xIncrement;
    } else if(self.orthoCenter.x > 2){
        newXpos = self.orthoCenter.x - xIncrement;
    }
    
    if(self.orthoCenter.y < 2){
        newYpos = self.orthoCenter.y + yIncrement;
    } else if(self.orthoCenter.y > 2){
        newYpos = self.orthoCenter.y +- yIncrement;
    }
    self.orthoCenter = CGPointMake(newXpos,newYpos);
}



@end
