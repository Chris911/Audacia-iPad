//
//  EAGLViewController.m
//  AppDemo
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLViewController.h"
#import "EAGLView.h"
#import "NodeTable.h"

#define kAlertNameMapTag 1

// Global constants
float const LARGEUR_FENETRE = 200;
float const HAUTEUR_FENETRE = 150;

int const LARGEUR_ECRAN = 1024;
int const HAUTEUR_ECRAN = 768;

int const CAMERAVIEW_TAG      = 100;
int const PARAMETERSVIEW_TAG  = 200;
int const TRANSFORMVIEW_TAG   = 300;
int const OBJECTSVIEW_TAG     = 400;



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
    BOOL anyNodeSelected;
    
    BOOL cameraTranslation;
    int  currentTransformState;
    
    float camPosX, camPosY, camPosZ;
    float zoomFactor;
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
    
    cameraTranslation = YES;
    currentTransformState = STATE_TRANSFORM_TRANSLATION;
 
    //Initialize Scene and rendring tree
    [Scene getInstance];
    
    // Loading the Default Map
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
    
    [_LeftSlideView release];
    [_CameraView release];
    [_ParametersView release];
    [_TransformView release];
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
        
        // Use touch coordinates to try and select a Node
        Vector3D pos = Vector3DMake([self convertFromScreenToWorld:positionCourante].x,
                                    [self convertFromScreenToWorld:positionCourante].y, 0);
        
        // Check if any node was selected with the first touch.
        // If not, we can move the camera
        if([[Scene getInstance].renderingTree selectNodeByPosition:pos])
        {
            NSLog(@"Touch resulted in node selection");
            [self slideInAnimationView:self.ParametersView];
            cameraTranslation = NO;
        } else {
            NSLog(@"Touch did not select any node");
            // TODO: Introduce camera movement here
            cameraTranslation = YES;
            [self slideOutAnimationView:self.ParametersView];
        }
    }
    
    // Multi-touch 
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        //CGPoint positionCourante = [touch locationInView:self.view];
    }    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] == 1)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint positionCourante = [touch locationInView:self.view];
        CGPoint positionPrecedente = [touch previousLocationInView:self.view];
        
        // 3 types of transformations.  If no node is selected,
        // then the camera will be panning around.  This allow
        // to not interfer with the currentTransformState
        
        if(!cameraTranslation) {
            if(currentTransformState == STATE_TRANSFORM_TRANSLATION) {
                [[Scene getInstance].renderingTree translateSelectedNodes:
                    CGPointMake([self convertFromScreenToWorld:positionCourante].x,
                                [self convertFromScreenToWorld:positionCourante].y)];
                
            } else if(currentTransformState == STATE_TRANSFORM_ROTATION) {
                CGPoint rotation = [self calculateVelocity:positionPrecedente :positionCourante];
                [[Scene getInstance].renderingTree rotateSelectedNodes:Rotation3DMake(rotation.x, rotation.y, 0)];
                
            } else if(currentTransformState == STATE_TRANSFORM_SCALE) {
                CGPoint scale = [self calculateVelocity:positionPrecedente :positionCourante];
                [[Scene getInstance].renderingTree scaleSelectedNodes:scale.x];
                
            }
            
        // User is dragging the screen.  Camera is thus moving
        } else {
            //camPosX = [self convertFromScreenToWorld:positionCourante].x;
            //camPosY = [self convertFromScreenToWorld:positionCourante].y;
        }

    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [Scene replaceOutOfBoundsElements];
    cameraTranslation = NO;
}

