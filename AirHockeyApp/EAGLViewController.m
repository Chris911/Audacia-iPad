//
//  EAGLViewController.m
//  Modified by Team Audacity, orignial code from AppDemo
//  Master OpenGL container, inherited from EAGLView and and UIViewController

#import <QuartzCore/QuartzCore.h>
#import "AppDemoAppDelegate.h"

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "Node.h"
#import "NodeTable.h"
#import "NodePortal.h"
#import "NodeBooster.h"
#import "NodePommeau.h" 
#import "NodePuck.h"
#import "NodeMurret.h"
#import "NetworkUtils.h"
#import "ElasticRect.h"
#import "Particle.h"    
#import "Skybox.h"

#define kAlertNameMapTag 1

// Global constants

// Touches modes
int const TOUCH_TRANSFORM_MODE  = 0;
int const TOUCH_CAMERA_MODE     = 1;
int const TOUCH_ELASTIC_MODE    = 2;
int const TOUCH_HALFLIFE_MODE   = 3;

// UI Views tags
int const CAMERAVIEW_TAG        = 100;
int const PARAMETERSVIEW_TAG    = 200;
int const TRANSFORMVIEW_TAG     = 300;
int const OBJECTSVIEW_TAG       = 400;
int const SETTINGSVIEW_TAG      = 500;
int const LJOYSTICKVIEW_TAG     = 600;
int const RJOYSTICKVIEW_TAG     = 700;
int const LEFTTIPVIEW_TAG       = 800;
int const RIGHTTIPVIEW_TAG      = 900;


// Drag and Drop views tags
int const PORTALVIEW_TAG        = 10;
int const BOOSTERVIEW_TAG       = 20;
int const MURETVIEW_TAG         = 30;
int const PUCKVIEW_TAG          = 40;
int const POMMEAUVIEW_TAG       = 50;

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

@interface EAGLViewController ()
{
    BOOL cameraViewIsHidden;
    BOOL settingViewIsHidden;
    BOOL anyNodeSelected;
    
    BOOL isHalfLifeCamActive;
    
    // Defines the current transformation state (translate,rotation or scale)
    int  currentTransformState;
    
    // Defines the current type of object to add
    int activeObjectTag;
    
    // Defines the current touch moved mode (Transform, Camera or Elastic Rectangle)
    int currentTouchesMode;
    
    // Elastic Rectangle
    ElasticRect *elasticRect;
    
    NSMutableArray *particles;
    
    Skybox* skybox;
    
    Node *selectedNode;
    CGPoint leftJoystickCenter;
    CGPoint rightJoystickCenter;
}

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation EAGLViewController

@synthesize animating;
@synthesize context;
@synthesize displayLink;

#pragma mark - Lifecycle methods

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    currentTransformState   = STATE_TRANSFORM_TRANSLATION;
    currentTouchesMode      = TOUCH_CAMERA_MODE;
    activeObjectTag         = -1;
    isHalfLifeCamActive     = NO;
    
    leftJoystickCenter = CGPointMake(self.leftJoystick.frame.size.width/2,
                                      self.leftJoystick.frame.size.height/2);
    
    rightJoystickCenter = CGPointMake(self.rightJoystick.frame.size.width/2,
                                      self.rightJoystick.frame.size.height/2);
 
    // Create the camera
    self.camera = [[[Camera alloc]init]autorelease];
    
    // Create the elastic rectangle
    elasticRect = [[ElasticRect alloc]init];
    
    // Create the skybox
    skybox = [[Skybox alloc]initWithSize:400.0f];
}

- (void)dealloc
{
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [elasticRect release];
    [skybox release];
    
    [_LeftSlideView release];
    [_CameraView release];
    [_ParametersView release];
    [_TransformView release];
    [_SettingsView release];
    [_PortalView release];
    [_PortalImageView release];
    [_BoosterView release];
    [_BoosterImageView release];
    [_MuretImageView release];
    [_PuckImageView release];
    [_PommeauImageView release];
    [_MuretView release];
    [_PuckView release];
    [_PommeauView release];
    [_sizeSlider release];
    [_angleSlider release];
    [_sizeLabel release];
    [_angleLable release];
    [_leftJoystick release];
    [_rightJoystick release];
    [_leftJoystickTip release];
    [_rightJoystickTip release];
    [_crossHair release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareRecognizers];
    [self prepareAdditionalViews];
}

