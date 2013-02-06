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
@synthesize authorName;
@synthesize timeStamp;
@synthesize rating;
@synthesize private;
@synthesize image;

- (id) initWithMapData:(int)_mapId :(NSString *)_name :(NSString *)_authorName :(NSString *)_timeStamp :(int)_rating :(BOOL)_private
{
    if((self = [super init])) {
        self.mapId = _mapId;
        self.authorName = _authorName;
        self.name  = _name;
        self.timeStamp = _timeStamp;
        self.rating = _rating;
        self.private = _private;
    }
    return self;
}

- (void) dealloc
{
    [name release];
    [image release];
    [timeStamp release];
    [authorName release];
    [super dealloc];

}

@end

