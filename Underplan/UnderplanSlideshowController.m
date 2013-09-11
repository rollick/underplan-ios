//
//  UnderplanSlideshowControllerViewController.m
//  Underplan
//
//  Created by Mark Gallop on 10/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanSlideshowController.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>

@implementation UnderplanSlideshowController

@synthesize photoImage, canvas, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDelegate:(id)aDelegate
{
    return [self initWithDelegate:aDelegate index:@0];
}

- (id)initWithDelegate:(id)aDelegate index:(NSNumber *)aIndex
{
    if (self = [super init])
    {
        _photoIndex = aIndex;
        delegate = aDelegate;
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.tabBarController.tabBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    } else
    {
        [self.tabBarController.tabBar setTintColor:[UIColor underplanDarkMenuColor]];
    }

    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor underplanDarkMenuColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkMenuFontColor]];
    } else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanDarkMenuColor]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.tabBarController.tabBar respondsToSelector:@selector(barTintColor)])
    {
        [self.tabBarController.tabBar setBarTintColor:[UIColor underplanPrimaryColor]];
        [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    } else
    {
        [self.tabBarController.tabBar setTintColor:[UIColor underplanPrimaryColor]];
    }
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(barTintColor)])
    {
        [self.navigationController.navigationBar setBarTintColor:[UIColor underplanPrimaryColor]];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    } else
    {
        [self.navigationController.navigationBar setTintColor:[UIColor underplanPrimaryColor]];
    }
}

-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = photoImage.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    
    [photoImage setTransform:newTransform];
    
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
    [self showOverlayWithFrame:photoImage.frame];
}

-(void)rotate:(id)sender {
    
    if([(UIRotationGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        
        _lastRotation = 0.0;
        return;
    }
    
    CGFloat rotation = 0.0 - (_lastRotation - [(UIRotationGestureRecognizer*)sender rotation]);
    
    CGAffineTransform currentTransform = photoImage.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform,rotation);
    
    [photoImage setTransform:newTransform];
    
    _lastRotation = [(UIRotationGestureRecognizer*)sender rotation];
    [self showOverlayWithFrame:photoImage.frame];
}


-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [photoImage center].x;
        _firstY = [photoImage center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [photoImage setCenter:translatedPoint];
    [self showOverlayWithFrame:photoImage.frame];
}

-(void)tapped:(id)sender {
    _marque.hidden = YES;
}

-(void)doubleTapped:(id)sender
{
    [self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
    
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1.0, 1.0);
    
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    canvas = [[UIView alloc] initWithFrame:self.view.bounds];
    photoImage = [[UIImageView alloc] initWithFrame:canvas.bounds];
    
    [self loadImageAtIndex:_photoIndex];
    
    if (!_marque) {
        _marque = [CAShapeLayer layer];
        _marque.fillColor = [[UIColor clearColor] CGColor];
        _marque.strokeColor = [[UIColor grayColor] CGColor];
        _marque.lineWidth = 1.0f;
        _marque.lineJoin = kCALineJoinRound;
        _marque.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:5], nil];
        _marque.bounds = CGRectMake(photoImage.frame.origin.x, photoImage.frame.origin.y, 0, 0);
        _marque.position = CGPointMake(photoImage.frame.origin.x + canvas.frame.origin.x, photoImage.frame.origin.y + canvas.frame.origin.y);
    }
    
    [[self.view layer] addSublayer:_marque];
    
    photoImage.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    photoImage.opaque = YES;
//    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    photoImage.contentMode = UIViewContentModeScaleAspectFill;
    photoImage.clipsToBounds = NO;
    [photoImage.layer setBorderColor:[UIColor redColor].CGColor];
    
    canvas.userInteractionEnabled = YES;
    canvas.multipleTouchEnabled = YES;
    [canvas.layer setBorderColor:[UIColor blueColor].CGColor];
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
//    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
//    [rotationRecognizer setDelegate:self];
//    [self.view addGestureRecognizer:rotationRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [canvas addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapProfileImageRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapProfileImageRecognizer setNumberOfTapsRequired:1];
    [tapProfileImageRecognizer setDelegate:self];
    [canvas addGestureRecognizer:tapProfileImageRecognizer];
    
    UIImageView *previous = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 60, 60)];
    previous.layer.backgroundColor = [UIColor clearColor].CGColor;
    previous.image = [[UIImage imageNamed:@"chevron-left.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    previous.contentMode = UIViewContentModeScaleAspectFill;
    previous.clipsToBounds = NO;

    
    // add views
    [self.view addSubview:self.canvas];
    [self.view addSubview:previous];

    [canvas addSubview:photoImage];
}

- (void)loadImageAtIndex:(NSNumber *)index
{
    if (delegate && [delegate respondsToSelector:@selector(fullImageUrlAtIndexPath:)])
    {
        NSString *imageUrl = [delegate performSelector:@selector(fullImageUrlAtIndexPath:) withObject:index];
        NSURL *url = [NSURL URLWithString:imageUrl];
        
        [photoImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

-(void)showOverlayWithFrame:(CGRect)frame {
    
    if (![_marque actionForKey:@"linePhase"]) {
        CABasicAnimation *dashAnimation;
        dashAnimation = [CABasicAnimation animationWithKeyPath:@"lineDashPhase"];
        [dashAnimation setFromValue:[NSNumber numberWithFloat:0.0f]];
        [dashAnimation setToValue:[NSNumber numberWithFloat:15.0f]];
        [dashAnimation setDuration:0.5f];
        [dashAnimation setRepeatCount:HUGE_VALF];
        [_marque addAnimation:dashAnimation forKey:@"linePhase"];
    }
    
    _marque.bounds = CGRectMake(frame.origin.x, frame.origin.y, 0, 0);
    _marque.position = CGPointMake(frame.origin.x + self.canvas.frame.origin.x, frame.origin.y + self.canvas.frame.origin.y);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, frame);
    [_marque setPath:path];
    CGPathRelease(path);
    
    _marque.hidden = NO;
    
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

@end
