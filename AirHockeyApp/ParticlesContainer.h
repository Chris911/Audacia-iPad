//
//  ParticlesContainer.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-20.
//
//

#import <Foundation/Foundation.h>
#import "Particle.h"

@interface ParticlesContainer : NSObject
@property (nonatomic, retain) NSMutableArray* particles;
@property BOOL isAlive;

- (id) initWithNumberOfParticles:(int)nb :(CGPoint)center;
- (void)render;

@end
