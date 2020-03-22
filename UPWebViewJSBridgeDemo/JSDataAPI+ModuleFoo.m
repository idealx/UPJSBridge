//
//  JSDataAPI+ModuleFoo.m
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/19.
//  Copyright © 2020 idealx. All rights reserved.
//

#import "JSDataAPI+ModuleFoo.h"


@implementation JSDataAPI (ModuleFoo)

+ (NSDictionary *)api_fooDemo:(NSDictionary *)param {
    return @{@"code": @0, @"data": @"Data from module foo."};
}

@end
