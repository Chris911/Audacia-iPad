//
//  GluPerspective.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//  Original code from http://iphonedevelopment.blogspot.ca/2008/12/gluperspective.html
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

void gluPerspective(double fovy , double aspect , double zNear , double zFar);

