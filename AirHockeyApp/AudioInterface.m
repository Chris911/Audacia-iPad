//
//  AudioInterface.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-03.
//
//

#import "AudioInterface.h"

@implementation AudioInterface

+ (void) loadSounds
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pew-pew.wav"];
}

+ (void) playSound:(NSString*)name
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew.wav"];
}

+ (void) startBackgroundMusic
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"technoloop.m4a"];
}

+ (void) stopBackgroundMusic
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

@end
