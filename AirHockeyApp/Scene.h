//
//  Scene.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import <Foundation/Foundation.h>
#import "RenderingTree.h"

@interface Scene : NSObject

@property (nonatomic,retain)RenderingTree* renderingTree;

+ (Scene *)getInstance;
+ (void) loadDefaultElements;
+ (void) loadCustomTree:(RenderingTree*) tree;
+ (void) replaceOutOfBoundsElements;
+ (BOOL) checkIfAddingLocationInBounds:(CGPoint)location;

@end
