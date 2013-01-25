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
@property (retain, nonatomic) IBOutlet UIView *LeftSlideView;
@property (retain, nonatomic) IBOutlet UIView *CameraView;
@property (retain, nonatomic) IBOutlet UIView *ParametersView;
@property (retain, nonatomic) IBOutlet UIView *TransformView;
@property (retain, nonatomic) IBOutlet UIView *SettingsView;
@property (retain, nonatomic) IBOutlet UIView *PortalView;
@property (retain, nonatomic) IBOutlet UIView *PortalImageView;
@property (retain, nonatomic) IBOutlet UIView *BoosterView;
@property (retain, nonatomic) IBOutlet UIImageView *BoosterImageView;

- (void)startAnimation;
- (void)stopAnimation;
- (void)setupView;

- (IBAction)OpenCameraView:(id)sender;
- (IBAction)toggleTranslateCamera:(id)sender;
- (IBAction)toggleScreenshotButton:(id)sender;
- (IBAction)toggleTransformRotation:(id)sender;
- (IBAction)toggleTransformScale:(id)sender;
- (IBAction)toggleSettingsView:(id)sender;
- (IBAction)ExitProgram:(id)sender;
@end
