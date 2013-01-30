//
//  MapContainer.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-29.
//
//

#import "Map.h"

@implementation Map

@synthesize mapId;
@synthesize name;
@synthesize timeStamp;
@synthesize rating;
@synthesize private;

- (id) initWithMapData:(int)_mapId :(NSString *)_name :(NSString *)_timeStamp :(int)_rating :(BOOL)_private
{
    if((self = [super init])) {
        self.mapId = _mapId;
        self.name  = _name;
        self.timeStamp = _timeStamp;
        self.rating = _rating;
        self.private = _private;
    }
    return self;
}

@end