- (void)viewDidUnload
{
    [self setLeftSlideView:nil];
    [self setCameraView:nil];
    [self setParametersView:nil];
    [self setTransformView:nil];
    [self setSettingsView:nil];
    [self setPortalView:nil];
    [self setPortalImageView:nil];
    [self setBoosterView:nil];
    [self setBoosterImageView:nil];
    [self setMuretImageView:nil];
    [self setPuckImageView:nil];
    [self setPommeauImageView:nil];
    [self setMuretView:nil];
    [self setPuckView:nil];
    [self setPommeauView:nil];
    [self setSizeSlider:nil];
    [self setAngleSlider:nil];
    [self setSizeLabel:nil];
    [self setAngleLable:nil];
    [self setLeftJoystick:nil];
    [self setRightJoystick:nil];
    [self setLeftJoystickTip:nil];
    [self setRightJoystickTip:nil];
    [self setCrossHair:nil];
	[super viewDidUnload];
	
    if (program) {
        glDeleteProgram(program);
        program = 0;
    }

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark - GL Animation methods

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        [self setupView];
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(drawFrame)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

#pragma mark - Touch methods

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in [event allTouches]) {
        CGPoint positionCourante = [touch locationInView:self.view];
        
        // Elastic rectangle mode (Zoom or selection).  Bypass object transformations
        // or Drag and Drop modes.
        if(elasticRect.isActive) {
            elasticRect.beginPosition = [self.camera convertToWorldPosition:positionCourante];
            elasticRect.endPosition = [self.camera convertToWorldPosition:positionCourante];

            currentTouchesMode = TOUCH_ELASTIC_MODE;
        } else {
        
            // Correct touch position according to the camera position (ORTHO)
            [self.camera assignWorldPosition:positionCourante];

            // Detect touch events on the EAGLView (self.view)
            if(touch.view == self.view){
                
                // Check if any node was selected with the first touch and that there aren't multiple nodes selected at the time
                // If not, we can move the camera
                if([[Scene getInstance].renderingTree selectNodeByPosition:self.camera.worldPosition]
                   && ![Scene getInstance].renderingTree.multipleNodesSelected)
                {
                    NSLog(@"Touch resulted in node selection");
                    
                    // Modify the UI (Parameters) of the currently selected Node
                    selectedNode = [[Scene getInstance].renderingTree getSingleSelectedNode];
                    [self modifyUIParametersValues:selectedNode];
                    currentTouchesMode = TOUCH_TRANSFORM_MODE;
                    
                } else if([Scene getInstance].renderingTree.multipleNodesSelected
                          && [[Scene getInstance].renderingTree checkIfAnyNodeClicked:self.camera.worldPosition]) {
                    NSLog(@"Touch resulted in Multi node selection");
                    currentTouchesMode = TOUCH_TRANSFORM_MODE;
                    
                } else {
                    NSLog(@"Touch did not select any node");
                    // TODO: Introduce camera movement here
                    [[Scene getInstance].renderingTree deselectAllNodes];
                    
                    currentTouchesMode = TOUCH_CAMERA_MODE;
                    //if(self.camera.isPerspective == NO){
                        [self slideOutAnimationView:self.ParametersView];
                    //}
                }
                
            // If a view other than EAGLView is touched
            } else {
                [[Scene getInstance].renderingTree deselectAllNodes];
                [self handleFirstTouchOnView:touch.view];
                currentTouchesMode = TOUCH_TRANSFORM_MODE;
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch* touch in [event allTouches]){        
        //NSLog(@"%i",[[event allTouches] count]);

        CGPoint positionCourante = [touch locationInView:self.view];
        CGPoint positionPrecedente = [touch previousLocationInView:self.view];
        
        // This allows to not interfer with the currentTransformState
        if(currentTouchesMode == TOUCH_TRANSFORM_MODE) {
            
            // Place the world positions according to the current camera position
            [self.camera assignWorldPosition:positionCourante];
            
            // Translation Mode ----------------------------------------------------------
            if(currentTransformState == STATE_TRANSFORM_TRANSLATION) {
                
                // Multiple Nodes translation
                if([Scene getInstance].renderingTree.multipleNodesSelected){ 
                    [[Scene getInstance].renderingTree translateMultipleNodes:
                     CGPointMake(self.camera.worldPosition.x,self.camera.worldPosition.y)];
                
                // Single Node translation
                } else { 
                    [[Scene getInstance].renderingTree translateSingleNode:
                     CGPointMake(self.camera.worldPosition.x,self.camera.worldPosition.y)];
                    [self modifyUIParametersValues:selectedNode];
                }
            
            // Rotation Mode ------------------------------------------------------------
            } else if(currentTransformState == STATE_TRANSFORM_ROTATION) {
                CGPoint rotation = [self.camera calculateVelocity:positionPrecedente :positionCourante];
                
                // Multiple Nodes rotation
                if([Scene getInstance].renderingTree.multipleNodesSelected){
                    [[Scene getInstance].renderingTree rotateMultipleNodes:positionCourante:positionPrecedente];
                
                // Single Node rotation
                } else { 
                    [[Scene getInstance].renderingTree rotateSingleNode:Rotation3DMake(rotation.x, rotation.y, 0)];
                    [self modifyUIParametersValues:selectedNode];
                }
               
            // Scaling Mode -------------------------------------------------------------
            } else if(currentTransformState == STATE_TRANSFORM_SCALE) {
                CGPoint scale = [self.camera calculateVelocity:positionPrecedente :positionCourante];
                [[Scene getInstance].renderingTree scaleSelectedNodes:scale.x];
                [self modifyUIParametersValues:selectedNode];
            }
            
        // User is dragging the screen.  Camera is thus moving
        } else if (currentTouchesMode == TOUCH_CAMERA_MODE){
            
            // Move camera in perspective mode
            if(self.camera.isPerspective){
                [self panPerspectiveCamera:positionCourante:positionPrecedente];

            } else {
                [self.camera orthoTranslate:positionCourante:positionPrecedente];
            }
            
        } else if (currentTouchesMode == TOUCH_ELASTIC_MODE) { // Elastic Rectangle mode
            elasticRect.endPosition = [self.camera convertToWorldPosition:positionCourante];
            
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [Scene replaceOutOfBoundsElements];
    if(currentTouchesMode == TOUCH_ELASTIC_MODE) {
        if(elasticRect.isSelectionMode){
            [[Scene getInstance].renderingTree selectNodesByZone:elasticRect.beginPosition :elasticRect.endPosition];
        } else {
            [self.camera zoomInFromRect:elasticRect.beginPosition :elasticRect.endPosition];
        }
        
        if([Scene getInstance].renderingTree.multipleNodesSelected) {
            [self slideInAnimationView:self.ParametersView];
        }
        [elasticRect reset];
    }
    selectedNode = nil; // invalidate pointer
}

#pragma mark - Joystick methods

// Left joystick movements, Camera strafe
- (void) handleLeftJoystickMovement:(UITouch*)touch
{
    //CGPoint location = [touch locationInView:self.leftJoystick];
    
    // Strafe cam
//    float radius = self.leftJoystick.frame.size.width/2;
//    CGPoint delta = CGPointMake((location.x - leftJoystickCenter.x)/20, (location.y - leftJoystickCenter.y)/20);
//    float distanceTipToCenter = (delta.x * delta.x) + (delta.y * delta.y);
//    location = CGPointMake(leftJoystickCenter.x, location.y);
//    
//    if( distanceTipToCenter <= radius){
//        [self.camera perspectiveZoom:delta];
//        [self.view viewWithTag:activeObjectTag].center = location;
//    } else {
//        float angle = atan2(delta.y, delta.x);
//        [self.view viewWithTag:activeObjectTag].center = CGPointMake(128 + radius * cosf(angle),128 + radius*sinf(angle));
//    }
}

// Right joystick movements, Camera rotation
- (void) handleRightJoystickMovement:(UITouch*)touch
{
//    CGPoint location = [touch locationInView:self.rightJoystick];
//    
//    // Rotate cam
//    CGPoint delta = CGPointMake((location.x - rightJoystickCenter.x)/30, (location.y - rightJoystickCenter.y)/30);
//    float radius = self.rightJoystick.frame.size.width/2;
//    float distanceTipToCenter = (delta.x * delta.x) + (delta.y * delta.y);
//    
//    if( distanceTipToCenter <= radius){
//        [self.camera rotateCamera:delta];
//        [self.view viewWithTag:activeObjectTag].center = location;
//    } else {
//        float angle = atan2(delta.y, delta.x);
//        [self.view viewWithTag:activeObjectTag].center = CGPointMake(128 + radius * cosf(angle),128 + radius*sinf(angle));
//    }
}

- (void) replaceJoysticks
{
//    if(activeObjectTag == LEFTTIPVIEW_TAG) {
//        [self.view viewWithTag:activeObjectTag].center =  leftJoystickCenter;
//    } else if(activeObjectTag == RIGHTTIPVIEW_TAG) {
//        [self.view viewWithTag:activeObjectTag].center =  rightJoystickCenter;
//    }
}

#pragma mark - Button methods

- (IBAction)OpenCameraView:(id)sender
{
    if(cameraViewIsHidden){
        [self slideOutAnimationView:self.CameraView];
        cameraViewIsHidden = NO;
    }
    else{
        [self slideInAnimationView:self.CameraView];
        cameraViewIsHidden = YES;
    }
}

- (IBAction)toggleTranslateCamera:(id)sender
{
    [self performSelectorInBackground:@selector(replaceView) withObject:nil];
}

// If the current transform state is translation, switch to rotation
// Will toggle back to translate if pressed again
- (IBAction)toggleTransformRotation:(id)sender
{
    if(currentTransformState != STATE_TRANSFORM_ROTATION) {
        currentTransformState = STATE_TRANSFORM_ROTATION;
    } else {
        currentTransformState = STATE_TRANSFORM_TRANSLATION;
    }
}

// If the current transform state is translation, switch to scale
// Will toggle back to translate if pressed again
- (IBAction)toggleTransformScale:(id)sender
{
    if(currentTransformState != STATE_TRANSFORM_SCALE) {
        currentTransformState = STATE_TRANSFORM_SCALE;
    } else {
        currentTransformState = STATE_TRANSFORM_TRANSLATION;
    }
}

- (IBAction)toggleSettingsView:(id)sender
{
    if(settingViewIsHidden){
        [self slideOutAnimationView:self.SettingsView];
    } else {
        [self slideInAnimationView:self.SettingsView];
    }
    settingViewIsHidden = !settingViewIsHidden;
}

// Turn elastic rectangle setting on or off
- (IBAction)toggleElasticSelection:(id)sender
{   //Can't just toggle or there will be a coherence problem
    if(elasticRect.isActive == YES){
        elasticRect.isActive = NO;
    } else {
        [elasticRect reset];
        elasticRect.isSelectionMode = YES;
        elasticRect.isActive = YES;
    }
}

- (IBAction)toggleElasticZoom:(id)sender
{
    if(elasticRect.isActive == YES){
        elasticRect.isActive = NO;
    } else {
        [elasticRect reset];
        elasticRect.isSelectionMode = NO;
        elasticRect.isActive = YES;
    }
}

- (IBAction)togglePerspective:(id)sender
{
    if(self.camera.isPerspective){
        [self slideOutAnimationView: self.leftJoystick];
        [self slideOutAnimationView: self.rightJoystick];
    }
    self.camera.isPerspective = !self.camera.isPerspective;
}

- (IBAction)ExitProgram:(id)sender
{
    [self stopAnimation];
    [self.camera resetCamera];
    [self resetTable];
    [self resetUI];
    AppDemoAppDelegate* delegate = [[UIApplication sharedApplication] delegate];
    [delegate afficherMenu];
}

- (IBAction)deleteItem:(id)sender
{
    [[Scene getInstance].renderingTree removeSelectedNodes];
    [self slideOutAnimationView:self.ParametersView];
}

- (IBAction)copyItem:(id)sender
{
    [[Scene getInstance].renderingTree copySelectedNodes];
}

- (IBAction)toggleScreenshotButton:(id)sender
{
    if([NetworkUtils isNetworkAvailable])
    {
        [self performSelectorInBackground:@selector(replaceView) withObject:nil];
        [self showNameMapAlert];
    } else {
        [NetworkUtils showNetworkUnavailableAlert];
    }
}

- (IBAction)toggleHalfLifeCam:(id)sender
{
    if(self.camera.isPerspective){
        if(!isHalfLifeCamActive){
            [self hideAllUIElements];
            [self slideInAnimationView:self.rightJoystick];
            [self slideInAnimationView:self.leftJoystick];
        } else {
            [self slideOutAnimationView:self.rightJoystick];
            [self slideOutAnimationView:self.leftJoystick];
        }
        isHalfLifeCamActive = !isHalfLifeCamActive;
    }
}

#pragma mark - Slider action methods
- (IBAction)angleSliderChanged:(id)sender
{
    float angleValue = (self.angleSlider.value * 360);
    [[Scene getInstance].renderingTree rotateBySliderSingleNode:angleValue];
}

- (IBAction)sizeSliderChanged:(id)sender
{
    float scaleValue = (self.sizeSlider.value * 3.5 ) + 0.5;
    [[Scene getInstance].renderingTree scaleBySliderSelectedNodes:scaleValue];
}

#pragma mark - Gesture functions

// Assign the view type (ex : PortalView) so that
// we know what object to add next
- (void) handleFirstTouchOnView:(UIView*) view
{
    if(view.tag > 0) {
        activeObjectTag = view.tag;
        
        if(activeObjectTag == LEFTTIPVIEW_TAG || activeObjectTag == RIGHTTIPVIEW_TAG){
            currentTouchesMode = TOUCH_HALFLIFE_MODE;
        }
    } else {
        NSLog(@"Invalid Tag"); 
    }
}

// Drag and drop objects on the table by using UIView
- (void) panGestureAction:(UIPanGestureRecognizer *) gesture
{
    CGPoint location = [gesture locationInView:self.view];

    if ([gesture state] == UIGestureRecognizerStateBegan) {
        
        // Drag started
        [self.view viewWithTag:activeObjectTag].center = location;
        [self slideOutAnimationView:self.ParametersView];

    } else if ([gesture state] == UIGestureRecognizerStateChanged) {
        
        // Drag moved
        [self.view viewWithTag:activeObjectTag].center = location;

    } else if ([gesture state] == UIGestureRecognizerStateEnded) {
        
        // Drag completed
        [self.view viewWithTag:activeObjectTag].center = location;
        [self.camera assignWorldPosition:location];
        
        [self addDragAndDropObject];
        
        //Finally, replace the views to their distinct origins
        if(activeObjectTag == PORTALVIEW_TAG) {
            [self.view viewWithTag:activeObjectTag].center =  self.PortalImageView.center;
        } else if(activeObjectTag == BOOSTERVIEW_TAG) {
            [self.view viewWithTag:activeObjectTag].center =  self.BoosterImageView.center;
        } else if(activeObjectTag == MURETVIEW_TAG) {
            [self.view viewWithTag:activeObjectTag].center =  self.MuretImageView.center;
        } else if(activeObjectTag == PUCKVIEW_TAG) {
            [self.view viewWithTag:activeObjectTag].center =  self.PuckImageView.center;
        } else if(activeObjectTag == POMMEAUVIEW_TAG) {
            [self.view viewWithTag:activeObjectTag].center =  self.PommeauImageView.center;
        } 
    }
}

- (void) addDragAndDropObject
{
    // Check if last touch location is legal
    if([Scene checkIfAddingLocationInBounds:CGPointMake(self.camera.worldPosition.x, self.camera.worldPosition.y)]){
        // Add a specific Node to the scene and replace the dragged view
        //FIXME: Z positions can break the adding
        if(activeObjectTag == PORTALVIEW_TAG) {
            NodePortal *portal = [[[NodePortal alloc]init]autorelease];
            [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(self.camera.worldPosition.x,
                                                                                                     self.camera.worldPosition.y,
                                                                                                     1)];
        } else if(activeObjectTag == BOOSTERVIEW_TAG) {
            NodeBooster *booster = [[[NodeBooster alloc]init]autorelease];
            [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(self.camera.worldPosition.x,
                                                                                                      self.camera.worldPosition.y,
                                                                                                      2)];
        } else if(activeObjectTag == MURETVIEW_TAG) {
            NodeBooster *booster = [[[NodeBooster alloc]init]autorelease];
            [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(self.camera.worldPosition.x,
                                                                                                      self.camera.worldPosition.y,
                                                                                                      1)];
        } else if(activeObjectTag == PUCKVIEW_TAG) {
            [[Scene getInstance].renderingTree addPuckToTreeWithInitialPosition:Vector3DMake(self.camera.worldPosition.x,
                                                                                             self.camera.worldPosition.y,
                                                                                             1)];
            
        } else if(activeObjectTag == POMMEAUVIEW_TAG) {
            [[Scene getInstance].renderingTree addStickToTreeWithInitialPosition:Vector3DMake(self.camera.worldPosition.x,
                                                                                              self.camera.worldPosition.y,
                                                                                              1)];
        }
    }

}

#pragma mark - Core GL Methods
-(void)setupView
{
    // Load the scene objects
    [self loadScene];
    
    // Prepare the lights
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    GLfloat lightpos[] = {0, 0, 500.0, 0.0};
    glLightfv(GL_LIGHT0, GL_POSITION, lightpos);
    
    // Prepare the view and colors
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_COLOR_MATERIAL);
	glMatrixMode(GL_PROJECTION);
	CGRect rect = self.view.bounds;    
    glViewport(0, 0, rect.size.width, rect.size.height);    
	glMatrixMode(GL_MODELVIEW);

	glLoadIdentity(); 
	//glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    
	glGetError(); // Clear error codes
}

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
    // Set the camera either in ortho or perspective mode
    [self.camera setCamera];
    
    //Render the skybox
    [skybox render];
    
    glEnable(GL_CULL_FACE);
    // Renders the whole rendring tree
    [[Scene getInstance].renderingTree render];
    glDisable(GL_CULL_FACE);
    
    // Render the elastic rectangle if active
    if(elasticRect.isActive){
        [elasticRect render];
    }
    
    [(EAGLView *)self.view presentFramebuffer];
}

#pragma mark - UI Animations
//Animation when user swipes a side view out (from left to right)
-(void)slideOutAnimationView:(UIView*)view
{
    //FIXME: HardCoded slide in values, change that to const
    if(view.tag == CAMERAVIEW_TAG) { // bottom left view
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.frame.size.width/2, HAUTEUR_ECRAN - view.frame.size.height/2);
             }
        completion:nil];
    } else if(view.tag == PARAMETERSVIEW_TAG) {
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.center.x, HAUTEUR_ECRAN + view.frame.size.height/2);
             }
             completion:nil];
    } else if(view.tag == TRANSFORMVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(TRANSFORMVIEW_INITIAL_POSITION, view.center.y);
                         }
                         completion:nil];
    } else if(view.tag == OBJECTSVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(OBJECTVIEW_INITIAL_POSITION, view.center.y);
                         }
                         completion:nil];
    } else if(view.tag == SETTINGSVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(1024 - view.frame.size.width/2, HAUTEUR_ECRAN - view.frame.size.height/2);
                         }
                         completion:nil];
    } else if(view.tag == LJOYSTICKVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(-512,view.center.y);
                             [self.crossHair setAlpha:0];

                         }
                         completion:nil];
    } else if(view.tag == RJOYSTICKVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(1024 + 512,view.center.y);
                         }
                         completion:nil];
    }
}

