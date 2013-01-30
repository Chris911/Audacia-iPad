//
//  MapContainer.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-29.
//
//

#import <Foundation/Foundation.h>

@interface MapContainer : NSObject

@property BOOL isMapsLoaded;
@property (nonatomic, retain) NSMutableArray* maps;

+ (MapContainer *)getInstance;
+ (void) assignNewMaps:(NSMutableArray*)newMaps;


@end
