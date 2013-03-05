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
#import "AFGDataXMLRequestOperation.h"
#import "Session.h"
#import "XMLUtil.h"
#import "RenderingTree.h"
#import "Scene.h"

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
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    NSString *fileName = [mapName stringByAppendingString:@".jpg"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.mapsAPIScript parameters:@{@"action":@"uploadMap"} constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpg"];
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
        }
        NSArray *mapIdArray = [JSON valueForKeyPath:@"mapId"];
        NSArray *nameArray = [JSON valueForKeyPath:@"name"];
        NSArray *authorNameArray = [JSON valueForKey:@"authorName"];
        NSArray *dateAddedArray = [JSON valueForKeyPath:@"dateAdded"];
        NSArray *ratingArray = [JSON valueForKeyPath:@"rating"];
        NSArray *privateArray = [JSON valueForKeyPath:@"private"];
        
        for(int i=0; i < [mapIdArray count]; i++) {

            // Convert from string to int or we obtain a weird pointe value
            NSString *mapIdString = [NSString stringWithFormat:@"%@",mapIdArray[i]];
            int mapIdInt = [mapIdString intValue];
            
            NSString *ratingString = [NSString stringWithFormat:@"%@",ratingArray[i]];
            int ratingInt = [ratingString intValue];
            
            NSString *privateString = [NSString stringWithFormat:@"%@",privateArray[i]];
            int privateInt = [privateString intValue];
            
            Map *map = [[[Map alloc]initWithMapData:mapIdInt
                                                   :[nameArray objectAtIndex:i]
                                                   :[authorNameArray objectAtIndex:i]
                                                   :[dateAddedArray objectAtIndex:i]
                                                   :ratingInt
                                                   :privateInt]autorelease];

            //Map *map = [[[Map alloc]initWithMapData:0 :@"NOLEAKS":@"t":@"t":0 :YES]autorelease];
            
            //[self fetchMapImageWithName:map];
            [allMaps addObject:map];
        }
        [self assignNewMaps:allMaps];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
    }];
    
    NSOperationQueue* opq = [[[NSOperationQueue alloc]init]autorelease];
    [opq addOperation:operation];
}


- (void) fetchMapXML:(NSString *)mapName
{
    NSString* xmlPathz = [self.xmlPath stringByAppendingFormat:@"%@.xml",mapName];
    AFGDataXMLRequestOperation *operation = [AFGDataXMLRequestOperation XMLDocumentRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:xmlPathz]] success:^(NSURLRequest *request, NSHTTPURLResponse *response, GDataXMLDocument *XMLDocument)
    {
        NSLog(@"[XML] Downloaded map successfully");
        //RenderingTree* tree = [XMLUtil loadRenderingTreeFromGDataXMLDocument:XMLDocument];
        //[Scene loadCustomTree:tree];
        [Scene getInstance].treeDoc = XMLDocument;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchMapEventFinished" object:nil];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, GDataXMLDocument *XMLDocument)
    {
        NSLog(@"[XML] Failed to download map");
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
        NSString *xmlPath1   = [JSON valueForKeyPath:@"XML_PATH"];
        NSString *imagePath1 = [JSON valueForKeyPath:@"MAP_IMAGE_PATH"];
        
        self.xmlPath = [basePath stringByAppendingString:xmlPath1];
        self.imagePath = [basePath stringByAppendingString:imagePath1];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error: %@", error);
        NSLog(@"Response %@", JSON);
    }];
    
    [operation start];
}

- (void) fetchMapImageWithName:(Map*) map
{
    NSString* imageName = [map.name stringByAppendingString:@".jpg"];    
    NSURL *url = [NSURL URLWithString:[self.imagePath stringByAppendingString:imageName]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    AFImageRequestOperation *requestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image)
    {
        map.image = image;
    }];
    NSOperationQueue* opq = [[[NSOperationQueue alloc]init]autorelease];
    [opq addOperation:requestOperation];
}

- (BOOL) validateLogin:(NSString*)username :(NSString*)password
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"login", @"action",
                            username, @"username",
                            password, @"password",
                            nil];
    
    [self.AFClient postPath:self.mapsAPIScript parameters:params
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Success [Login]: %@", operation.responseString);
                [Session getInstance].isAuthenticated = YES;
                //Just because we can
                [NSThread sleepForTimeInterval:1.0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginEventFinish" object:nil];
    }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error [Login]: %@", operation.responseString);
                //Just because we can
                [NSThread sleepForTimeInterval:1.0];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginEventFinish" object:nil];
    }];
    
    return [Session getInstance].isAuthenticated;
}

- (void) assignNewMaps:(NSMutableArray*)maps
{
    [MapContainer getInstance];
    [MapContainer assignNewMaps:maps];
}

- (void) dealloc
{
    [super dealloc];
    [AFClient release];
    [xmlPath release];
    [imagePath release];
    [mapsAPIScript release];
}

@end
