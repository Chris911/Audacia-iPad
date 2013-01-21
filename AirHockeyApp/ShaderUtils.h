//
//  ShaderUtils.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-15.
//
//

#import "Node.h"
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface ShaderUtils : NSObject

- (GLuint) buildShader:(NSString *)fileName:(GLenum)shaderType;
- (GLuint) buildProgram:(NSString *)shaderSourceFile;

@end
