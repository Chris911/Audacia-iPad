//
//  ShaderUtils.m
//  AirHockeyApp
//
//  Created by Chris on 13-01-15.
//
//

#import "ShaderUtils.h"

@implementation ShaderUtils

- (GLuint) buildShader:(NSString *)fileName:(GLenum)shaderType
{
    NSString* shaderExt;
    if(shaderType == GL_VERTEX_SHADER) {
        shaderExt = @"vsh";
    } else {
        shaderExt = @"fsh";
    }
    
    NSString *shaderSource = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                                                 pathForResource:fileName ofType:shaderExt] encoding:NSUTF8StringEncoding error:nil];
    const char *shaderSourceCString = [shaderSource cStringUsingEncoding:NSUTF8StringEncoding];
    
    GLuint shaderHandle = glCreateShader(shaderType);
    GLenum error = glGetError();
    NSLog(@"%i", error);
    glShaderSource(shaderHandle, 1, &shaderSourceCString, NULL);
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"Error loading shaders: %s", messages);
        exit(1);
    }
    
    return shaderHandle;
}


- (GLuint) buildProgram:(NSString *)shaderSourceFile {
    GLuint vertexShader =   [self buildShader:shaderSourceFile :GL_VERTEX_SHADER];
    GLuint fragmentShader = [self buildShader:shaderSourceFile :GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSLog(@"Error loading shaders: %s", messages);
        exit(1);
    }
    
    return programHandle;
}


@end
