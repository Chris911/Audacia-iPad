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
#import "ProfileViewController.h"

@interface WebClient : NSObject

@property (retain,nonatomic) AFHTTPClient* AFClient;
@property (retain,nonatomic) NSString* server;
@property (retain,nonatomic) NSString* mapsAPIScript;
@property (retain,nonatomic) NSString* profileAPIScript;
@property (retain,nonatomic) NSString* imagePath;
@property (retain,nonatomic) NSString* profileImagePath;
@property (retain,nonatomic) NSString* xmlPath;

- (id) initWithDefaultServer;
- (void) uploadMapData:(NSString *)mapName :(NSData *)xmlData :(UIImage*)mapImage;
- (void) uploadProfilePicture:(UIImage*)image :(NSString*)username;
- (void) fetchAllMapsFromDatabase;
- (void) fetchMapsByUser:(NSString *)username :(ProfileViewController *)view;
- (void) fetchProfilePicture:(NSString*) username :(ProfileViewController*)view;
- (void) fetchMapXML:(NSString *)mapName;
- (void) getConfigPaths;
- (void) fetchMapImageWithName:(Map*)map;
- (BOOL) validateLogin:(NSString*)username :(NSString*)password ;
@end