// Animate a view so it slides in the iPad screen
-(void)slideInAnimationView:(UIView*)view
{
    if(view.tag == CAMERAVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(-view.frame.size.width/2, HAUTEUR_ECRAN + view.frame.size.height);
                 
             }
        completion:nil];
    } else if(view.tag == PARAMETERSVIEW_TAG){
        [UIView animateWithDuration:0.1 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.center.x, HAUTEUR_ECRAN - view.frame.size.height/2);
                 
             }
        completion:nil];
    } else if(view.tag == TRANSFORMVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(1024 - view.frame.size.width/2, view.center.y);
                             
                         }
                         completion:nil];
    } else if(view.tag == OBJECTSVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(view.bounds.size.width/2, view.center.y);
                             
                         }
                         completion:nil];
    } else if(view.tag == SETTINGSVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(1024 + view.frame.size.width/2, HAUTEUR_ECRAN + view.frame.size.height);
                             
                         }
                         completion:nil];
    } else if(view.tag == LJOYSTICKVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(250,view.center.y);
                             [self.crossHair setAlpha:1];

                         }
                         completion:nil];
    } else if(view.tag == RJOYSTICKVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(1024 - 250,view.center.y);
                         }
                         completion:nil];
    }
}

- (void) hideAllUIElements
{
    [self slideOutAnimationView:self.ParametersView];
    [self slideOutAnimationView:self.LeftSlideView];
    [self slideOutAnimationView:self.TransformView];
    [self slideInAnimationView:self.SettingsView];
    [self slideInAnimationView:self.CameraView];
}

