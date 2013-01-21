//
//  WebClient.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-20.
//
//  Client to connect to web server.
//  Wrapper for the AFNetworking HTTP Client

#import "WebClient.h"

@implementation WebClient
@synthesize AFClient;
@synthesize server;
@synthesize uploadScript;

- (id) initWithDefaultServer
{
    if((self = [super init])) {
        self.server = @"http://kepler.step.polymtl.ca/";
        self.uploadScript = @"/projet3/scripts/upload.php";
        NSURL *url = [NSURL URLWithString:self.server];
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        self.AFClient = httpClient;
        [url release];
        [httpClient release];
    }
    return self;
}

- (void) uploadMapData:(NSString*)mapName :(UIImage*)mapImage
{
    [self uploadImageData:mapImage :mapName];
}

- (void) uploadXMLData:(NSString*)mapName
{
    
}

- (void) uploadImageData:(UIImage*)image :(NSString*)mapName
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [mapName stringByAppendingString:@".png"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.uploadScript parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation start];
}

@end
