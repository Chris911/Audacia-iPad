//
//  EAGLViewController.h
//  AppDemo
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "OpenGLWaveFrontObject.h"
#import "Scene.h"
#import "WebClient.h"
#import "XMLUtil.h"
#import "Camera.h"

extern float const LARGEUR_FENETRE;
extern float const HAUTEUR_FENETRE;

@interface EAGLViewController : UIViewController <UIGestureRecognizerDelegate, UIAlertViewDelegate> {
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;
@property (nonatomic, retain) Camera *camera;

@property (retain, nonatomic) IBOutlet UIView *LeftSlideView;
@property (retain, nonatomic) IBOutlet UIView *CameraView;
@property (retain, nonatomic) IBOutlet UIView *ParametersView;
@property (retain, nonatomic) IBOutlet UIView *TransformView;
@property (retain, nonatomic) IBOutlet UIView *SettingsView;

// Image Views for drag n drop
@property (retain, nonatomic) IBOutlet UIView *PortalImageView;
@property (retain, nonatomic) IBOutlet UIImageView *BoosterImageView;
@property (retain, nonatomic) IBOutlet UIImageView *MuretImageView;
@property (retain, nonatomic) IBOutlet UIImageView *PuckImageView;
@property (retain, nonatomic) IBOutlet UIImageView *PommeauImageView;

// Views for drag and drop
@property (retain, nonatomic) IBOutlet UIView *PortalView;
@property (retain, nonatomic) IBOutlet UIView *BoosterView;
@property (retain, nonatomic) IBOutlet UIView *MuretView;
@property (retain, nonatomic) IBOutlet UIView *PuckView;
@property (retain, nonatomic) IBOutlet UIView *PommeauView;

// Parameters UI elements
@property (retain, nonatomic) IBOutlet UISlider *sizeSlider;
@property (retain, nonatomic) IBOutlet UISlider *angleSlider;
@property (retain, nonatomic) IBOutlet UILabel *sizeLabel;
@property (retain, nonatomic) IBOutlet UILabel *angleLable;

// Joystick UI elements
@property (retain, nonatomic) IBOutlet UIView *leftJoystick;
@property (retain, nonatomic) IBOutlet UIView *rightJoystick;
@property (retain, nonatomic) IBOutlet UIView *leftJoystickTip;
@property (retain, nonatomic) IBOutlet UIView *rightJoystickTip;
@property (retain, nonatomic) IBOutlet UIImageView *crossHair;


- (void)startAnimation;
- (void)stopAnimation;
- (void)setupView;

- (IBAction)OpenCameraView:(id)sender;
- (IBAction)toggleTranslateCamera:(id)sender;
- (IBAction)toggleScreenshotButton:(id)sender;
- (IBAction)toggleTransformRotation:(id)sender;
- (IBAction)toggleTransformScale:(id)sender;
- (IBAction)toggleSettingsView:(id)sender;
- (IBAction)toggleElasticSelection:(id)sender;
- (IBAction)ExitProgram:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)copyItem:(id)sender;
- (IBAction)toggleElasticZoom:(id)sender;
- (IBAction)togglePerspective:(id)sender;
- (IBAction)angleSliderChanged:(id)sender;
- (IBAction)sizeSliderChanged:(id)sender;
- (IBAction)toggleHalfLifeCam:(id)sender;




@end
