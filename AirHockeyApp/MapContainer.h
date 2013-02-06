//
//  MapContainer.h
//  AirHockeyApp
//
//  Created by Sam Des Rochers on 13-01-29.
//
// Singleton class used to contain all the maps
// and access them from the BETAVIEWCONTROLLER
// This allows the container to fill up in a
// background thread while the UI waits for the
// container to be full with maps, fetched from
// the WebClient.  

#import <Foundation/Foundation.h>

@interface MapContainer : NSObject

@property BOOL isMapsLoaded;
@property (nonatomic, retain) NSMutableArray* maps;

+ (MapContainer *)getInstance;
+ (void) assignNewMaps:(NSMutableArray*)newMaps;
+ (BOOL) checkIfMapImagesLoaded;

@end