- (void)SwipeLeftSideView:(UITapGestureRecognizer *)recognizer
{
    [self slideOutAnimationView:self.LeftSlideView];
}

- (void)SwipeTransformView:(UITapGestureRecognizer *)recognizer
{
    // When closing the transform view, return to translation mode
    currentTransformState = STATE_TRANSFORM_TRANSLATION;
    [Scene getInstance].renderingTree.multipleNodesSelected = NO;
    [elasticRect reset];
    [self slideOutAnimationView:self.TransformView];

}

- (void)SwipeTransformView_Main:(UITapGestureRecognizer *)recognizer
{
    [self slideInAnimationView:self.LeftSlideView];
}

- (void)SwipeLeftSideView_Main:(UITapGestureRecognizer *)recognizer
{    
    [self slideInAnimationView:self.TransformView];    
}

- (void) handlePinch:(UIGestureRecognizer *)sender 
{
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    if(self.camera.isPerspective){
        [self.camera perspectiveZoom:factor];
    } else {
        [self.camera orthoZoom:factor];
    }
}

#pragma mark - Elements initialization
- (void) loadScene
{
    // Initialize Scene and rendring tree
    [Scene getInstance];
    [[Scene getInstance].renderingTree emptyRenderingTree];
    [Scene loadDefaultElements];
    
}

