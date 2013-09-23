//
//  UnderplanSlideshowControllerViewController.m
//  Underplan
//
//  Created by Mark Gallop on 10/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "UnderplanSlideshowController.h"
#import "UIViewController+ShowHideBars.h"
#import "UnderplanSlideshowButton.h"
#import "UIViewController+BarColor.h"

#import "UIColor+Underplan.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

@interface UnderplanSlideshowController ()

@property (nonatomic, retain) NSTimer *buttonTimer;

@end

@implementation UnderplanSlideshowController
{
    bool buttonsVisible;
    bool zoomed;
}

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
    
    [self.photoImage setHidden:NO];
    [self showControlsTemporarily];
    
    [self setDarkBarColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [_nextBtn setHidden:YES];
    [_previousBtn setHidden:YES];
    [self.photoImage setHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    int yPosition = self.navigationController.navigationBar.layer.position.y;
    
	if (yPosition > 0) {
        return NO;
    } else {
        return YES;
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
    
    [self showControlsTemporarily];
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

    [self showControlsTemporarily];
}


-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [photoImage center].x;
        _firstY = [photoImage center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [photoImage setCenter:translatedPoint];

    [self showControlsTemporarily];
}

-(void)tapped:(id)sender {
    [self showControlsTemporarily];
}

-(void)doubleTapped:(id)sender
{
    if ([(UITapGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
//        if(zoomed) {
//            _lastScale = 0.25;
//            zoomed = NO;
//        } else {
//            _lastScale = 4.0;
//            zoomed = YES;
//        }
//        
//        CGAffineTransform currentTransform = photoImage.transform;
//        CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, _lastScale, _lastScale);
//        
//        [photoImage setTransform:newTransform];
//        CGPoint touchLocation = [(UITapGestureRecognizer*)sender locationInView:canvas];
//        
//        [UIView animateWithDuration:0.25 animations:^{
//            [self.photoImage setCenter:CGPointMake(touchLocation.x, touchLocation.y)];
//            self.canvas.transform = CGAffineTransformIdentity;
//        }];
        
        CGPoint canvasPoint = [(UITapGestureRecognizer*)sender locationInView:canvas];
        
        CGFloat photoX = [photoImage center].x;
        CGFloat photoY = [photoImage center].y;

        CGFloat canvasX = [canvas center].x;
        CGFloat canvasY = [canvas center].y;
        
        CGPoint translatedPoint = CGPointMake(photoX + canvasX - canvasPoint.x, photoY + canvasY - canvasPoint.y);
        
        [UIView animateWithDuration:0.25 animations:^{
            [photoImage setCenter:translatedPoint];
        }];
        
        [self showControlsTemporarily];
    }
}

- (void)swipe:(id)sender
{
    UISwipeGestureRecognizerDirection direction = [(UISwipeGestureRecognizer *)sender direction];
    
    if (direction == UISwipeGestureRecognizerDirectionLeft)
    {
        [self loadNextImage];
    }
    else if (direction == UISwipeGestureRecognizerDirectionRight)
    {
        [self loadPreviousImage];
    }
    else if (direction == UISwipeGestureRecognizerDirectionUp || direction == UISwipeGestureRecognizerDirectionDown)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadNextImage
{
    if ([delegate numberOfPhotos] > [_photoIndex integerValue] + 1) {
        _photoIndex = [NSNumber numberWithInt:[_photoIndex integerValue] + 1];
        [self loadImageAtIndex:_photoIndex];
        
        [self setButtonVisibility];
    }
}

// Returns whether first image loaded
- (void)loadPreviousImage
{
    if ([_photoIndex integerValue] > 0) {
        _photoIndex = [NSNumber numberWithInt:[_photoIndex integerValue] - 1];
        [self loadImageAtIndex:_photoIndex];
        
        [self setButtonVisibility];
    }
}

- (void)showControlsTemporarily
{
    [self showBarsTemporarily];

    [self slideButtonsIn];
    self.buttonTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                  target:self
                                                selector:@selector(slideButtonsOut)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)slideButtonsOut
{
    [self.buttonTimer invalidate];
    buttonsVisible = NO;
    [_previousBtn slideIn];
    [_nextBtn slideIn];
}

- (void)slideButtonsIn
{
    [self.buttonTimer invalidate];
    buttonsVisible = YES;
    [_previousBtn slideOut];
    [_nextBtn slideOut];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    canvas = [[UIView alloc] initWithFrame:self.view.bounds];
    [self slideButtonsOut];
    
    [self loadImageAtIndex:_photoIndex];
    
    // change the back button to cancel and add an event handler
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(handleBack:)];
    
    self.navigationItem.rightBarButtonItem = backButton;
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    canvas.userInteractionEnabled = YES;
    canvas.multipleTouchEnabled = YES;
    
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [pinchRecognizer setDelegate:self];
    [self.view addGestureRecognizer:pinchRecognizer];
    
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
//    [panRecognizer setMinimumNumberOfTouches:1];
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [panRecognizer setDelegate:self];
//    [canvas addGestureRecognizer:panRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [canvas addGestureRecognizer:tapRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    [doubleTapRecognizer setNumberOfTapsRequired:2];
    [doubleTapRecognizer setDelegate:self];
    [canvas addGestureRecognizer:doubleTapRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeLeftRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:swipeLeftRecognizer];

    UISwipeGestureRecognizer *swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeRightRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:swipeRightRecognizer];

    UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeUpRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:swipeUpRecognizer];

    UISwipeGestureRecognizer *swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    [swipeDownRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:swipeDownRecognizer];
    
    // Next / Previous buttons
    _previousBtn = [[UnderplanSlideshowButton alloc] initWithDelegate:self andDirection:SlideshowDirectionLeft];
    _nextBtn = [[UnderplanSlideshowButton alloc] initWithDelegate:self andDirection:SlideshowDirectionRight];
    
    [self setButtonVisibility];
    
    // add views
    [self.view addSubview:self.canvas];
    [self.view addSubview:_nextBtn];
    [self.view addSubview:_previousBtn];
}

- (void)handleBack:(id)sender
{
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController popViewControllerAnimated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.navigationController.view cache:NO];
                     }];
}

