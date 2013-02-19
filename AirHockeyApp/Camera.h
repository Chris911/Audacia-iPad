//
//  Camera.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-31.
//
//

#import <Foundation/Foundation.h>
#import "OpenGLWaveFrontCommon.h"
#import "GluLookAt.h"
#import "GluPerspective.h"

@interface Camera : NSObject

@property Vector3D currentPosition;
@property Vector3D centerPosition;
@property Vector3D eyePosition;
@property Vector3D up;
@property Vector3D worldPosition;

@property CGPoint orthoCenter;
@property CGPoint zoomFactor;

@property BOOL isPerspective;

@property GLfloat  orthoWidth;
@property GLfloat  orthoHeight;
@property GLfloat  windowWidth;
@property GLfloat  windowHeight;

@property GLfloat  eyeToCenterDistance;
@property GLfloat  theta;
@property GLfloat  phi;


- (void) setCamera;
- (void) assignWorldPosition:(CGPoint)screenPos;
- (void) orthoTranslate:(CGPoint)newPosition :(CGPoint)lastPosition ;
- (void) orthoZoom:(float) factor;

- (CGPoint)convertFromScreenToWorld:(CGPoint)pos;
- (CGPoint) convertToWorldPosition:(CGPoint)pos;
- (CGPoint) calculateVelocity:(CGPoint)lastTouch :(CGPoint) currentTouch ;

- (void) replaceCamera;
- (void) resetCamera;
- (void) zoomInFromRect:(CGPoint)begin :(CGPoint)end ;

- (void) perspectiveZoom:(float)delta;
- (void) strafeXY:(CGPoint)delta;
- (void) convertScreenToWorldProj:(CGPoint)_point3D;


@end
