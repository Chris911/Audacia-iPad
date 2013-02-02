//
//  Camera.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-31.
//
//

#import <Foundation/Foundation.h>
#import "OpenGLWaveFrontCommon.h"

@interface Camera : NSObject

@property Vector3D currentPosition;
@property Vector3D centerPosition;
@property Vector3D eyePosition;
@property Vector3D orientation;
@property Vector3D worldPosition;

@property CGPoint orthoCenter;
@property CGPoint zoomFactor;

@property BOOL isPerspective;

@property GLfloat  orthoWidth;
@property GLfloat  orthoHeight;
@property GLfloat  windowWidth;
@property GLfloat  windowHeight;


- (void) setCamera;
- (void) assignWorldPosition:(CGPoint)screenPos;
- (void) orthoTranslate:(CGPoint)newPosition:(CGPoint)lastPosition;
- (void) orthoZoom:(float) factor;
- (CGPoint)convertFromScreenToWorld:(CGPoint)pos;
- (CGPoint) convertToWorldPosition:(CGPoint)pos;
- (CGPoint) calculateVelocity:(CGPoint) lastTouch:(CGPoint) currentTouch;
- (void) replaceCamera;
- (void) resetCamera;



@end
