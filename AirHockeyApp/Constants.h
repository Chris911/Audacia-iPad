//
//  Constants.h
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-01-18.
//
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

// Main constants interface for whole project

// EAGLViewController Constants
extern const int STATE_TRANSFORM_TRANSLATION;
extern const int STATE_TRANSFORM_ROTATION;
extern const int STATE_TRANSFORM_SCALE;
extern const int OBJECTVIEW_INITIAL_POSITION;
extern const int TRANSFORMVIEW_INITIAL_POSITION;


// Table constants
extern const int TABLE_LIMIT_X;
extern const int TABLE_LIMIT_Y;
extern const int NB_OF_TRIANGLES;
extern const int NB_OF_TABLE_EDGES;
extern const GLfloat TABLE_DEPTH;

// Camera constants
extern float const LARGEUR_FENETRE;
extern float const HAUTEUR_FENETRE;
extern int const LARGEUR_ECRAN;
extern int const HAUTEUR_ECRAN;



@end
