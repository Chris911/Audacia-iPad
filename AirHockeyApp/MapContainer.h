//
//  MapContainer.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-29.
//
//

#import <Foundation/Foundation.h>

@interface MapContainer : NSObject

@property int mapId;
@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *timeStamp;
@property int rating;
@property BOOL private;

- (id) initWithMapData:(int)_mapId :(NSString *)_name :(NSString *)_timeStamp :(int)_rating :(BOOL)_private;

@end
