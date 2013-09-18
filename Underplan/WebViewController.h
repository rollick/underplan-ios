//
//  WebViewController.h
//  Underplan
//
//  Created by Mark Gallop on 18/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property(nonatomic, retain) UIWebView *webView;
@property(nonatomic, retain) NSURL *initialUrl;

- (id)initWithUrl:(NSString *)url;

@end
