//
//  CreditsViewController.m
//  AirHockeyApp
//
//  Created by Sam DesRochers on 2013-04-02.
//
//  Gotta give credits where it's due

#import "CreditsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CreditsViewController ()

@end

@implementation CreditsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareViews];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self rollCredits];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_textView release];
    [_creditView release];
    [_placeHolderView release];
    [_placeHolderImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setCreditView:nil];
    [self setPlaceHolderView:nil];
    [self setPlaceHolderImageView:nil];
    [super viewDidUnload];
}

- (IBAction)backPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) prepareViews
{
    self.textView.backgroundColor = [UIColor clearColor];

    [self.creditView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.creditView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.creditView.layer setShadowOpacity:0.8];
    [self.creditView.layer setShadowRadius:15.0];
    [self.creditView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    
    [self.placeHolderView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.placeHolderView.layer setShadowColor:[UIColor lightGrayColor].CGColor];
    [self.placeHolderView.layer setShadowOpacity:0.8];
    [self.placeHolderView.layer setShadowRadius:20.0];
    [self.placeHolderView.layer setShadowOffset:CGSizeMake(3.0, 3.0)];
    
    NSString *text = @"";
    
    text = [text stringByAppendingString:@"-- iOS Developers -- \n\n"];
    text = [text stringByAppendingString:@"Samuel Des Rochers\n"];
    text = [text stringByAppendingString:@"Christophe Naud-Dulude\n"];
    
    text = [text stringByAppendingString:@"\n\n"];
    
    text = [text stringByAppendingString:@"-- API used for AirHockey App -- \n\n"];
    text = [text stringByAppendingString:@"Cocos Denshion : Audio API\n"];
    text = [text stringByAppendingString:@"iCarousel : Maps Viewer\n"];
    text = [text stringByAppendingString:@"AFNetworking : Network API\n"];
    text = [text stringByAppendingString:@"GDataXMLNode : XML serializer\n"];
    text = [text stringByAppendingString:@"OpenGLWaveFront : Graphics\n"];

    text = [text stringByAppendingString:@"\n\n"];
    
    text = [text stringByAppendingString:@"Server provided by Polytechnique Montreal\n\n"];

    self.textView.text = text;
}

- (void) rollCredits
{
    [UIView animateWithDuration:90.0 delay: 0.0 options: UIViewAnimationCurveLinear
                    animations:^{
                        self.creditView.center = CGPointMake(self.creditView.center.x, -self.creditView.frame.size.height/2);
                    }
                    completion:nil
     ];
}
@end
