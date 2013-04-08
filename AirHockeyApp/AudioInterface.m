//
//  AudioInterface.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-03.
//
//  Written permission to use the song, flex_dubstep.mp3, in this product for non commercial
//  purpose  was granted by the Author, Flex Vector, on March 28th 2013.

#import "AudioInterface.h"

@implementation AudioInterface

static BOOL soundEnabled = NO;

+ (void) loadSounds
{   
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"camera1.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"sfx1.wav"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"sound1.wav"];
}

+ (void) playSound:(NSString*)name
{
    if(soundEnabled){
        [[SimpleAudioEngine sharedEngine] playEffect:name];
    }
}

+ (void) startBackgroundMusic
{
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"flex_dubstep.mp3"];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.5f];

}

+ (void) stopBackgroundMusic
{
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
}

+ (void) setSoundEnabled:(BOOL) enabled
{
    soundEnabled = enabled;
}

@end
