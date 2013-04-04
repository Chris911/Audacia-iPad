//
//  XMLUtil.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "RenderingTree.h"


@interface XMLUtil : NSObject

+ (NSString *)dataFilePath:(NSString*)fileName :(BOOL)forSave;
+ (RenderingTree *)loadRenderingTreeFromGDataXMLDocument:(GDataXMLDocument*)doc;
+ (GDataXMLDocument *)getRenderingTreeXmlData:(RenderingTree *)renderingTree;

@end
