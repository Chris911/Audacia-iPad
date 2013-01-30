//
//  MapContainer.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-29.
//
//

#import "MapContainer.h"

@implementation MapContainer

@synthesize maps;
@synthesize isMapsLoaded;

static MapContainer *mapContainer = NULL;

+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        mapContainer = [[MapContainer alloc]init];
        mapContainer.isMapsLoaded = NO;
    }
}

+ (MapContainer *)getInstance
{
    [self initialize];
    return (mapContainer);
}

+ (void) assignNewMaps:(NSMutableArray*)newMaps
{
    if(newMaps != nil){
        mapContainer.maps = newMaps;
        mapContainer.isMapsLoaded = YES;
    }
}

- (void) dealloc
{
    [super dealloc];
    [mapContainer release];
}

@end