- (void) prepareRecognizers
{
    // SwipeGesture recognizers
    
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(rotationDetected:)];
    [rotationRecognizer setDelegate:self];
    [self.view addGestureRecognizer:rotationRecognizer];
    [rotationRecognizer release];
    
    // Placed on the LeftSideView
    UISwipeGestureRecognizer *SwipeLeftSideView = [[[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(SwipeLeftSideView:)] autorelease];
    [SwipeLeftSideView setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self LeftSlideView] addGestureRecognizer:SwipeLeftSideView];
    
    // Placed on the the main view (for LeftSideView)
    UISwipeGestureRecognizer *SwipeTransformView_Main = [[[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(SwipeTransformView_Main:)] autorelease];
    [SwipeTransformView_Main setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self LeftSlideView] addGestureRecognizer:SwipeTransformView_Main];
    
    // Placed on the the main view (for TransformView)
    UISwipeGestureRecognizer *SwipeLeftSideView_Main = [[[UISwipeGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(SwipeLeftSideView_Main:)] autorelease];
    [SwipeLeftSideView_Main setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self TransformView] addGestureRecognizer:SwipeLeftSideView_Main];
    
    // Placed on the LeftSideView
    UISwipeGestureRecognizer *SwipeTransformView = [[[UISwipeGestureRecognizer alloc]
                                                       initWithTarget:self
                                                       action:@selector(SwipeTransformView:)] autorelease];
    [SwipeTransformView setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self TransformView] addGestureRecognizer:SwipeTransformView];
    
    // PinchGesture recognizer
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [pinchGesture setDelegate:self];
    [self.view addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    // PanGesture recognizer for drag n drop
    UIPanGestureRecognizer *dndPortal = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dndBooster = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dndMuret = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dndPuck = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dndPommeau = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dragLjoystick = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    UIPanGestureRecognizer *dragRjoystick = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];

    [self.PortalView addGestureRecognizer:dndPortal];
    [self.BoosterView addGestureRecognizer:dndBooster];
    [self.MuretView addGestureRecognizer:dndMuret];
    [self.PuckView addGestureRecognizer:dndPuck];
    [self.PommeauView addGestureRecognizer:dndPommeau];
    //[self.leftJoystickTip addGestureRecognizer:dragLjoystick];
    //[self.rightJoystickTip addGestureRecognizer:dragRjoystick];

    [dndBooster release];
    [dndPortal release];
    [dndMuret release];
    [dndPuck release];
    [dndPommeau release];
    [dragLjoystick release];
    [dragRjoystick release];
    
    // Pan for camera, 2 fingers
