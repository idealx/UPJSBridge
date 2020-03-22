//
//  UIWebViewController.m
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/12.
//  Copyright © 2020 idealx. All rights reserved.
//

#import "UIWebViewController.h"
#import "UPJSBridge.h"

@interface UIWebViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation UIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UPJSBridge bridgeWidthWebView:_webView];
    NSURLRequest *req = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://localhost:8000/demo.html"]];
    [self.webView loadRequest:req];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UPJSBridge start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UPJSBridge stop];
}
@end
