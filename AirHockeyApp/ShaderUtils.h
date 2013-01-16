//
//  ShaderUtils.h
//  AirHockeyApp
//
//  Created by Chris on 13-01-15.
//
//

#import "Node.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ShaderUtils : NSObject

- (GLuint) buildShader:(NSString *)fileName:(GLenum)shaderType;
- (GLuint) buildProgram:(NSString *)shaderSourceFile;

@end
