//
//  Scene.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//  DESC: Interface between GL view and backend model (rendering tree)
//  Singleton Class

#import "Scene.h"
#import "RenderingTree.h"

@implementation Scene

static RenderingTree *renderingTree;

// Singleton of a rendering tree
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        renderingTree = [[[RenderingTree alloc]init]autorelease];
    }
}

@end
