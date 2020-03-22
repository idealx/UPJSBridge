//
//  UPJSBridge.m
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/13.
//  Copyright © 2020 idealx. All rights reserved.
//

#import "UPJSBridge.h"
#import "JSDataAPI.h"

static NSString *kUPBridgeURLScheme = @"upbridgescheme";
static NSString *kAJAXCallNativeHost = @"ajax.call.native";

@implementation UPJSBridge

+ (void)addURLProtocol4WKWebview {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Hack NSURLProtocol for WKWebView
        Class cls = [[[WKWebView new] valueForKey:@"browsingContextController"] class];
        SEL sel = NSSelectorFromString(@"registerSchemeForCustomProtocol:");
        if ([(id)cls respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [(id)cls performSelector:sel withObject:kUPBridgeURLScheme];
            [(id)cls performSelector:sel withObject:@"http"];
#pragma clang diagnostic pop
        }
    });
}

+ (void)start {
    [UPJSBridge addURLProtocol4WKWebview];
    [NSURLProtocol registerClass:[self class]];
}

+ (void)stop {
    [NSURLProtocol unregisterClass:[self class]];
}

+ (void)evaluateJavaScript:(NSString *)jsSource
                 inWebView:(id)webView
                completion:(void (^)(id, NSError *error))completion {
    // evaluate JavaScript code should run in main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([webView isKindOfClass:[UIWebView class]]) {
            NSString *res = [webView stringByEvaluatingJavaScriptFromString:jsSource];
            completion(res, nil);
        } else if ([webView isKindOfClass:[WKWebView class]]) {
            [webView evaluateJavaScript:jsSource completionHandler:completion];
        } else {
            NSLog(@"Unsupport web view class.");
        }
    });
}

+ (void)bridgeWidthWebView:(id)webView {
    NSString *webViewAddr = [NSString stringWithFormat:@"%p", webView];
    NSString *jsSource = [NSString stringWithFormat:@"window.bridgeWebView = '%@';", webViewAddr];
    [self evaluateJavaScript:jsSource inWebView:webView completion:^(id res, NSError *err) {}];
}

#pragma mark - NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.scheme isEqualToString:kUPBridgeURLScheme] ||
        [request.URL.host isEqualToString:kAJAXCallNativeHost];
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURL *reqUrl = self.request.URL;
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:reqUrl
                                                resolvingAgainstBaseURL:NO];
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    for (NSURLQueryItem *item in urlComponents.queryItems) {
        [parameter setValue:item.value forKey:item.name];
    }
    
    if ([reqUrl.scheme isEqualToString:kUPBridgeURLScheme]) {     // URL scheme
        uintptr_t hex = strtoull([parameter[@"wv"] UTF8String], NULL, 0);
        id callbackWebView = (__bridge id)(void *)hex;
        if (callbackWebView) {
            if ([reqUrl.path length] == 0) {    // API
                NSString *apiName = reqUrl.host;
                [JSDataAPI handleURLSchemeRequestWithAPI:apiName
                                                 parameter:parameter
                                                   webView:callbackWebView];
            } else {
                // If you have your own router, add it here to handle url.
                [[UIApplication sharedApplication] openURL:reqUrl
                                                   options:@{@"from": @"UPJSBridge"}
                                         completionHandler:nil];
            }
        } else {
            NSLog(@"Callback web view no set.");
        }
    } else {    // AJAX request
        NSString *apiName = [reqUrl.path stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSData *data = [JSDataAPI handleAJAXRequestWithAPI:apiName parameter:parameter];
        
        // Need cross domain header avoid ajax error
        NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*",
                                  @"Access-Control-Allow-Headers" : @"Content-Type",
                                  @"Content-Type": @"application/json"
        };
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:reqUrl
                                                                  statusCode:200
                                                                 HTTPVersion:@"1.1"
                                                                headerFields:headers];
        
        [self.client URLProtocol:self didReceiveResponse:response
              cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [self.client URLProtocol:self didLoadData:data];
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading {}

@end
