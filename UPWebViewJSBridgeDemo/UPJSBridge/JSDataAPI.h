//
//  JSDataAPI.h
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/17.
//  Copyright © 2020 idealx. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSDataAPI : NSObject

+ (void)handleURLSchemeRequestWithAPI:(NSString *)apiName parameter:(NSDictionary *)param webView:(id)webView;
+ (NSData *)handleAJAXRequestWithAPI:(NSString *)apiName parameter:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
