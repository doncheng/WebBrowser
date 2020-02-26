//
//  WebServer.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/2/16.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>

typedef GCDWebServerResponse *(^ServerBlock)(GCDWebServerRequest *);

@interface WebServer : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(WebServer)

- (BOOL)start;
- (NSString *)base;
- (void)registerHandlerForMethod:(NSString *)method module:(NSString *)module resource:(NSString *)resource handler:(ServerBlock)handler;
- (void)registerMainBundleResource:(NSString *)resource module:(NSString *)module;
- (void)registerMainBundleResourcesOfType:(NSString *)type module:(NSString *)module;

@end
