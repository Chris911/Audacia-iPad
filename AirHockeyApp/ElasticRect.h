//
//  ElasticRect.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-02.
//
//

#import <Foundation/Foundation.h>

@interface ElasticRect : NSObject

@property CGPoint beginPosition;
@property CGPoint endPosition;
@property CGPoint dimension;

@property BOOL isActive;
@property BOOL isSelectionMode; // implying !isSelectionMode = zoom mode

- (void) render;
- (void) reset;


@end
