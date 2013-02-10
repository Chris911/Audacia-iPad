//
//  Constants.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-18.
//
//

#import "Constants.h"

@implementation Constants

const int STATE_TRANSFORM_TRANSLATION    = 1;
const int STATE_TRANSFORM_ROTATION       = 2;
const int STATE_TRANSFORM_SCALE          = 3;
const int OBJECTVIEW_INITIAL_POSITION    = -26;
const int TRANSFORMVIEW_INITIAL_POSITION = 1050;

const int TABLE_LIMIT_X                  = 75;
const int TABLE_LIMIT_Y                  = 55;
const int NB_OF_TRIANGLES                = 8;
const int NB_OF_TABLE_EDGES              = 8;
const GLfloat TABLE_HEIGHT                = 0;

float const LARGEUR_FENETRE = 200;
float const HAUTEUR_FENETRE = 150;
int const LARGEUR_ECRAN = 1024;
int const HAUTEUR_ECRAN = 768;

float lightAmbient[] = { 0.2f, 0.3f, 0.6f, 1.0f };
float lightDiffuse[] = { 0.2f, 0.3f, 0.6f, 1.0f };
float matAmbient[] = { 0.6f, 0.6f, 0.6f, 1.0f };
float matDiffuse[] = { 0.6f, 0.6f, 0.6f, 1.0f };

@end