//    UIPanGestureRecognizer *panPerspectiveCamera = [[UIPanGestureRecognizer alloc]
//                                                    initWithTarget:self
//                                                    action:@selector(panGestureAction:)];
//    panPerspectiveCamera.minimumNumberOfTouches = 2;
//    [self.view addGestureRecognizer:panPerspectiveCamera];
//    [panPerspectiveCamera release];

}

- (void) prepareAdditionalViews
{
    cameraViewIsHidden  = YES;
    settingViewIsHidden = YES;
    anyNodeSelected     = YES;
    
    // Hide the views out of the screen
    self.LeftSlideView.center = CGPointMake(OBJECTVIEW_INITIAL_POSITION ,self.LeftSlideView.center.y);
    self.CameraView.center = CGPointMake(-self.CameraView.frame.size.width,
                                         HAUTEUR_ECRAN + self.CameraView.frame.size.height);
    self.ParametersView.center = CGPointMake(self.ParametersView.center.x,
                                             self.ParametersView.center.y + self.ParametersView.bounds.size.height);
    self.TransformView.center = CGPointMake(TRANSFORMVIEW_INITIAL_POSITION,self.TransformView.center.y);
    self.SettingsView.center = CGPointMake(1024 + self.SettingsView.frame.size.width,
                                         HAUTEUR_ECRAN + self.SettingsView.frame.size.height);
    self.leftJoystick.center = CGPointMake(-512, 540);
    self.rightJoystick.center = CGPointMake(1024 + 512, 540);
    [self.crossHair setAlpha:0];
}

