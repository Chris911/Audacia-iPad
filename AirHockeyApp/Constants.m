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

const int TABLE_LIMIT_X                  = 85;
const int TABLE_LIMIT_Y                  = 65;
const int NB_OF_TRIANGLES                = 8;
const int NB_OF_TABLE_EDGES              = 8;
const GLfloat TABLE_HEIGHT               = 0;

float const LARGEUR_FENETRE              = 200;
float const HAUTEUR_FENETRE              = 150;
int const LARGEUR_ECRAN                  = 1024;
int const HAUTEUR_ECRAN                  = 768;

float lightAmbient[] = { 1, 1, 1, 1.0f };
float lightDiffuse[] = { 0.2f, 0.3f, 0.6f, 1.0f };
float matAmbient[] = { 1, 1, 1, 1.0f };
float matDiffuse[] = { 1, 0, 0.4f, 1.0f };
float orangeColor[] = { 0.0f, 0.0f, 1.0f, 1.0f };


int GLOBAL_SIZE_OFFSET = 6;

NSString *const leftCamp = @"Gauche";
NSString *const rightCamp = @"Droite";

NSString *const positionPack_Head = @"{\"Type\":\"gameloop\",\"SerializedStruct\":\"{\\\"Pos1\\\":";
NSString *const positionPack_Separator = @",\\\"Pos2\\\":";
NSString *const positionPack_Trail = @"}\"}\0";

NSString *const authenPack_Head = @"{\"Type\":\"authentification\",\"SerializedStruct\":\"{\\\"Username\\\":\\\"";
NSString *const authenPack_Separator = @"\\\",\\\"Password\\\":\\\"";
NSString *const authenPack_Trail = @"\\\",\\\"UserId\\\":\\\"7bd9c930-f07b-4810-b36e-cc1390cc4e33\\\"}\"}";

@end
