#import "UITabBarController+ShowHideTabBar.h"

@implementation UITabBarController (ShowHideTabBar)

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