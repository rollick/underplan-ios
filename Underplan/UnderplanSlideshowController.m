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
#import <MBProgressHUD.h>

@interface UnderplanSlideshowController ()

@property (nonatomic, retain) NSTimer *timer;

@end

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
    
    [self.photoImage setHidden:NO];
    [self showNavBarTemporarily];
    
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
    
    [self.timer invalidate];
    [self.photoImage setHidden:YES];
    
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
    
    [self showNavBarTemporarily];
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

    [self showNavBarTemporarily];
}


-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [photoImage center].x;
        _firstY = [photoImage center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [photoImage setCenter:translatedPoint];

    [self showNavBarTemporarily];
}

-(void)tapped:(id)sender {
    [self.navigationController.navigationBar setHidden:NO];
}

-(void)doubleTapped:(id)sender
{
    [self.view bringSubviewToFront:[(UIPinchGestureRecognizer*)sender view]];
    
	CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, 1.0, 1.0);
    
	[[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
}

- (void)showNavBarTemporarily
{
    [self.timer invalidate];
    [self showNavBar];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                  target:self
                                                selector:@selector(hideNavBar)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)showNavBar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)hideNavBar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    canvas = [[UIView alloc] initWithFrame:self.view.bounds];
    photoImage = [[UIImageView alloc] initWithFrame:canvas.bounds];
    
    [self loadImageAtIndex:_photoIndex];
    
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
    
    
    // Next / Previous buttons
    UIImageView *previousBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, 60, 60)];
    previousBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
    previousBtn.image = [[UIImage imageNamed:@"leftLarge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    previousBtn.contentMode = UIViewContentModeScaleToFill;
    previousBtn.clipsToBounds = NO;
    
    UIImageView *nextBtn = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 60.0f, 200, 60, 60)];
    nextBtn.layer.backgroundColor = [UIColor clearColor].CGColor;
    nextBtn.image = [[UIImage imageNamed:@"rightLarge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    nextBtn.contentMode = UIViewContentModeScaleAspectFit;
    nextBtn.clipsToBounds = NO;
    
    // add views
    [self.view addSubview:self.canvas];
    [self.view addSubview:previousBtn];
    [self.view addSubview:nextBtn];

    [canvas addSubview:photoImage];
}

- (void)loadImageAtIndex:(NSNumber *)index
{
    if (delegate && [delegate respondsToSelector:@selector(fullImageUrlAtIndexPath:)])
    {
        NSString *imageUrl = [delegate performSelector:@selector(fullImageUrlAtIndexPath:) withObject:index];
        NSURL *url = [NSURL URLWithString:imageUrl];

        UIView *mainView = self.view;
        [MBProgressHUD showHUDAddedTo:mainView animated:YES];
        [photoImage setImageWithURL:url
                   placeholderImage:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                              [MBProgressHUD hideHUDForView:mainView animated:YES];
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
