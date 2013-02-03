//
//  Particles.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-03.
//
//

#import <Foundation/Foundation.h>
#import "OpenGLWaveFrontCommon.h"   

@interface Particle : NSObject

@property Vector3D position;
@property BOOL isActive;
- (void)render;

@end