-(CGPoint) calculateVelocity:(CGPoint) lastTouch:(CGPoint) currentTouch
{
    return CGPointMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
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

- (IBAction)TouchButtonInViewTEST:(id)sender
{
    if(anyNodeSelected)
        [self slideInAnimationView:self.ParametersView];
    else
        [self slideOutAnimationView:self.ParametersView];
    anyNodeSelected = !anyNodeSelected;

}

- (IBAction)toggleTranslateCamera:(id)sender
{
    [self slideInAnimationView:self.TransformView];
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

#pragma mark - Core GL Methods

-(void)setupView
{
    camPosX = 0;
    camPosY = 0;
    camPosZ = 0;
    zoomFactor = 1;
    
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
//    gluPerspective(60, LARGEUR_FENETRE/HAUTEUR_FENETRE, 0.1, 2000);
//    gluLookAt(camPosX, camPosY, -50,
//              0, 0, 0,
//              0, 1, 0);

    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // Orthogonal Mode
    glOrthof(camPosX -(LARGEUR_FENETRE / 2)*zoomFactor, camPosX + (LARGEUR_FENETRE / 2)*zoomFactor,
             -(HAUTEUR_FENETRE / 2)*zoomFactor, (HAUTEUR_FENETRE / 2)*zoomFactor, -100, 100);
	glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Renders the whole rendring tree
    [[Scene getInstance].renderingTree render];
    [(EAGLView *)self.view presentFramebuffer];
}

#pragma mark - UI Animations
//Animation when user swipes a side view out (from left to right)
-(void)slideOutAnimationView:(UIView*)view
{
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
                             view.center = CGPointMake(1024 + view.frame.size.width/2, view.center.y);
                             
                         }
                         completion:nil];
    } else if(view.tag == OBJECTSVIEW_TAG){
        [UIView animateWithDuration:0.2 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(-view.frame.size.width/2, view.center.y);
                             
                         }
                         completion:nil];
    }
}

//Animation when user swipes a side view in (from right to left)
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
                             view.center = CGPointMake(view.frame.size.width/2, view.center.y);
                             
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
    [self slideOutAnimationView:self.TransformView];
}

- (void)SwipeTransformView_Main:(UITapGestureRecognizer *)recognizer
{
    CGPoint beginningPoint = [recognizer locationInView:[self view]];
    
    // Slide from right to left on LeftSideView
    if(beginningPoint.x < 50){
        [self slideInAnimationView:self.LeftSlideView];
    }
}

- (void)SwipeLeftSideView_Main:(UITapGestureRecognizer *)recognizer
{
    CGPoint beginningPoint = [recognizer locationInView:[self view]];
    
    // Slide from right to left on LeftSideView
    if(beginningPoint.x >900){
        [self slideInAnimationView:self.TransformView];
    }
}


float mCurrentScale, mLastScale;
-(void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    NSLog(@"ZoomFactor = %f",zoomFactor);

    mCurrentScale += [sender scale] - mLastScale;
    mLastScale = [sender scale];
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        mLastScale = 1.0;
    }
    if(mCurrentScale > 1) {
        zoomFactor += mCurrentScale/20;
        if(zoomFactor >= 3.0f)
            zoomFactor = 2.9f;
    } else {
        
        zoomFactor -= mCurrentScale/20;
        if(zoomFactor <= 0.5f)
            zoomFactor = 0.51f;
    }
}

#pragma mark - Screen conversion
// Takes a screen coordinate point and convert it to predefined world coords
- (CGPoint)convertFromScreenToWorld:(CGPoint)pos
{
    pos = CGPointMake((pos.x * (LARGEUR_FENETRE/1024) - LARGEUR_FENETRE/2) * zoomFactor,
                      -(pos.y * (HAUTEUR_FENETRE/HAUTEUR_ECRAN) - HAUTEUR_FENETRE/2) * zoomFactor);
    return pos;
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
    [[self view] addGestureRecognizer:SwipeTransformView_Main];
    
    // Placed on the the main view (for TransformView)
    UISwipeGestureRecognizer *SwipeLeftSideView_Main = [[[UISwipeGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(SwipeLeftSideView_Main:)] autorelease];
    [SwipeLeftSideView_Main setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:SwipeLeftSideView_Main];
    
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
}

- (void) prepareAdditionalViews
{
    cameraViewIsHidden  = YES;
    anyNodeSelected     = YES;
    
    // Hide the views out of the screen
    self.LeftSlideView.center = CGPointMake(-self.LeftSlideView.bounds.size.width,self.LeftSlideView.center.y);
    self.CameraView.center = CGPointMake(-self.CameraView.frame.size.width,
                                         HAUTEUR_ECRAN + self.CameraView.frame.size.height);
    self.ParametersView.center = CGPointMake(self.ParametersView.center.x,
                                             self.ParametersView.center.y + self.ParametersView.bounds.size.height);
    self.TransformView.center = CGPointMake(self.TransformView.center.x+self.TransformView.bounds.size.width,self.TransformView.center.y);
}

#pragma mark - Screenshot Utility

- (IBAction)toggleScreenshotButton:(id)sender
{
    [self showNameMapAlert];
}

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
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertNameMapTag){
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        //TODO: Do some validation here
        WebClient *webClient = [[WebClient alloc]initWithDefaultServer];
        [webClient uploadMapData:inputText :[self getGLScreenshot]];
        [webClient release];
    }
}

@end
