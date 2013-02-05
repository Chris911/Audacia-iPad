//
//  WebClient.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-20.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "Map.h"
#import "MapContainer.h"
#import "BetaViewController.h"

//NSString* const defaultServer = @"http://kepler.step.polymtl.ca/";
//NSString* const defaultUploadScript = @"/projet3/scripts/upload.php";

@interface WebClient : NSObject

@property (retain,nonatomic) AFHTTPClient* AFClient;
@property (retain,nonatomic) NSString* server;
@property (retain,nonatomic) NSString* mapsAPIScript;
@property (retain,nonatomic) NSString* imagePath;
@property (retain,nonatomic) NSString* xmlPath;

- (id) initWithDefaultServer;
- (void) uploadMapData:(NSString*)mapName :(NSData *)xmlData :(UIImage*)mapImage;
- (void) fetchAllMapsFromDatabase;
- (void) getConfigPaths;
@end
