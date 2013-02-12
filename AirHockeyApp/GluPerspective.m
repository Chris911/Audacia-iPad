//
//  GluPerspective.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-16.
//  Original code from http://iphonedevelopment.blogspot.ca/2008/12/gluperspective.html
//
#include "GluPerspective.h"

void gluPerspective(double fovy , double aspect , double zNear , double zFar)
{
    // Start in projection mode.
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    double xmin, xmax, ymin, ymax;
    ymax = zNear * tan(fovy * M_PI / 360.0);
    ymin = -ymax;
    xmin = ymin * aspect;
    xmax = ymax * aspect;
    glFrustumf(xmin, xmax, ymin, ymax, zNear, zFar);
}