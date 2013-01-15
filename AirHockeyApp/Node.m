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

- (void) render
{
    if(self.isWaveFrontObject) {
        NSLog(@"Rendering wavefront object: %@", self.type);
        
    }
    else {
        glLoadIdentity();
        
    }
}

- (NSString*) generateHash
{
    // TODO: Implement hash function using type and time
    NSString* emptyString = @"";
    return emptyString;
}
@end
