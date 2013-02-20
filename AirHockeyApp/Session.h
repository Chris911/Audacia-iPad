//
//  Session.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-28.
//
//

#import <Foundation/Foundation.h>

@interface Session : NSObject

@property (nonatomic,retain) NSString* username;
@property (nonatomic,retain) NSString* password;
@property BOOL isAuthenticated;

+ (Session *) getInstance;
+ (void) resetSession;

@end
