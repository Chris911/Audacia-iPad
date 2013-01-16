//
//  EAGLViewController.m
//  AppDemo
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLViewController.h"
#import "EAGLView.h"

// Global constants
float const LARGEUR_FENETRE = 200;
float const HAUTEUR_FENETRE = 150;

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
}
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end


/* TEST */
/* TEST */
struct Vertex {
    float Position[2];
    float Color[4];
} vertexsize;

// Define the positions and colors(R,G,B,A) of two triangles.
const struct Vertex Vertices[] = {
    {{-0.5, 0}, {1, 0, 0, 1}},
    {{0, 0.5},  {0, 1, 0, 1}},
    {{0.5, 0},  {1, 1, 0, 1}},
    {{0, -0.5}, {1, 0, 1, 1}},
    
};

//Define the order of vertices
//0,1,2 forms first triangle
//2,3,0 form second triangle.
const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};
/* TEST */
/* TEST */

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
 
    //Initialize Scene
    [Scene getInstance];
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
    // Releases the view if it doesn't have a superview.
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
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationDetectee:)];
    [rotationGesture setDelegate:self];
    [self.view addGestureRecognizer:rotationGesture];
    [rotationGesture release];
    
    // Add swipeGestures
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
        
    cameraViewIsHidden  = YES;
    anyNodeSelected     = YES;
    
    // Hide the views out of the screen
    self.LeftSlideView.center = CGPointMake(-self.LeftSlideView.bounds.size.width,self.LeftSlideView.center.y);
    self.CameraView.center = CGPointMake(-self.CameraView.frame.size.width,
                                         768 + self.CameraView.frame.size.height);
    self.ParametersView.center = CGPointMake(self.ParametersView.center.x,
                                             self.ParametersView.center.y + self.ParametersView.bounds.size.height);
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

#pragma mark - GL Animation methods

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
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
        NSLog(@"x: %f y: %f", positionCourante.x, positionCourante.y);        
    }        
    NSLog(@"Position de tous les doigts sur l'écran");            
    NSSet *allTouches = [event allTouches];
    for(UITouch* touch in allTouches) {
        CGPoint positionCourante = [touch locationInView:self.view];
        NSLog(@"x: %f y: %f", positionCourante.x, positionCourante.y);        
    }
    NSLog(@"\n\n");
    
}


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    /*
    if ([[event allTouches] count] == 1)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint positionCourante = [touch locationInView:self.view];
        CGPoint positionPrecedente = [touch previousLocationInView:self.view];
        cube.currentPosition = Vertex3DMake(cube.currentPosition.x + (((positionCourante.x - positionPrecedente.x) / self.view.bounds.size.width) * LARGEUR_FENETRE),
                                            cube.currentPosition.y - (((positionCourante.y - positionPrecedente.y) / self.view.bounds.size.height) * HAUTEUR_FENETRE),
                                            cube.currentPosition.z);
    }
     */
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

#pragma mark - Core GL Methods

-(void)setupView
{		
    glEnable(GL_DEPTH_TEST);
	glMatrixMode(GL_PROJECTION);

	CGRect rect = self.view.bounds; 
    
    glOrthof(-(LARGEUR_FENETRE / 2), (LARGEUR_FENETRE / 2), -(HAUTEUR_FENETRE / 2), (HAUTEUR_FENETRE / 2), 0, 100);
    
	glViewport(0, 0, rect.size.width, rect.size.height);  
	glMatrixMode(GL_MODELVIEW);

	glLoadIdentity(); 
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
		
    //Build our shaders and program
    NSString* shaderSourceFifle = @"BasicShader";
    ShaderUtils* shaderUtils = [[[ShaderUtils alloc]init]autorelease];
    program = [shaderUtils buildProgram:shaderSourceFifle];
    glUseProgram(program);
    
    shaderPositionSlot = glGetAttribLocation(program, "Position");
    shaderColorSlot    = glGetAttribLocation(program, "SourceColor");
    
	glGetError(); // Clear error codes
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
	static GLfloat rotation = 0.0;

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glLoadIdentity(); 
	glColor4f(1.0, 1.0, 1.0, 1.0);
    
    //[[Scene getInstance].renderingTree render];
    
    [self drawTriangles];
    
	static NSTimeInterval lastDrawTime;
	if (lastDrawTime)
	{
		NSTimeInterval timeSinceLastDraw = [NSDate timeIntervalSinceReferenceDate] - lastDrawTime;
		rotation+=50 * timeSinceLastDraw;				
		Rotation3D rot;
		rot.x = rotation;
		rot.y = rotation;
		rot.z = rotation;
		[[Scene getInstance].renderingTree rotateSelectedNodes:rot];
	}
	lastDrawTime = [NSDate timeIntervalSinceReferenceDate];
    
    [(EAGLView *)self.view presentFramebuffer];
}

#pragma mark - Draw Triangle Test

- (void) drawTriangles
{
    glPushMatrix();
    glEnableVertexAttribArray(shaderPositionSlot);
    glEnableVertexAttribArray(shaderColorSlot);
    
    
    //Lets give these functions pointer to head of vertex array.
    GLsizei stride = sizeof(vertexsize);
    const GLvoid* pCoords = &Vertices[0].Position[0];
    const GLvoid* pColors = &Vertices[0].Color[0];
    
    glVertexAttribPointer(shaderPositionSlot, 2, GL_FLOAT, GL_FALSE, stride, pCoords);
    glVertexAttribPointer(shaderColorSlot, 4, GL_FLOAT, GL_FALSE, stride, pColors);
    
    //Draw the 2 triangles of the square.
    const GLvoid* bodyIndices = &Indices[0];
    glDrawElements(GL_TRIANGLES,2* 3, GL_UNSIGNED_BYTE, bodyIndices);
    
    glDisableVertexAttribArray(shaderPositionSlot);
    glDisableVertexAttribArray(shaderColorSlot);
    glPopMatrix();
}


#pragma mark - Nodes methods

-(BOOL)checkIfAnyNodeSelected
{
    if(anyNodeSelected)
        return YES;
    return NO;
}

#pragma mark - UI Animations

-(void)slideOutAnimationView:(UIView*)view
{
    if(view.tag == CAMERAVIEW_TAG){ // bottom left view
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(view.frame.size.width/2, 768 - view.frame.size.height/2);
                         }
        completion:nil];
    }
    else if(view.tag == PARAMETERSVIEW_TAG){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(view.center.x, 768 + view.frame.size.height/2);
                             
                         }
                         completion:nil];
    }
}

-(void)slideInAnimationView:(UIView*)view
{
    if(view.tag == CAMERAVIEW_TAG){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(-view.frame.size.width/2, 768 + view.frame.size.height);
                             
                         }
        completion:nil];
    }
    else if(view.tag == PARAMETERSVIEW_TAG){
        [UIView animateWithDuration:0.4 delay: 0.0 options: UIViewAnimationCurveEaseOut
                         animations:^{
                             view.center = CGPointMake(view.center.x, 768 - view.frame.size.height/2);
                             
                         }
                         completion:nil];
    }

}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {

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

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    
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

@end
