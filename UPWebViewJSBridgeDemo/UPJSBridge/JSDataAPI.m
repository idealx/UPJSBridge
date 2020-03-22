//
//  JSDataAPI.m
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/17.
//  Copyright © 2020 idealx. All rights reserved.
//

#import "JSDataAPI.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "UPJSBridge.h"

@implementation JSDataAPI

+ (void)handleURLSchemeRequestWithAPI:(NSString *)apiName parameter:(NSDictionary *)param webView:(id)webView {
    NSString *actualParamJS = param[@"p"];
    if (actualParamJS == nil) {
        NSLog(@"Need param p");
        return;
    }
    [UPJSBridge evaluateJavaScript:actualParamJS inWebView:webView completion:^(NSString *res, NSError *err) {
        NSDictionary *paramDict = [NSJSONSerialization JSONObjectWithData:[res dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&err];
        NSDictionary *resDict = [self handleAPIRequest:apiName parameter:paramDict];
        NSData *resData = [NSJSONSerialization dataWithJSONObject:resDict
                                                          options:0
                                                            error:NULL];
        NSString *callbackJS = [NSString stringWithFormat:@"%@('%@')", param[@"cb"],
                                [[NSString alloc] initWithData:resData encoding:NSUTF8StringEncoding]];
        [UPJSBridge evaluateJavaScript:callbackJS
                             inWebView:webView
                            completion:^(NSString *res, NSError *err) {}];
    }];
}

+ (NSData *)handleAJAXRequestWithAPI:(NSString *)apiName parameter:(NSDictionary *)param {
    NSDictionary *resDict = [self handleAPIRequest:apiName parameter:param];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resDict
                                                       options:0
                                                         error:NULL];
    return jsonData;
}

+ (NSDictionary *)handleAPIRequest:(NSString *)apiName parameter:(NSDictionary *)param {
    NSLog(@"%@", [NSString stringWithFormat:@"Call API: %@\n params: %@", apiName, param]);
    SEL apiSel = NSSelectorFromString([NSString stringWithFormat:@"api_%@:", apiName]);
    if ([self respondsToSelector:apiSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:apiSel withObject:param];
#pragma clang diagnostic pop
    } else {
        return @{@"code": @-1,
                 @"error": [NSString stringWithFormat:@"%@: Unsupport API call.", apiName]};
    }
}

#pragma mark - API implementation

+ (NSDictionary *)api_version:(NSDictionary *)param {
    return @{@"code": @0, @"version": @"0.1"};
}

@end
