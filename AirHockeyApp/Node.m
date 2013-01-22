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
    // Virtual - Do not put anything here

}

- (void) setRotation:(Rotation3D)rotation
{
    // Virtual - Do not put anything here   
}

// Destroyed setPosition method as it was
// redifining the synthetized method for
// OpenGL objects. The function would enter an
// infinite loop when assigning NodeTableEdge.position
// - Sam (Obviously)

- (void) setScaling :(float)scaleFactor
{
    // Virtual - Do not put anything here
}

//  Make sure that a specific node (that have been released
// from the user's touch) is in the Zone limits
- (void) checkIfInBounds
{
    // Check if the node is inside the edition surface (in X and Y)
    if(self.position.x >= TABLE_LIMIT_X) {
        self.position = Vector3DMake(TABLE_LIMIT_X,self.position.y,self.position.z);
    } else if(self.position.x <= -TABLE_LIMIT_X) {
        self.position = Vector3DMake(-TABLE_LIMIT_X,self.position.y,self.position.z);
    }
    
    if(self.position.y >= TABLE_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,TABLE_LIMIT_Y,self.position.z);
    } else if(self.position.y <= -TABLE_LIMIT_Y) {
        self.position = Vector3DMake(self.position.x,-TABLE_LIMIT_Y,self.position.z);
    }
}

- (NSString*) generateHash
{
    // TODO: Implement hash function using type and time
    NSString* emptyString = @"";
    return emptyString;
}
@end
