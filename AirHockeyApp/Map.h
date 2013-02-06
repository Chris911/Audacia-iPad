//
//  MapContainer.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-29.
//
//

#import <Foundation/Foundation.h>

@interface Map : NSObject

@property int mapId;
@property (nonatomic, retain)NSString *name;
@property (nonatomic, retain)NSString *authorName;
@property (nonatomic, retain)NSString *timeStamp;
@property int rating;
@property BOOL private;
@property (nonatomic, retain)UIImage *image;

- (id) initWithMapData:(int)_mapId :(NSString *)_name :(NSString *)_authorName :(NSString *)_timeStamp :(int)_rating :(BOOL)_private;

@end
