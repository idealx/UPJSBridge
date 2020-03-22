//
//  AppDelegate.m
//  UPWebViewJSBridgeDemo
//
//  Created by idealx on 2020/3/11.
//  Copyright © 2020 idealx. All rights reserved.
//

#import "AppDelegate.h"
#import "UPJSBridge.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [UPJSBridge start];
    
    return YES;
}

@end
