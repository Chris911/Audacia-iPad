//
//  WebClient.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-20.
//
//  Client to connect to web server.
//  Wrapper for the AFNetworking HTTP Client

#import "WebClient.h"
#import "UIImageView+AFNetworking.h"

@implementation WebClient
@synthesize AFClient;
@synthesize server;
@synthesize mapsAPIScript;
@synthesize xmlPath;
@synthesize imagePath;

- (id) initWithDefaultServer
{
    if((self = [super init])) {
        self.server = @"http://kepler.step.polymtl.ca/";
        self.mapsAPIScript = @"/projet3/scripts/MapsAPI.php";
        NSURL *url = [NSURL URLWithString:self.server];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        self.AFClient = httpClient;
        [self getConfigPaths];
        [httpClient release];
    }
    return self;
}


- (void) uploadMapData:(NSString*)mapName :(NSData *)xmlData :(UIImage*)mapImage
{
    [self uploadXMLData:xmlData :mapName];
    [self uploadImageData:mapImage :mapName];
    
    //Add to database
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"addMapToDatabase", @"action",
                            mapName, @"mapName",
                            nil];

    [self.AFClient postPath:self.mapsAPIScript parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Success [Map to DB]: %@", operation.responseString);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error [Map to DB]: %@", operation.responseString);
    }];
}


- (void) uploadXMLData:(NSData*)xmlData :(NSString *)mapName
{
    NSString *fileName = [mapName stringByAppendingString:@".xml"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.mapsAPIScript parameters:@{@"action":@"uploadMap"} constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:xmlData name:@"file" fileName:fileName mimeType:@"application/xml"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success [Map XML]: %@", operation.responseString);
    }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error [Map XML]: %@",  operation.responseString);
          }
     ];
    
    [operation start];
}


- (void) uploadImageData:(UIImage*)image :(NSString*)mapName
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [mapName stringByAppendingString:@".png"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.mapsAPIScript parameters:@{@"action":@"uploadMap"} constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success [Map Image]: %@", operation.responseString);
    }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error [Map Image]: %@",  operation.responseString);
          }
     ];
    
    [operation start];
}


- (void) fetchAllMapsFromDatabase
{
    NSMutableURLRequest *request = [self.AFClient requestWithMethod:@"POST"
                                                       path:self.mapsAPIScript
                                                       parameters:@{@"action":@"fetchAllMaps"}];
    
    NSMutableArray *allMaps = [[[NSMutableArray alloc]init]autorelease];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        while(self.imagePath == 0){
            NSLog(@"WTF");
        }
        NSArray *mapIdArray = [JSON valueForKeyPath:@"mapId"];
        NSArray *nameArray = [JSON valueForKeyPath:@"name"];
        NSArray *dateAddedArray = [JSON valueForKeyPath:@"dateAdded"];
        NSArray *ratingArray = [JSON valueForKeyPath:@"rating"];
        NSArray *privateArray = [JSON valueForKeyPath:@"private"];
        
        for(int i=0; i < [mapIdArray count]; i++) {

            // Convert from string to int or we obtain a weird pointe value
            NSString *mapIdString = [NSString stringWithFormat:@"%@",mapIdArray[i]];
            int mapIdInt = [mapIdString intValue];
            
            NSString *ratingString = [NSString stringWithFormat:@"%@",ratingArray[i]];
            int ratingInt = [ratingString intValue];
            
            Map *map = [[Map alloc]initWithMapData:mapIdInt :[nameArray objectAtIndex:i] :[dateAddedArray objectAtIndex:i] :ratingInt  :[privateArray objectAtIndex:i]];
            map.image = [self fetchMapImageWithName:map.name];
            [allMaps addObject:map];
        }
        
        [self assignNewMaps:allMaps];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    
    [operation start];
}

- (void) getConfigPaths
{
    NSMutableURLRequest *request = [self.AFClient requestWithMethod:@"POST"
                                                   path:self.mapsAPIScript
                                                   parameters:@{@"action":@"getConfigPaths"}];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *basePath  = [JSON valueForKeyPath:@"BASE_PATH"];
        NSString *xmlPath   = [JSON valueForKeyPath:@"XML_PATH"];
        NSString *imagePath = [JSON valueForKeyPath:@"MAP_IMAGE_PATH"];
        
        self.xmlPath = [basePath stringByAppendingString:xmlPath];
        self.imagePath = [basePath stringByAppendingString:imagePath];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response %@", JSON);
    }];
    
    [operation start];
}

- (UIImage*) fetchMapImageWithName:(NSString*) mapName
{
    NSString* imageName = [mapName stringByAppendingString:@".png"];
    NSString* urlString = [self.imagePath stringByAppendingString:imageName];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
    UIImage *image = [UIImage imageWithData:data];
    
    if(image == nil)
    {
        NSLog(@"Could not create image with name :%s",mapName);
    }
    
    return image;
}

- (void) assignNewMaps:(NSMutableArray*)maps
{
    [MapContainer getInstance];
    [MapContainer assignNewMaps:maps];
}

@end
