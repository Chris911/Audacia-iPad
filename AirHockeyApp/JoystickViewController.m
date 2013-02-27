//
//  JoystickViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-21.
//  Allows end user to move his stick around.
//  Yup, that sounds nasty
//

#import "JoystickViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AsyncSocket.h" 
#import "AsyncUdpSocket.h"
#import "GCDAsyncSocket.h"
#import "Session.h"
@interface JoystickViewController ()
{
    AsyncUdpSocket* updSocket;
    AsyncSocket* tcpSocket;
    
    GCDAsyncSocket *gcdsocket;
    NSString* host;
    UInt16 port;
}

@end

@implementation JoystickViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lifecycle methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup other view
    [self.joystickView.layer setCornerRadius:60.0f];
    [self.joystickView.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [self.joystickView.layer setBorderWidth:1.0f];
    [self.joystickView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.joystickView.layer setShadowOpacity:0.8];
    [self.joystickView.layer setShadowRadius:3.0];
    [self.joystickView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    // Socket
    updSocket = [[AsyncUdpSocket alloc]init];
    tcpSocket = [[AsyncSocket alloc]initWithDelegate:self];
    gcdsocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    host = @"132.207.156.227";
    port = 5050;
    
    [self connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_joystickView release];
    [updSocket release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setJoystickView:nil];
    [super viewDidUnload];
}

- (IBAction)exitPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in touches){
        CGPoint location = [touch locationInView:self.view];
        self.joystickView.center = location;
        [self checkOutOfBounds:location];
        self.joystickView.alpha = 0.7f;
        [self sendUdpPacket:[self convertFromScreenToWorld:location]];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in touches){
        CGPoint location = [touch locationInView:self.view];
        CGPoint lastLocation = [touch previousLocationInView:self.view];

        if(location.x != lastLocation.x && location.y != lastLocation.y){
            self.joystickView.center = location;
            [self checkOutOfBounds:location];
            [self sendUdpPacket:[self convertFromScreenToWorld:location]];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.joystickView.alpha = 0.2f;
}

// Takes a CGPoint from the screen (1024, 768) and
// transforms it to a position for the game (100, 100)
- (CGPoint) convertFromScreenToWorld:(CGPoint)touch
{
    float worldWidth = 200;
    float worldHeight = 150;
    float dx = ((touch.x/1024) * worldWidth) - worldWidth/2;
    float dy = (((768 - touch.y)/768) * worldHeight) - worldHeight/2;
    //NSLog(@"X: %f, Y: %f",dx,dy);
    
    return CGPointMake(dx, dy);
}

#pragma mark - Utility methods
- (void) checkOutOfBounds:(CGPoint)location
{
    // X Bounds 
    if(location.x > 1024 - self.joystickView.frame.size.width/2){
        self.joystickView.center = CGPointMake(1024 - self.joystickView.frame.size.width/2, self.joystickView.center.y);
    } else if(location.x < self.joystickView.frame.size.width/2){
        self.joystickView.center = CGPointMake(self.joystickView.frame.size.width/2, self.joystickView.center.y);
    }
    
    // Y bounds
    if(location.y > 700 - self.joystickView.frame.size.height/2){
        self.joystickView.center = CGPointMake(self.joystickView.center.x, 700 - self.joystickView.frame.size.height/2);
    } else if(location.y < self.joystickView.frame.size.height/2){
        self.joystickView.center = CGPointMake(self.joystickView.center.x, self.joystickView.frame.size.height/2);
    }
}

#pragma mark - Socket methods
// Most methods acquired from or similar to :
// https://github.com/twyatt/asyncsocket-example/blob/master/Classes/SocketTestViewController.m

#include <netinet/tcp.h>
#include <netinet/in.h>
// Connect to server via TCP 
- (void) connect
{
    NSError* error;
    
    [gcdsocket connectToHost:host onPort:port error:&error];
    [gcdsocket performBlock:^{
        int fd = [gcdsocket socketFD];
        int on = 1;
        if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (char*)&on, sizeof(on)) == -1) {
        }
    }];    
    
    NSString* authentification = [authenPack_Head stringByAppendingString:[Session getInstance].username];
    authentification = [authentification stringByAppendingString:authenPack_Separator];
    authentification = [authentification stringByAppendingString:[Session getInstance].password];
    authentification = [authentification stringByAppendingString:authenPack_Trail];

    NSData* testString = [authentification dataUsingEncoding:NSUTF8StringEncoding];
    
    // Send authentification packet
    [gcdsocket writeData:testString withTimeout:-1 tag:-1];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err {
	NSLog(@"Disconnecting. Error: %@", [err localizedDescription]);
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
	NSLog(@"Disconnected.");
    
	[tcpSocket setDelegate:nil];
	[tcpSocket release];
	tcpSocket = nil;
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock {
	NSLog(@"onSocketWillConnect:");
	return YES;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host_ port:(UInt16)port_ {
	NSLog(@"Connected To %@:%i.", host_, port_);
}

- (void) sendUdpPacket:(CGPoint)location
{
    // Casted in int, BAD
    NSString* x = [NSString stringWithFormat:@"%i",(int)location.x];
    NSString* y = [NSString stringWithFormat:@"%i",(int)location.y];
    
    NSString* position = [positionPack_Head stringByAppendingString:x];
    position = [position stringByAppendingString:positionPack_Separator];
    position = [position stringByAppendingString:y];
    position = [position stringByAppendingString:positionPack_Trail];
    
    NSData* testString = [position dataUsingEncoding:NSUTF8StringEncoding];
    [gcdsocket writeData:testString withTimeout:-1 tag:1];
}   

@end
