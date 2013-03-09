//
//  SocketUtil.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-03-09.
//
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface SocketUtil : NSObject

@property (nonatomic, retain) AsyncSocket   *tcpSocket;
@property (nonatomic, retain) NSString      *address;
@property int           port;

+ (SocketUtil *) getInstance;
- (void) connectToServer;
- (void) sendPositionPacketToServer:(CGPoint)point;

@end
