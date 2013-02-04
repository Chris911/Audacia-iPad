//
//  AudioInterface.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-03.
//
//

#import <Foundation/Foundation.h>
#import "SimpleAudioEngine.h"

@interface AudioInterface : NSObject

+ (void) loadSounds;
+ (void) playSound:(NSString*)name;
+ (void) startBackgroundMusic;
+ (void) stopBackgroundMusic;

@end

