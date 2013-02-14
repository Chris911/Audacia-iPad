//
//  Texture2DUtil.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-02-10.
//
//  Original post from : http://iphonedevelopment.blogspot.ca/2009/05/opengl-es-from-ground-up-part-6_25.html

#import "Texture2DUtil.h"

@implementation Texture2DUtil

+ (void) load2DTextureFromName:(NSString*)name {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"Image not loaded");

    GLuint width = CGImageGetWidth(image.CGImage);
    GLuint height = CGImageGetHeight(image.CGImage);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context, 0, height - height );
    CGContextDrawImage( context, CGRectMake( 0, 0, width, height ), image.CGImage );

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);

    CGContextRelease(context);

    free(imageData);
    [image release];
    [texData release];
}

+ (void) load2DTextureFromNamePVRTC:(NSString*)name :(int)size;
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"pvrtc"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    
    // This assumes that source PVRTC image is 4 bits per pixel and RGB not RGBA
    // If you use the default settings in texturetool, e.g.:
    //
    //      texturetool -e PVRTC -o texture.pvrtc texture.png
    //
    // then this code should work fine for you.
    glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, size, size, 0, [texData length], [texData bytes]);
    [texData release];
}

@end
