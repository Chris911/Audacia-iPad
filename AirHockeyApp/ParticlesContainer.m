//
//  ParticlesContainer.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-20.
//
//

#import "ParticlesContainer.h"

@implementation ParticlesContainer
@synthesize particles;

- (id) initWithNumberOfParticles:(int)nb :(CGPoint)center;
{
    if((self = [super init])) {
        self.isAlive = YES;
        self.particles = [[[NSMutableArray alloc]init]autorelease];
        
        for (int i = 0; i < nb; i++) {
            Particle *p = [[Particle alloc]initWithCenterPosition:center];
            [self.particles addObject:p];
        }
        
        for (int i = 0; i < nb; i++) {
            Particle *p = [particles objectAtIndex:i];
            float angle = 360 / (i+1);
            p.angle = angle;

        }
    }
    return self;
}

- (void)render
{
    glDisable(GL_LIGHTING);
    glDisable(GL_TEXTURE_2D);
    
    for(int i = [self.particles count] -1; i >= 0; i-- ) {
        
        Particle* p = [self.particles objectAtIndex:i];
        [p render];
        
        if(p.alpha <=0){
            [self.particles removeObject:p];
        }
    }
    if([self.particles count] == 0){
        self.isAlive = NO;
    }
    glEnable(GL_LIGHTING);
    glEnable(GL_TEXTURE_2D);
}

- (void) dealloc
{
    [super dealloc];
    [particles release];
}

@end