#pragma mark - Reset table utility

- (void) resetUI
{
    [self prepareAdditionalViews];
}

- (void) resetTable
{
    currentTransformState = STATE_TRANSFORM_TRANSLATION;
    activeObjectTag = -1;
    [[Scene getInstance].renderingTree emptyRenderingTree];
}

#pragma mark - Modify UI Elements
- (void) modifyUIParametersValues:(Node*)node 
{
    if(![node.type isEqualToString:@"EDGE"]){
        if(!isHalfLifeCamActive){ //FIXME: Slide not appropriate
            [self slideInAnimationView:self.ParametersView];
        }
    } else {
        [self slideOutAnimationView:self.ParametersView];
    }

    [self hideOrShowParameters:node];
    self.sizeSlider.value = node.scaleFactor/4;
    self.angleSlider.value = node.angle/360;
}

- (void) hideOrShowParameters:(Node*)node
{
    if([node.type isEqualToString:@"POMMEAU"] || [node.type isEqualToString:@"PUCK"] || [Scene getInstance].renderingTree.multipleNodesSelected){
        // Hide some parameters if the selected nodes are Puck or Stick
        [self.sizeLabel setHidden:YES];
        [self.sizeSlider setHidden:YES];
        
    } else {
        [self.sizeLabel setHidden:NO];
        [self.sizeSlider setHidden:NO];
    }
}

