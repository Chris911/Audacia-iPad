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

@synthesize renderingTree;

static Scene *scene = NULL;

// Singleton of a rendering tree
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        scene = [[Scene alloc]init];
        RenderingTree* tempTree = [[RenderingTree alloc]init];
        scene.renderingTree = tempTree;
        [tempTree release];
    }
}

+ (Scene *)getInstance
{
    [self initialize];
    return (scene);
}

- (void)dealloc
{
    self.renderingTree = nil;
    [renderingTree release];
    [scene release];
    [super dealloc];
}

@end