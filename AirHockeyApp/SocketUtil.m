//
//  SocketUtil.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-03-09.
//
//

#import "SocketUtil.h"
#import "AsyncSocket.h"
#import "Session.h"

@implementation SocketUtil

static SocketUtil* socketUtil = NULL;

// Singleton class
+ (SocketUtil *) getInstance
{
    [self initialize];
    return (socketUtil);
}

+ (void) initialize
{
    if(socketUtil == nil)
    {
        socketUtil = [[SocketUtil alloc]init];
        socketUtil.tcpSocket = [[[AsyncSocket alloc]initWithDelegate:self]autorelease];
        socketUtil.address = @"127.0.0.1";
        socketUtil.port = 5050;
    }
}

// Try and connect to the game server. If it fails, will throw an error in the approriate callback of this Class
- (void) connectToServer
{
    NSError *error;
    [socketUtil.tcpSocket connectToHost:socketUtil.address onPort:socketUtil.port error:&error];
}

// Validation with the game server so the player can send data
+ (void) validateUser
{
    NSString* authentification = [authenPack_Head stringByAppendingString:[Session getInstance].username];
    authentification = [authentification stringByAppendingString:authenPack_Separator];
    authentification = [authentification stringByAppendingString:[Session getInstance].password];
    authentification = [authentification stringByAppendingString:authenPack_Trail];
    
    NSData* validation = [authentification dataUsingEncoding:NSUTF8StringEncoding];
    
    // Send authentification packet
    [socketUtil.tcpSocket writeData:validation withTimeout:-1 tag:1];
    
    // Wait for answer from server (5 seconds)
    [socketUtil.tcpSocket readDataWithTimeout:-1 tag:1];
}

// Using a CGPoint, converts it to a NSData packet which is then sent to the game server
- (void) sendPositionPacketToServer:(CGPoint)point
{
    // Casted in int, BAD
    NSString* x = [NSString stringWithFormat:@"%i",(int)point.x];
    NSString* y = [NSString stringWithFormat:@"%i",(int)point.y];
    
    NSString* position = [positionPack_Head stringByAppendingString:x];
    position = [position stringByAppendingString:positionPack_Separator];
    position = [position stringByAppendingString:y];
    position = [position stringByAppendingString:positionPack_Trail];
    
    NSData* positionPacket = [position dataUsingEncoding:NSUTF8StringEncoding];
    [socketUtil.tcpSocket writeData:positionPacket withTimeout:-1 tag:1];
}

#pragma mark - Callbacks
+ (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FailConnectedToGameServer" object:nil];
    
}

+ (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	NSLog(@"Disconnected.");
    
	//[socketUtil.tcpSocket setDelegate:nil];
	//[socketUtil.tcpSocket release];
	//socketUtil.tcpSocket = nil;
}

+ (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

+ (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host_ port:(UInt16)port_ {
	NSLog(@"Connected To %@:%i.", host_, port_);
    [self validateUser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectedToGameServer" object:nil];
}

//-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
//{
//    NSString* newStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
//    NSLog(@"didReadData : %@", newStr);
//}

// Custom did read data "callback", f***you asyncsocket
- (void) getReadData:(NSData*)data
{
    NSString* newStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"didReadData : %@", newStr);
}

- (void) dealloc
{
    [super dealloc];
    //[socketUtil.tcpSocket release];
    //[socketUtil.address release];
    [socketUtil release];
}

@end
