//
//  Node.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import "Node.h"

@implementation Node

@synthesize type;
@synthesize hash;
@synthesize angle;
@synthesize position;
@synthesize scaleFactor;

@synthesize isSelectable;
@synthesize isSelected;
@synthesize isVisible;


// Constants definition
const float DEFAULT_SCALE_VALUE = 1.0f;
const float DEFAULT_ANGLE_VALUE = 0.0f;

- (id) init
{
    if((self = [super init])) {
        self.hash = [self generateHash];
        
        self.scaleFactor        = DEFAULT_SCALE_VALUE;
        self.angle              = DEFAULT_ANGLE_VALUE;
        
        self.isSelectable       = YES;
        self.isVisible          = YES;
        self.isSelected         = NO;
        self.isWaveFrontObject  = NO;
    }
    return self;
}

// This method is only used for primitive objects.
// Wavefront objects overload the render method instead.
- (void) render
{
    
}

- (void) setRotation:(Rotation3D)rotation
{
    
}

- (void) setPosition:(Vector3D)position
{
    
}

- (void) setScaling :(float)scaleFactor
{
    
}

- (NSString*) generateHash
{
    // TODO: Implement hash function using type and time
    NSString* emptyString = @"";
    return emptyString;
}
@end
