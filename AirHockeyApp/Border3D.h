//
//  Border3D.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-30.
//
//

#import <Foundation/Foundation.h>
#import "OpenGLWaveFrontCommon.h"

@interface Border3D : NSObject

@property  Vector3D begPt;
@property  Vector3D endPt;

@property  Vector3D v1;
@property  Vector3D v2;
@property  Vector3D v3;
@property  Vector3D v4;
@property  Vector3D v5;
@property  Vector3D v6;
@property  Vector3D v7;
@property  Vector3D v8;

- (id) initWithStartAndEndPoints:(Vector3D)startPt:(Vector3D)endPt;
- (void) drawVertices;
- (void) setNewPosition:(Vector3D)begPt:(Vector3D)endPt:(BOOL)isVertical;

@end
