//
//  JavaScriptHelper.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/2/14.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BrowserWebView;

@interface JavaScriptHelper : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(JavaScriptHelper)
+ (void)setNoImageMode:(BOOL)enabled webView:(BrowserWebView *)webView loadPrimaryScript:(BOOL)needsLoad;
+ (void)setLongPressGestureWithWebView:(BrowserWebView *)webView;
+ (void)setFindInPageWithWebView:(BrowserWebView *)webView;
+ (void)setBaiduADBlockWithWebView:(BrowserWebView *)webView;
+ (void)setEyeProtectiveWithWebView:(BrowserWebView *)webView colorValue:(NSInteger)colorValue loadPrimaryScript:(BOOL)needsLoad;

@end
