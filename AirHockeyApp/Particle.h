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
@property Vector3D velocity;
@property float alpha;
@property float angle;

- (id) initWithCenterPosition:(CGPoint)point;
- (void)render;

@end
