//
//  UPJSBridge.h
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/13.
//  Copyright © 2020 idealx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UPJSBridge : NSURLProtocol

+ (void)start;
+ (void)stop;
+ (void)bridgeWidthWebView:(id)webView;
+ (void)evaluateJavaScript:(NSString *)jsSource
                 inWebView:(id)webView
                completion:(void (^)(id, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
