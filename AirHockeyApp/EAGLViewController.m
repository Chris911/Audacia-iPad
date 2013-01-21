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
    
    BOOL isCameraTranslateActive;
    
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
    
    isCameraTranslateActive = NO;
 
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
    NSLog(@"Position de tous les doigts venant de commencer à toucher l'écran");            
    for(UITouch* touch in touches) {
        CGPoint positionCourante = [touch locationInView:self.view];
        
        // Use touch coordinates to try and select a Node
        Vector3D pos = Vector3DMake([self convertFromScreenToWorld:positionCourante].x, [self convertFromScreenToWorld:positionCourante].y, 0);
        
        // Check if any node was selected with the first touch.
        // If not, we can move the camera
        if([[Scene getInstance].renderingTree selectNodeByPosition:pos])
        {
            NSLog(@"Touch resulted in node selection");
        } else {
            NSLog(@"Touch did not select any node");
            // TODO: Introduce camera movement here
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
        //CGPoint positionPrecedente = [touch previousLocationInView:self.view];
        
        // Try to translate a selected object if any
        // FIXME: Only one type of camera by now, so this
        // statement may not make sense.  It will later
        if(!isCameraTranslateActive){
            [[Scene getInstance].renderingTree translateSelectedNodes:
                CGPointMake([self convertFromScreenToWorld:positionCourante].x,
                            [self convertFromScreenToWorld:positionCourante].y)];
        } else if (isCameraTranslateActive) {
            camPosX = [self convertFromScreenToWorld:positionCourante].x;
            camPosY = [self convertFromScreenToWorld:positionCourante].y;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)rotationDetectee:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer numberOfTouches] == 2)
    {
        CGPoint position = [gestureRecognizer locationInView:self.view];
        NSLog(@"Centre de rotation x: %f y: %f",position.x, position.y);        
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
    isCameraTranslateActive = !isCameraTranslateActive;
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

	CGRect rect = self.view.bounds;
    
    glViewport(0, 0, rect.size.width, rect.size.height);    
	glMatrixMode(GL_MODELVIEW);

	glLoadIdentity(); 
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    
	glGetError(); // Clear error codes
}

- (void)drawFrame
{

    [(EAGLView *)self.view setFramebuffer];
        
//    gluPerspective(60, LARGEUR_FENETRE/HAUTEUR_FENETRE, 0.1, 2000);
//    gluLookAt(camPosX, camPosY, -50,
//              0, 0, 0,
//              0, 1, 0);

    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    glOrthof(-(LARGEUR_FENETRE / 2 + camPosX)*zoomFactor, (LARGEUR_FENETRE / 2 + camPosX)*zoomFactor,
             -(HAUTEUR_FENETRE / 2 + camPosY)*zoomFactor, (HAUTEUR_FENETRE / 2 +camPosY)*zoomFactor, 0, 100);
	glMatrixMode(GL_MODELVIEW);
    
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    
    // Renders the whole rendring tree
    [[Scene getInstance].renderingTree render];
        
//	static NSTimeInterval lastDrawTime;
//	if (lastDrawTime)
//	{
//		NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
//		rotation+=50 * timeSinceLastDraw;				
//		Rotation3D rot;
//		rot.x = rotation;
//		rot.y = rotation;
//		rot.z = rotation;
//		[[Scene getInstance].renderingTree rotateSelectedNodes:rot];
//	}
//	lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
    
    [(EAGLView *)self.view presentFramebuffer];
}

#pragma mark - UI Animations
//Animation when user swipes a side view out (from left to right)
-(void)slideOutAnimationView:(UIView*)view
{
    if(view.tag == CAMERAVIEW_TAG) { // bottom left view
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.frame.size.width/2, HAUTEUR_ECRAN - view.frame.size.height/2);
             }
        completion:nil];
    }
    else if(view.tag == PARAMETERSVIEW_TAG) {
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.center.x, HAUTEUR_ECRAN + view.frame.size.height/2);
                 
             }
             completion:nil];
    }
}

//Animation when user swipes a side view in (from right to left)
-(void)slideInAnimationView:(UIView*)view
{
    if(view.tag == CAMERAVIEW_TAG){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(-view.frame.size.width/2, HAUTEUR_ECRAN + view.frame.size.height);
                 
             }
        completion:nil];
    }
    else if(view.tag == PARAMETERSVIEW_TAG){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 view.center = CGPointMake(view.center.x, HAUTEUR_ECRAN - view.frame.size.height/2);
                 
             }
        completion:nil];
    }
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer
{

    CGPoint beginningPoint = [recognizer locationInView:[self view]];
    
    // Slide from left to right on LeftSideView
    if(beginningPoint.x < 300){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 self.LeftSlideView.center = CGPointMake(-self.LeftSlideView.frame.size.width, self.LeftSlideView.center.y);
             }
        completion:nil];
        
        //Also close parameters view bar if opened
        [self slideOutAnimationView:self.ParametersView];
    }
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer
{
    CGPoint beginningPoint = [recognizer locationInView:[self view]];
    
    // Slide from right to left on LeftSideView
    if(beginningPoint.x < 50){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
             animations:^{
                 self.LeftSlideView.center = CGPointMake(self.LeftSlideView.frame.size.width/2, self.LeftSlideView.center.y);
             }
        completion:nil];
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
    // Rotation recognizer
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetectee:)];
    [rotationGesture setDelegate:self];
    [self.view addGestureRecognizer:rotationGesture];
    [rotationGesture release];

    // SwipeGesture recognizers
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeLeft:)] autorelease];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self LeftSlideView] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(oneFingerSwipeRight:)] autorelease];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
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
