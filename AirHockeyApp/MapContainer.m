//
//  MapContainer.m
//  AirHockeyApp
//
//  Created by Sam Des Rochers on 13-01-29.
//
//  

#import "MapContainer.h"
#import "Map.h"

@implementation MapContainer

@synthesize maps;
@synthesize isMapsLoaded;

static MapContainer *mapContainer = NULL;

// Classic Obj-C singleton
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

// Switch the current maps set with the one fetched from
// the webclient.  Set isMapsLoaded to YES so the UI know
// this task is finished.
+ (void) assignNewMaps:(NSMutableArray*)newMaps
{
    if(newMaps != nil){
        mapContainer.maps = newMaps;
        mapContainer.isMapsLoaded = YES;
    }
}

+ (BOOL) checkIfMapImagesLoaded
{
    for(Map *m in mapContainer.maps)
    {
        CGImageRef cgref = [m.image CGImage];
        if(cgref == NULL && ![m.name isEqualToString:@"daveisgod"]){
            return NO;
        }
    }
    return YES;
}

- (void) dealloc
{
    [super dealloc];
    [mapContainer release];
}

@end

