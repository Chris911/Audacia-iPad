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
        [httpClient release];
    }
    return self;
}

- (void) uploadMapData:(NSString*)mapName :(NSData *)xmlData :(UIImage*)mapImage
{
    [self uploadXMLData:xmlData :mapName];
    [self uploadImageData:mapImage :mapName];
}

- (void) uploadXMLData:(NSData*)xmlData :(NSString *)mapName
{
    NSString *fileName = [mapName stringByAppendingString:@".xml"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.uploadScript parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:xmlData name:@"file" fileName:fileName mimeType:@"application/xml"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes [XML]", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation start];
}

- (void) uploadImageData:(UIImage*)image :(NSString*)mapName
{
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *fileName = [mapName stringByAppendingString:@".png"];
    
    NSMutableURLRequest *request = [self.AFClient multipartFormRequestWithMethod:@"POST" path:self.uploadScript parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/png"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        NSLog(@"Sent %lld of %lld bytes [SS]", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [operation start];
}

@end
