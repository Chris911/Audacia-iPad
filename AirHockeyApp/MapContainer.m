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
@synthesize isMapsInfosLoaded;
@synthesize isMapsImagesLoaded;

static MapContainer *mapContainer = NULL;

// Classic Obj-C singleton
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        mapContainer = [[MapContainer alloc]init];
        mapContainer.isMapsInfosLoaded = NO;
        mapContainer.isMapsImagesLoaded = NO;
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
+ (void) assignNewMaps:(NSArray*)newMaps
{
    if(newMaps != nil){
        [mapContainer.maps removeAllObjects];
        mapContainer.maps = [NSMutableArray arrayWithArray:newMaps];
        mapContainer.isMapsInfosLoaded = YES;
    }
}

+ (BOOL) removeMapsInContainers
{
    [mapContainer.maps removeAllObjects];
    return YES;
}

+ (BOOL) allMapImagesLoaded
{
    @try {
        for(Map* m in mapContainer.maps)
        {
            CGImageRef cgref = [m.image CGImage];
            if(cgref == NULL){
                return NO;
            }
        }
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"[MapContainer] : error loading maps images from server");
    }
    
    return NO;
}

- (void) dealloc
{
    [super dealloc];
    [mapContainer release];
    [maps release];
}

@end

