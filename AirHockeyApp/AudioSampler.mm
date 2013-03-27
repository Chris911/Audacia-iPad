////
////  AudioSampler.m
////  AirHockeyApp
////
////  Created by Sam DesRochers on 2013-03-27.
////
////
//
//#import "AudioSampler.h"
//#import <Foundation/Foundation.h>
//#import <CoreFoundation/CoreFoundation.h>
//#include <AudioToolbox/AudioToolbox.h>
//#define kInputFileLocation	CFSTR("/Users/petermarks/Developer/CoreAudio/FloatExtract/loop.wav")
//
//
//@implementation AudioSampler
//
//static void CheckResult(OSStatus error, const char *operation)
//{
//	if (error == noErr) return;
//	char errorString[20];
//	// See if it appears to be a 4-char-code
//	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
//	if (isprint(errorString[1]) && isprint(errorString[2]) &&
//		isprint(errorString[3]) && isprint(errorString[4])) {
//		errorString[0] = errorString[5] = '\'';
//		errorString[6] = '\0';
//	} else
//		// No, format it as an integer
//		sprintf(errorString, "%d", (int)error);
//	
//	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
//	exit(1);
//}
//
//+ (void) extract
//{
//    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flex_dubstep" ofType:@"mp3"];
//    NSURL *songUrl = [NSURL fileURLWithPath:filePath];
//    CFURLRef url = (CFURLRef)songUrl;
//    
//    OSStatus ExtAudioFileCreateWithURL (
//                                        CFURLRef                          url,
//                                        AudioFileTypeID                   inFileType,
//                                        const AudioStreamBasicDescription *inStreamDesc,
//                                        const AudioChannelLayout          *inChannelLayout,
//                                        UInt32                            inFlags,
//                                        ExtAudioFileRef                   *outExtAudioFile
//                                        );
//
//    // 1) Open an Extended Audio File
////	CFURLRef inputFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
////                                                          filePath,
////                                                          kCFURLPOSIXPathStyle,
////                                                          false);
//    CFURLRef inputFileURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
//    
//	ExtAudioFileRef fileRef;
//	CheckResult(ExtAudioFileOpenURL(inputFileURL, &fileRef), "ExtAudioFileOpenURL failed");
//	
//	// 2) Set up audio format
//	AudioStreamBasicDescription audioFormat;
//	audioFormat.mSampleRate = 44100;
//	audioFormat.mFormatID = kAudioFormatLinearPCM;
//	audioFormat.mFormatFlags = kLinearPCMFormatFlagIsFloat;
//	audioFormat.mBitsPerChannel = sizeof(Float32) * 8;
//	audioFormat.mChannelsPerFrame = 1; // set this to 2 for stereo
//	audioFormat.mBytesPerFrame = audioFormat.mChannelsPerFrame * sizeof(Float32);
//	audioFormat.mFramesPerPacket = 1;
//	audioFormat.mBytesPerPacket = audioFormat.mFramesPerPacket * audioFormat.mBytesPerFrame;
//	
//	// 3) Apply audio format to my Extended Audio File
//	CheckResult(ExtAudioFileSetProperty(fileRef,
//                                        kExtAudioFileProperty_ClientDataFormat,
//                                        sizeof (AudioStreamBasicDescription),
//                                        &audioFormat),
//				"Couldn't set client data format on input ext file");
//	
//	
//	// 4) Set up an AudioBufferList
//	UInt32 outputBufferSize = 32 * 1024; // 32 KB
//	UInt32 sizePerPacket = audioFormat.mBytesPerPacket;
//	UInt32 packetsPerBuffer = outputBufferSize / sizePerPacket;
//	UInt8 *outputBuffer = (UInt8 *)malloc(sizeof(UInt8 *) * outputBufferSize);
//	AudioBufferList convertedData;
//	convertedData.mNumberBuffers = 2;
//	convertedData.mBuffers[0].mNumberChannels = audioFormat.mChannelsPerFrame;
//	convertedData.mBuffers[0].mDataByteSize = outputBufferSize;
//	convertedData.mBuffers[0].mData = outputBuffer;
//	
//	// 5) Read Extended Audio File into AudioBufferList with ExtAudioFileRead()
//	UInt32 frameCount = packetsPerBuffer;
//	CheckResult(ExtAudioFileRead(fileRef,
//                                 &frameCount,
//                                 &convertedData),
//				"ExtAudioFileRead failed");
//	
//	// 6) Log float values of AudioBufferList
//	for( int y=0; y<convertedData.mNumberBuffers; y++ )
//	{
//		NSLog(@"buffer# %u", y);
//		AudioBuffer audioBuffer = convertedData.mBuffers[y];
////		int bufferSize = audioBuffer.mDataByteSize / sizeof(Float32);
////		Float32 *frame = audioBuffer.mData;
////		for( int i=0; i<bufferSize; i++ ) {
////			Float32 currentSample = frame[i];
////			NSLog(@"currentSample: %f", currentSample);
////		}
//	}
//    NSLog(@"done");
//}
//
//@end
