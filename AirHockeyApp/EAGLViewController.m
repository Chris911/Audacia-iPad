//
//  EAGLViewController.m
//  Modified by Team Audacity, orignial code from AppDemo
//  Master OpenGL container, inherited from EAGLView and and UIViewController

#import <QuartzCore/QuartzCore.h>
#import "AppDemoAppDelegate.h"

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "NodeTable.h"
#import "NodePortal.h"
#import "NodeBooster.h"
#import "NodePommeau.h" 
#import "NodePuck.h"
#import "NodeMurret.h"
#import "NetworkUtils.h"
#import "ElasticRect.h"

#define kAlertNameMapTag 1

// Global constants

// Touches modes
int const TOUCH_TRANSFORM_MODE = 0;
int const TOUCH_CAMERA_MODE = 1;
int const TOUCH_ELASTIC_MODE = 2;

// UI Views tags
int const CAMERAVIEW_TAG      = 100;
int const PARAMETERSVIEW_TAG  = 200;
int const TRANSFORMVIEW_TAG   = 300;
int const OBJECTSVIEW_TAG     = 400;
int const SETTINGSVIEW_TAG    = 500;

// Drag and Drop views tags
int const PORTALVIEW_TAG      = 10;
int const BOOSTERVIEW_TAG     = 20;
int const MURETVIEW_TAG       = 30;
int const PUCKVIEW_TAG        = 40;
int const POMMEAUVIEW_TAG     = 50;

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
    BOOL firstTimeBuilding;
    BOOL cameraViewIsHidden;
    BOOL settingViewIsHidden;
    BOOL anyNodeSelected;
    
    BOOL cameraTranslation;
    
    // Defines the current transformation state (translate,rotation or scale)
    int  currentTransformState;
    
    // Defines the current type of object to add
    int activeObjectTag;
    
    // Defines the current touch moved mode (Transform, Camera or Elastic Rectangle)
    int currentTouchesMode;
    
    // Elastic Rectangle
    ElasticRect *elasticRect;
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
    
    firstTimeBuilding       = YES;
    currentTransformState   = STATE_TRANSFORM_TRANSLATION;
    currentTouchesMode      = TOUCH_CAMERA_MODE;
    activeObjectTag         = -1;
 
    // Create the camera
    self.camera = [[[Camera alloc]init]autorelease];
    
    // Create the elastic rectangle
    elasticRect = [[ElasticRect alloc]init];
    
    // Initialize Scene and rendring tree
    [Scene getInstance];
    
    // Init from default map
    [Scene loadDefaultElements];
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
    
    [self.camera release];
    [elasticRect release];
    
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
    
    // Load default elements only when switching to this EAGL View
    if(!firstTimeBuilding) {
        [self setupView];
        [Scene loadDefaultElements];
    }
    firstTimeBuilding = NO;
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
    for(UITouch* touch in touches) {
        CGPoint positionCourante = [touch locationInView:self.view];

        // Elastic rectangle mode (Zoom or selection).  Bypass object transformations
        // or Drag and Drop modes.
        if(elasticRect.isActive) {
            elasticRect.beginPosition = [self.camera convertToWorldPosition:positionCourante];
            elasticRect.endPosition = [self.camera convertToWorldPosition:positionCourante];

            currentTouchesMode = TOUCH_ELASTIC_MODE;
        } else {
        
            // Correct touch position according to the camera position
            [self.camera assignWorldPosition:positionCourante];

            // Detect touch events on the EAGLView (self.view)
            if(touch.view == self.view){
                
                
                
                // Check if any node was selected with the first touch and that there aren't multiple nodes selected at the time
                // If not, we can move the camera
                if([[Scene getInstance].renderingTree selectNodeByPosition:self.camera.worldPosition] && ![Scene getInstance].renderingTree.multipleNodesSelected)
                {
                    NSLog(@"Touch resulted in node selection");
                    [self slideInAnimationView:self.ParametersView];
                    currentTouchesMode = TOUCH_TRANSFORM_MODE;
                } else if([Scene getInstance].renderingTree.multipleNodesSelected) {
                    NSLog(@"Touch resulted in Multi node selection");
                    currentTouchesMode = TOUCH_TRANSFORM_MODE;
                } else {
                    NSLog(@"Touch did not select any node");
                    // TODO: Introduce camera movement here
                    //[self.camera orthoTranslate:positionCourante:positionPrecedente];
                    
                    currentTouchesMode = TOUCH_CAMERA_MODE;
                    [self slideOutAnimationView:self.ParametersView];
                }
                
            // If a view other than EAGLView is touched, we want
            // to handle the drag and drop functionnality
            } else {
                [[Scene getInstance].renderingTree deselectAllNodes];
                [self handleFirstTouchOnView:touch.view];
            }
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] >= 1){
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint positionCourante = [touch locationInView:self.view];
        CGPoint positionPrecedente = [touch previousLocationInView:self.view];
        
        // This allows to not interfer with the currentTransformState
        if(currentTouchesMode == TOUCH_TRANSFORM_MODE) {
            
            // Place the world positions according to the current camera position
            [self.camera assignWorldPosition:positionCourante];
            
            if(currentTransformState == STATE_TRANSFORM_TRANSLATION) {
                [[Scene getInstance].renderingTree translateSelectedNodes:
                    CGPointMake(self.camera.worldPosition.x,self.camera.worldPosition.y)];
                
            } else if(currentTransformState == STATE_TRANSFORM_ROTATION) {
                CGPoint rotation = [self.camera calculateVelocity:positionPrecedente :positionCourante];
                [[Scene getInstance].renderingTree rotateSelectedNodes:Rotation3DMake(rotation.x, rotation.y, 0)];
                
            } else if(currentTransformState == STATE_TRANSFORM_SCALE) {
                CGPoint scale = [self.camera calculateVelocity:positionPrecedente :positionCourante];
                [[Scene getInstance].renderingTree scaleSelectedNodes:scale.x];
            }
            
        // User is dragging the screen.  Camera is thus moving
        } else if (currentTouchesMode == TOUCH_CAMERA_MODE){
            [self.camera orthoTranslate:positionCourante:positionPrecedente];
            
        } else if (currentTouchesMode == TOUCH_ELASTIC_MODE) { // Elastic Rectangle mode
            [elasticRect modifyRect:[self.camera convertToWorldPosition:positionCourante]
                                   :[self.camera convertToWorldPosition:positionPrecedente]];
            elasticRect.endPosition = [self.camera convertToWorldPosition:positionCourante];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [Scene replaceOutOfBoundsElements];
    if(currentTouchesMode == TOUCH_ELASTIC_MODE) {
        [[Scene getInstance].renderingTree selectNodesByZone:elasticRect.beginPosition :elasticRect.endPosition];
        [elasticRect reset];
    }
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
- (IBAction)toggleElasticRect:(id)sender
{   //Can't just toggle or there will be a coherence problem
    if(elasticRect.isActive == YES){
        elasticRect.isActive = NO;
    } else {
        elasticRect.isActive = YES;
    }
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

#pragma mark - Drag And Drop function

// Assign the view type (ex : PortalView) so that
// we know what object to add next
- (void) handleFirstTouchOnView:(UIView*) view
{
    if(view.tag > 0) {
        activeObjectTag = view.tag;
    } else {
        NSLog(@"Invalid Tag");
    }
}

// Drag and drop objects on the table by using UIView
- (void) dragAndDrop:(UIPanGestureRecognizer *) gesture
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
        
        // Check if last touch location is legal
        if([Scene checkIfAddingLocationInBounds:CGPointMake(self.camera.worldPosition.x, self.camera.worldPosition.y)]){
            // Add a specific Node to the scene and replace the dragged view
            //FIXME: Z positions can break the adding
            if(activeObjectTag == PORTALVIEW_TAG) {
                NodePortal *portal = [[[NodePortal alloc]init]autorelease];
                [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:portal :Vector3DMake(self.camera.worldPosition.x,
                                                                                                         self.camera.worldPosition.y,
                                                                                                         5)];
                
            } else if(activeObjectTag == BOOSTERVIEW_TAG) {
                NodeBooster *booster = [[[NodeBooster alloc]init]autorelease];
                [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(self.camera.worldPosition.x,
                                                                                                          self.camera.worldPosition.y,
                                                                                                          5)];
                
            } else if(activeObjectTag == MURETVIEW_TAG) {
                NodeBooster *booster = [[[NodeBooster alloc]init]autorelease];
                [[Scene getInstance].renderingTree addNodeToTreeWithInitialPosition:booster :Vector3DMake(self.camera.worldPosition.x,
                                                                                                          self.camera.worldPosition.y,
                                                                                                          5)];
                
            } else if(activeObjectTag == PUCKVIEW_TAG) {
                [[Scene getInstance].renderingTree addPuckToTreeWithInitialPosition:Vector3DMake(self.camera.worldPosition.x,
                                                                                                 self.camera.worldPosition.y,
                                                                                                 5)];
                
            } else if(activeObjectTag == POMMEAUVIEW_TAG) {
                [[Scene getInstance].renderingTree addStickToTreeWithInitialPosition:Vector3DMake(self.camera.worldPosition.x,
                                                                                                  self.camera.worldPosition.y,
                                                                                                  5)];
            }
        }
        
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

#pragma mark - Core GL Methods
-(void)setupView
{
    glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);
    
    //FIXME: Remove or change for lights
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
	CGRect rect = self.view.bounds;
    
    glViewport(0, 0, rect.size.width, rect.size.height);    
	glMatrixMode(GL_MODELVIEW);

	glLoadIdentity(); 
	glClearColor(0.2f, 0.2f, 0.2f, 1.0f);
    
	glGetError(); // Clear error codes
}

- (void)drawFrame
{

    [(EAGLView *)self.view setFramebuffer];
      // Perspective Mode
//    glMatrixMode(GL_PROJECTION);
//    gluPerspective(60, LARGEUR_FENETRE/HAUTEUR_FENETRE, 0.1, 2000);
//    gluLookAt(camPosX, camPosY, -50,
//              0, 0, 0,
//              0, 1, 0);

    
//    glMatrixMode(GL_PROJECTION);
//    glLoadIdentity();
//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    // Orthogonal Mode
//    glOrthof(camPosX -(LARGEUR_FENETRE / 2)*zoomFactor, camPosX + (LARGEUR_FENETRE / 2)*zoomFactor,
//             -(HAUTEUR_FENETRE / 2)*zoomFactor, (HAUTEUR_FENETRE / 2)*zoomFactor, -100, 100);
//	glMatrixMode(GL_MODELVIEW);
    [self.camera setCamera];
    
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Renders the whole rendring tree
    [[Scene getInstance].renderingTree render];
    
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
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
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
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
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
    }
}

- (void)SwipeLeftSideView:(UITapGestureRecognizer *)recognizer
{
    [self slideOutAnimationView:self.LeftSlideView];
}

- (void)SwipeTransformView:(UITapGestureRecognizer *)recognizer
{
    // When closing the transform view, return to translation mode
    currentTransformState = STATE_TRANSFORM_TRANSLATION;
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
    [self.camera orthoZoom:factor];
}

#pragma mark - UI Elements initialization
- (void) prepareRecognizers
{
    // SwipeGesture recognizers
    
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
    [self.view addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    // PanGesture recognizer for drag n drop
    UIPanGestureRecognizer *dndPortal = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAndDrop:)];
    UIPanGestureRecognizer *dndBooster = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAndDrop:)];
    UIPanGestureRecognizer *dndMuret = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAndDrop:)];
    UIPanGestureRecognizer *dndPuck = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAndDrop:)];
    UIPanGestureRecognizer *dndPommeau = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAndDrop:)];
    [self.PortalView addGestureRecognizer:dndPortal];
    [self.BoosterView addGestureRecognizer:dndBooster];
    [self.MuretView addGestureRecognizer:dndMuret];
    [self.PuckView addGestureRecognizer:dndPuck];
    [self.PommeauView addGestureRecognizer:dndPommeau];
    [dndBooster release];
    [dndPortal release];
    [dndMuret release];
    [dndPuck release];
    [dndPommeau release];
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

#pragma mark - Screenshot Utility
//
//Source: http://getsetgames.com/2009/07/30/5-ways-to-take-screenshots-of-your-iphone-app/
//
- (UIImage*) getGLScreenshot
{
    NSInteger myDataLength = LARGEUR_ECRAN * HAUTEUR_ECRAN * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, LARGEUR_ECRAN, HAUTEUR_ECRAN, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    for(int y = 0; y<HAUTEUR_ECRAN; y++)
    {
        for(int x = 0; x<LARGEUR_ECRAN * 4; x++)
        {
            buffer2[(HAUTEUR_ECRAN-1 - y) * LARGEUR_ECRAN * 4 + x] = buffer[y * 4 * LARGEUR_ECRAN + x];
        }
    }
    
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
    
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * LARGEUR_ECRAN;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(LARGEUR_ECRAN, HAUTEUR_ECRAN, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
    return myImage;
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
        [xmlData release];
    }
}

- (void) replaceView
{
    [self.camera replaceCamera];
}



@end
