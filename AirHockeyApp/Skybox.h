//
//  Skybox.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-10.
//
//

#import <Foundation/Foundation.h>
#import "OpenGLWaveFrontCommon.h"

@interface Skybox : NSObject

@property  Vector3D v1;
@property  Vector3D v2;
@property  Vector3D v3;
@property  Vector3D v4;
@property  Vector3D v5;
@property  Vector3D v6;
@property  Vector3D v7;
@property  Vector3D v8;

- (id) initWithSize:(float) size;
- (void) render;

@end