- (void)setButtonVisibility
{
    if ([_photoIndex isEqualToNumber:@0]) {
        [_nextBtn setHidden:NO];
        [_previousBtn setHidden:YES];
    }
    else if ([delegate numberOfPhotos] == [_photoIndex integerValue] + 1) {
        [_nextBtn setHidden:YES];
        [_previousBtn setHidden:NO];
    }
    else {
        [_nextBtn setHidden:NO];
        [_previousBtn setHidden:NO];
    }
}

- (void)loadImageAtIndex:(NSNumber *)index
{
    if (delegate && [delegate respondsToSelector:@selector(fullImageUrlAtIndexPath:)])
    {
        photoImage = [[UIImageView alloc] initWithFrame:canvas.bounds];
        
        NSString *imageUrl = [delegate performSelector:@selector(fullImageUrlAtIndexPath:) withObject:index];
        NSURL *url = [NSURL URLWithString:imageUrl];

        UIView *mainView = self.view;
        CGRect bounds = self.view.bounds;
        
        [MBProgressHUD showHUDAddedTo:mainView animated:YES];
        [photoImage setImageWithURL:url
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              [MBProgressHUD hideHUDForView:mainView animated:YES];
                              
                              photoImage.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
                              photoImage.opaque = YES;
                              //    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
                              photoImage.contentMode = UIViewContentModeScaleAspectFill;
                              photoImage.clipsToBounds = NO;
                              
                              // TODO:  Should create a view stack and push / pull the images rather than
                              //        re-adding them everytime.
                              [canvas.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
                              [canvas addSubview:photoImage];
                              
//                              [self showControlsTemporarily];
                          }];
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


#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return ![gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]];
}

@end
