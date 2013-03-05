//
//  Scene.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-14.
//
//

#import <Foundation/Foundation.h>
#import "RenderingTree.h"
#import "GDataXMLNode.h"

@interface Scene : NSObject

@property (nonatomic,retain)RenderingTree* renderingTree;
@property (nonatomic) BOOL loadingCustomTree;
@property (nonatomic,retain)GDataXMLDocument* treeDoc;

+ (Scene *)getInstance;
+ (void) loadDefaultElements;
+ (void) loadTreeFromXMLDoc;
+ (void) loadCustomTree:(RenderingTree*) tree;
+ (void) replaceOutOfBoundsElements;
+ (BOOL) checkIfAddingLocationInBounds:(CGPoint)location;

@end
