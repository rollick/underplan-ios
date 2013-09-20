//
//  WebViewController.m
//  Underplan
//
//  Created by Mark Gallop on 18/09/13.
//  Copyright (c) 2013 Mark Gallop. All rights reserved.
//

#import "WebViewController.h"

#import "UIViewController+ShowHideBars.h"

@interface WebViewController ()

@end

@implementation WebViewController

@synthesize webView = _webView, initialUrl = _initialUrl;

- (id)initWithUrl:(NSString *)url
{
    if (self = [super init])
    {
        _initialUrl = [NSURL URLWithString:url];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;

    [self.view addSubview:_webView];
    
    // Add code to load web content in UIWebView
    if (_initialUrl)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:_initialUrl];
        [_webView loadRequest:request];
    }
    
    [self showBars];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{

    if([request.URL.absoluteString compare:@"underplan.it"])
    {
        return YES;
    }
    else
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        
        return NO;
    }
}

@end