#pragma mark - Screenshot Utility
//
//Source: http://developer.apple.com/library/ios/#qa/qa1704/_index.html
//
- (UIImage*) getGLScreenshot
{
    GLint backingWidth, backingHeight;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point,
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
    //glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        //CGFloat scale = eaglview.contentScaleFactor;
        CGFloat scale = 1.0;
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

#pragma mark - UIAlertViewDelegate
- (void)showNameMapAlert
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Veuillez entrer le nom de la carte"
                                                      message:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Upload", nil];
    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
    message.tag = kAlertNameMapTag;
    [message show];
    [message release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertNameMapTag){
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        //TODO: Do some validation here
        WebClient *webClient = [[WebClient alloc]initWithDefaultServer];
        NSData *xmlData = [XMLUtil getRenderingTreeXmlData:[Scene getInstance].renderingTree];
        // Upload data to server
        [webClient uploadMapData:inputText :xmlData :[self getGLScreenshot]];
        [webClient release];
    }
}

- (void) replaceView
{
    if(self.camera.isPerspective){
        [self.camera resetCamera];
    } else {
        [self.camera replaceCamera];
    }
}

- (void) rotationDetected:(UIGestureRecognizer *)sender 
{
    CGFloat angle = [(UIRotationGestureRecognizer *)sender rotation];
    self.camera.theta += angle*2;
}

- (void) panPerspectiveCamera:(CGPoint)location :(CGPoint)lastLocation
{
    CGPoint delta = CGPointMake(location.x - lastLocation.x, location.y - lastLocation.y);
    [self.camera strafeXY:delta];
}

@end
