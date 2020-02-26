//
//  BrowserWebView.h
//  WebBrowser
//
//  Created by kkyun.com on 2016/10/4.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class BrowserWebView, WebModel, WebViewBackForwardList, HomePageView;

typedef void (^WebCompletionBlock)(NSString *, NSError *);
typedef void(^BackForwardListCompletion)(WebViewBackForwardList *);

@protocol WebViewDelegate <NSObject>

@optional

#pragma mark - WebViewDelegate

- (BOOL)webView:(BrowserWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType;

@end

@interface BrowserWebView : WKWebView<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, assign) WebModel *webModel;
@property (nonatomic, assign, readonly) BOOL isMainFrameLoaded;
@property (nonatomic, assign, readonly) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, retain) HomePageView *homePage;

@property(nonatomic, strong) WKNavigation *navigation;
@property(nonatomic, assign) BOOL reviewsAppInAppStore;
@property(nonatomic, assign) BOOL showsBackgroundLabel;

@property(nonatomic, strong) UILabel *backgroundLabel;
@property(nonatomic, strong) UIProgressView *progressView;


- (NSString *)mainFURL;
- (NSString *)mainFTitle;
- (void)webViewBackForwardListWithCompletion:(BackForwardListCompletion)completion;

@end
