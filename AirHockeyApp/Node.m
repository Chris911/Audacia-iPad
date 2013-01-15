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

- (id) init
{
    if((self = [super init])) {
        self.hash = [self generateHash];
        self.isSelectable = YES;
        self.isSelected = NO;
        self.isVisible = YES;
        self.isWaveFrontObject = NO;
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
