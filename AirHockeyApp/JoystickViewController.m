//
//  JoystickViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-21.
//
//

#import "JoystickViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AsyncSocket.h" 
#import "AsyncUdpSocket.h"

@interface JoystickViewController ()
{
    AsyncUdpSocket* updSocket;
    AsyncSocket* tcpSocket;
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
    host = @"127.0.0.1";
    port = 5052;
    
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

#pragma mark - Touches Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in touches){
        CGPoint location = [touch locationInView:self.view];
        self.joystickView.center = location;
        [self checkOutOfBounds:location];
        self.joystickView.alpha = 0.7f;
        [self sendUdpPacket:location];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in touches){
        CGPoint location = [touch locationInView:self.view];
        self.joystickView.center = location;
        [self checkOutOfBounds:location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.joystickView.alpha = 0.2f;
    self.joystickView.center = CGPointMake(512, 384);
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

// Connect to server via TCP 
- (void) connect
{
    NSError* error;
    [tcpSocket connectToHost:host onPort:port error:&error];
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
    NSData *data;
    NSString* test = @"Hello World";
    data = [test dataUsingEncoding:NSUTF8StringEncoding];
    //[updSocket sendData:data toHost:host port:port withTimeout:-1 tag:1];
    [tcpSocket writeData:data withTimeout:-1 tag:1];
}   

@end
