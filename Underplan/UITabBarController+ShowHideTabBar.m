#import "UITabBarController+ShowHideTabBar.h"

#import "SystemVersionInfo.h"

static float kAnimationInterval = 0.25;

@implementation UITabBarController (ShowHideTabBar)

- (void)showTabBar
{
    self.tabBar.hidden = NO;
    float fHeight;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0"))
    {
        fHeight = self.view.frame.size.height;
        if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            fHeight = self.view.frame.size.width;
        }
        
        float barHeight = self.tabBar.frame.size.height;
        fHeight -= barHeight;
    }
    else
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        fHeight = screenRect.size.height;
        if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
        {
            fHeight = screenRect.size.width;
        }
        
        fHeight -= self.tabBar.frame.size.height;
    }
    
    [UIView animateWithDuration:kAnimationInterval animations:^{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            }
        }
    } completion:^(BOOL finished) {
        //do smth after animation finishes
    }];
}

- (void)hideTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height;
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        fHeight = screenRect.size.width;
    }
    
    [UIView animateWithDuration:kAnimationInterval animations:^{
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            }
        }
    } completion:^(BOOL finished) {
        //do smth after animation finishes
        self.tabBar.hidden = YES;
    }];
}

- (void) setHidden:(BOOL)hidden
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height;
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
    {
        fHeight = screenRect.size.width;
    }
    
    if(!hidden) fHeight -= self.tabBar.frame.size.height;
    
    [UIView animateWithDuration:0.25 animations:^{
        for(UIView *view in self.view.subviews){
            if([view isKindOfClass:[UITabBar class]]){
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }else{
                if(hidden) [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            }
        }
    }
    completion:^(BOOL finished)
    {
        if(!hidden){
            [UIView animateWithDuration:0.25 animations:^{
                for(UIView *view in self.view.subviews)
                {
                    if(![view isKindOfClass:[UITabBar class]])
                        [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                }
            }];
        }
    }];
}

@end