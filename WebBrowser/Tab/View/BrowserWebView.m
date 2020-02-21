//
//  BrowserWebView.m
//  WebBrowser
//
//  Created by 钟武 on 2016/10/4.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import "BrowserWebView.h"
#import "WebViewHeader.h"
#import "HttpHelper.h"
#import "TabManager.h"
#import "DelegateManager+WebViewDelegate.h"
#import "MenuHelper.h"
#import "WebViewBackForwardList.h"

#import <objc/runtime.h>
#import <objc/message.h>

#import <StoreKit/StoreKit.h>
#import "UIProgressView+WebKit.h"

#ifndef kLY404NotFoundHTMLPath
#define kLY404NotFoundHTMLPath [[NSBundle mainBundle] pathForResource:@"html.bundle/404" ofType:@"html"]
#endif

#ifndef kLYNetworkErrorHTMLPath
#define kLYNetworkErrorHTMLPath [[NSBundle mainBundle] pathForResource:@"html.bundle/neterror" ofType:@"html"]
#endif
/// URL key for 404 not found page.
static NSString *const kLY404NotFoundURLKey = @"html.bundle/404.html";
/// URL key for network error page.
static NSString *const kLYNetworkErrorURLKey = @"html.bundle/neterror.html";
/// Tag value for container view.
static NSUInteger const kContainerViewTag = 0x893147;

@interface BrowserWebView () <MenuHelperInterface>
{
    BOOL _loading;
    WKWebViewConfiguration *_configuration;
}
@property (nonatomic, assign, readwrite) BOOL isMainFrameLoaded;
@property (nonatomic, assign) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property(nonatomic, assign) NSTimeInterval timeoutInternal;
@property(nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
@property(nonatomic, assign) NSUInteger maxAllowedTitleLength;
@end

@implementation BrowserWebView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initializeWebView];
    }
    
    return self;
}

- (void)initializeWebView{
    //don't set backgroundColor to clearColor, prevents black screens from appearing on screenshots
    self.backgroundColor = [UIColor whiteColor];
    
    self.opaque = NO;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    //self.allowsInlineMediaPlayback = YES;
    //self.mediaPlaybackRequiresUserAction = NO;
    //self.scalesPageToFit = YES;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self setDrawInWebThread];
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.hidesWhenStopped = YES;
    
    [self addSubview:activityView];
    
    self.indicatorView = activityView;
    [activityView release];
    
    
    UILongPressGestureRecognizer *longPressGesture = [UILongPressGestureRecognizer new];
    self.longPressGestureRecognizer = longPressGesture;
    longPressGesture.delegate = [TabManager sharedInstance].browserContainerView;
    [self addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"scrollView.contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)setBounds:(CGRect)bounds{
    if (!CGSizeEqualToSize(self.bounds.size, bounds.size)) {
        self.indicatorView.center = CGPointMake(self.bounds.origin.x + bounds.size.width / 2, self.bounds.origin.y + bounds.size.height / 2);
    }
    [super setBounds:bounds];
}

- (void)setDrawInWebThread{
    if([self respondsToSelector:NSSelectorFromString(DRAW_IN_WEB_THREAD)])
        (DRAW_IN_WEB_THREAD__PROTO objc_msgSend)(self,NSSelectorFromString(DRAW_IN_WEB_THREAD),YES);
    if([self respondsToSelector:NSSelectorFromString(DRAW_CHECKERED_PATTERN)])
        (DRAW_CHECKERED_PATTERN__PROTO objc_msgSend)(self, NSSelectorFromString(DRAW_CHECKERED_PATTERN),YES);
}

- (NSString *)mainFURL{
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    WKWebView *webView = [self webView];
    return [[webView URL] absoluteString];
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_URL)])
            return [[(MAIN_FRAME_URL__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_URL)) retain] autorelease];
        else
            return nil;
    }
    else
        return nil;
}

- (NSString *)mainFTitle
{
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    WKWebView *webView = [self webView];
    return [webView title];
    if(webView)
    {
        if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME_TITLE)])
            return [[(MAIN_FRAME_TITLE__PROTO objc_msgSend)(webView, NSSelectorFromString(MAIN_FRAME_TITLE)) retain] autorelease];
        else
            return nil;
    }
    else
        return nil;
}

- (void)webViewBackForwardListWithCompletion:(BackForwardListCompletion)completion{
    NSAssert([NSThread isMainThread], @"method should called in main thread");
    
    WKWebView *webView = [self webView];
    
    WebViewBackForwardList *list = nil;
    
    if (webView && [webView respondsToSelector:NSSelectorFromString(BACK_FORWARD_LIST)]) {
        WKBackForwardList *backForwardList = nil;
        
        backForwardList = webView.backForwardList;
        if (backForwardList) {
            list = [[[WebViewBackForwardList alloc] initWithCurrentItem:[self getCurrentItem:backForwardList.currentItem] backList:[self getBackForwardItemsWithArray:backForwardList.backList] forwardList:[self getBackForwardItemsWithArray:backForwardList.forwardList]] autorelease];
        }
    }
    
    if (completion) {
        completion(list);
    }
}

- (WebViewHistoryItem *)getCurrentItem:(WKBackForwardListItem *)item{
    if (item ) {
        WebViewHistoryItem *hisItem = [[[WebViewHistoryItem alloc] initWithURLString:[item.URL absoluteString] title:item.title] autorelease];
        return hisItem;
    }
    return nil;
}

- (NSArray<WebViewHistoryItem *> *)getBackForwardItemsWithArray:(NSArray *)items{
    if (items && items.count > 0) {
        NSMutableArray<WebViewHistoryItem *> *historyItems = [NSMutableArray arrayWithCapacity:items.count];
        [items enumerateObjectsUsingBlock:^(id item, NSUInteger idx, BOOL *stop){
            if ([item respondsToSelector:NSSelectorFromString(URL_TITLE)] && [item respondsToSelector:NSSelectorFromString(URL_STRING)]) {
                @autoreleasepool {
                    id urlString = [[(URL_STRING__PROTO objc_msgSend)(item, NSSelectorFromString(URL_STRING)) retain] autorelease];
                    id title = [[(URL_TITLE__PROTO objc_msgSend)(item, NSSelectorFromString(URL_TITLE)) retain] autorelease];
                    WebViewHistoryItem *hisItem = [[WebViewHistoryItem alloc] initWithURLString:urlString title:title];
                    [historyItems addObject:hisItem];
                    [hisItem release];
                }
            }
        }];
        return historyItems;
    }
    return nil;
}

// get mainFrame
- (id)mainFrameWithWebView:(id)webView{
    if([webView respondsToSelector:NSSelectorFromString(MAIN_FRAME)])
    {
        id mainFrame = [[(MAIN_FRAME__PROTO objc_msgSend)(webView,NSSelectorFromString(MAIN_FRAME)) retain] autorelease];
        return mainFrame;
        
    }
    return nil;
}

// get WebView
- (id)webView{
    id webDocumentView = nil;
    id webView = nil;
    id selfid = self;
    return selfid;
    if([selfid respondsToSelector:NSSelectorFromString(DOCUMENT_VIEW)]){
        webDocumentView = [[(DOCUMENT_VIEW__PROTO objc_msgSend)(selfid,NSSelectorFromString(DOCUMENT_VIEW)) retain] autorelease];
    }
    else{
        return nil;
    }
    
    if(webDocumentView)
    {
        //也可以使用valueForKey来获取,object_getInstanceVariable方法只能在MRC下执行
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else{
        return nil;
    }
    
    if(webDocumentView)
    {
        object_getInstanceVariable(webDocumentView,[GOT_WEB_VIEW cStringUsingEncoding:NSUTF8StringEncoding], (void**)&webView);
        [[webView retain] autorelease];
    }
    else{
        return nil;
    }
    
    return webView;
}
- (UILabel *)backgroundLabel
{
    if (_backgroundLabel) return _backgroundLabel;
    _backgroundLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _backgroundLabel.textColor = [UIColor colorWithRed:0.180 green:0.192 blue:0.196 alpha:1.00];
    _backgroundLabel.font = [UIFont systemFontOfSize:12];
    _backgroundLabel.numberOfLines = 0;
    _backgroundLabel.textAlignment = NSTextAlignmentCenter;
    _backgroundLabel.backgroundColor = [UIColor clearColor];
    _backgroundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_backgroundLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    //_backgroundLabel.hidden = !self.showsBackgroundLabel;
    return _backgroundLabel;
}

- (UIProgressView *)progressView
{
    if (_progressView) return _progressView;
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    _progressView.trackTintColor = [UIColor clearColor];
    _progressView.ly_hiddenWhenProgressApproachFullSize = YES;
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    __weak typeof(self) wself = self;
//    _progressView.delegate = wself;
    return _progressView;
}
#pragma mark - Public
- (void)loadURL:(NSURL *)pageURL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:pageURL];
    request.timeoutInterval = _timeoutInternal;
    request.cachePolicy = _cachePolicy;
    NSString *cookie = [self readCurrentCookie];
    if (cookie && cookie.length != 0) {
        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
    _navigation = [self loadRequest:request];
}
- (void)didStartLoad
{
    self.backgroundLabel.text = @"Loading";
//    self.navigationItem.title = LYWebViewControllerLocalizedString(@"loading", @"Loading");
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    if (self.navigationType == LYWebViewControllerNavigationBarItem) {
//        [self updateNavigationItems];
//    }
//    if (self.navigationType == LYWebViewControllerNavigationToolItem) {
//        [self updateToolbarItems];
//    }
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didStartLoad)]) {
//        [self.delegate didStartLoad];
//    }

    _loading = YES;
}

- (void)didFinishLoad{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
//    if (self.navigationType == LYWebViewControllerNavigationBarItem) {
//        [self updateNavigationItems];
//    }
//    if (self.navigationType == LYWebViewControllerNavigationToolItem) {
//        [self updateToolbarItems];
//    }
    
    [self _updateTitleOfWebVC];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *bundle = ([infoDictionary objectForKey:@"CFBundleDisplayName"]?:[infoDictionary objectForKey:@"CFBundleName"])?:[infoDictionary objectForKey:@"CFBundleIdentifier"];
    NSString *host = self.URL.host;
    self.backgroundLabel.text = host;
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoad)]) {
//        [self.delegate didFinishLoad];
//    }
    _loading = NO;
}

- (void)didFailLoadWithError:(NSError *)error{
    if (error.code == NSURLErrorCannotFindHost) {// 404
        NSURL *URL = [NSURL fileURLWithPath:kLY404NotFoundHTMLPath];
        [self loadURL:URL];
    } else {
        NSURL *URL = [NSURL fileURLWithPath:kLYNetworkErrorHTMLPath];
        [self loadURL:URL];
    }

    self.backgroundLabel.text = [NSString stringWithFormat:@"%@%@",@"加载失败" , error.localizedDescription];
//    self.navigationItem.title = LYWebViewControllerLocalizedString(@"load failed", nil);
//    if (self.navigationType == LYWebViewControllerNavigationBarItem) {
//        [self updateNavigationItems];
//    }
//    if (self.navigationType == LYWebViewControllerNavigationToolItem) {
//        [self updateToolbarItems];
//    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didFailLoadWithError:)]) {
//        [self.delegate didFailLoadWithError:error];
//    }
//    [self.progressView setProgress:0.9 animated:YES];
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKFrameInfo *frameInfo = navigationAction.targetFrame;
    if (![frameInfo isMainFrame]) {
        if (navigationAction.request) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)webViewDidClose:(WKWebView *)webView {
    
}
#endif
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    // Get host name of url.
    NSString *host = webView.URL.host;
    // Init the alert view controller.
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host message:message preferredStyle: UIAlertControllerStyleAlert];
    // Init the cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completionHandler != NULL) {
            completionHandler();
        }
    }];
    // Init the ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler();
        }
    }];
    
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    //[self presentViewController:alert animated:YES completion:NULL];
}
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    // Get the host name.
    NSString *host = webView.URL.host;
    // Initialize alert view controller.
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host message:message preferredStyle:UIAlertControllerStyleAlert];
    // Initialize cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler(NO);
        }
    }];
    // Initialize ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        if (completionHandler != NULL) {
            completionHandler(YES);
        }
    }];
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    //[self presentViewController:alert animated:YES completion:NULL];
}
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSString *host = webView.URL.host;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:prompt message:host preferredStyle:UIAlertControllerStyleAlert];
    // Add text field.
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText?:@"输入";
        textField.font = [UIFont systemFontOfSize:12];
    }];
    // Initialize cancel action.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        // Get inputed string.
        NSString *string = [alert.textFields firstObject].text;
        if (completionHandler != NULL) {
            completionHandler(string?:defaultText);
        }
    }];
    // Initialize ok action.
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
        // Get inputed string.
        NSString *string = [alert.textFields firstObject].text;
        if (completionHandler != NULL) {
            completionHandler(string?:defaultText);
        }
    }];
    // Add actions.
    [alert addAction:cancelAction];
    [alert addAction:okAction];
}
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // URL actions for 404 and Errors:
    if ([navigationAction.request.URL.absoluteString rangeOfString:kLY404NotFoundURLKey].location != NSNotFound || [navigationAction.request.URL.absoluteString rangeOfString:kLYNetworkErrorURLKey].location != NSNotFound) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    // Disable all the '_blank' target in page's target.
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:navigationAction.request.URL.absoluteString];
    // For appstore and system defines. This action will jump to AppStore app or the system apps.
    if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/' OR SELF BEGINSWITH[cd] 'mailto:' OR SELF BEGINSWITH[cd] 'tel:' OR SELF BEGINSWITH[cd] 'telprompt:'"] evaluateWithObject:components.URL.absoluteString]) {
        if ([[NSPredicate predicateWithFormat:@"SELF BEGINSWITH[cd] 'https://itunes.apple.com/'"] evaluateWithObject:components.URL.absoluteString] && !self.reviewsAppInAppStore) {
            SKStoreProductViewController *productVC = [[SKStoreProductViewController alloc] init];
            productVC.delegate = self;
            NSError *error;
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"id[1-9]\\d*" options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *result = [regex firstMatchInString:components.URL.absoluteString options:NSMatchingReportCompletion range:NSMakeRange(0, components.URL.absoluteString.length)];
            
            if (!error && result) {
                NSRange range = NSMakeRange(result.range.location+2, result.range.length-2);
                [productVC loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier: @([[components.URL.absoluteString substringWithRange:range] integerValue])} completionBlock:^(BOOL result, NSError * _Nullable error) {
                }];
                //[self presentViewController:productVC animated:YES completion:NULL];
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    } else if (![[NSPredicate predicateWithFormat:@"SELF MATCHES[cd] 'https' OR SELF MATCHES[cd] 'http' OR SELF MATCHES[cd] 'file' OR SELF MATCHES[cd] 'about'"] evaluateWithObject:components.scheme]) {// For any other schema but not `https`、`http` and `file`.
        if ([[UIApplication sharedApplication] canOpenURL:components.URL]) {
            [UIApplication.sharedApplication openURL:components.URL options:@{} completionHandler:NULL];
        }
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    // Update the items.
//    if (self.navigationType == LYWebViewControllerNavigationBarItem) {
//        [self updateNavigationItems];
//    }
//    if (self.navigationType == LYWebViewControllerNavigationToolItem) {
//        [self updateToolbarItems];
//    }
    BOOL isShouldStart = YES;

    NSArray<WeakWebBrowserDelegate *> *delegates = [[DelegateManager sharedInstance] webViewDelegates];

    foreach(delegate, delegates) {
        if ([delegate.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            isShouldStart = [delegate.delegate webView:self shouldStartLoadWithRequest:navigationAction.request navigationType:navigationAction.navigationType];
            if (!isShouldStart) {
                //return isShouldStart;
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
//    if ([components.URL.absoluteString isEqualToString:DEFAULT_CARD_CELL_URL]) {
//        [self webViewForMainFrameDidFinishLoad:self];
//        decisionHandler(WKNavigationActionPolicyCancel);
//        return;
//    }
    // Call the decision handler to allow to load web page.
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    if (![response.URL.absoluteString isEqualToString:DEFAULT_CARD_CELL_URL]) {
        NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

    [self didStartLoad];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) {
        [webView reloadFromOrigin];
        return;
    }
    [self didFailLoadWithError:error];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    [[DelegateManager sharedInstance] performSelector:@selector(webViewForMainFrameDidCommitLoad:) arguments:@[self] key:kDelegateManagerWebView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [self didFinishLoad];
    [[DelegateManager sharedInstance] performSelector:@selector(webViewForMainFrameDidFinishLoad:) arguments:@[self] key:kDelegateManagerWebView];
}
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
//    if (error.code == NSURLErrorCancelled) {
//        [webView reloadFromOrigin];
//        return;
//    }
    [self didFailLoadWithError:error];
}

//WKWebView 上当总体的内存占用比较大的时候，WebContent Process 会 crash，出现白屏现象
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    NSString *host = webView.URL.host;
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:host message:@"网页进程终止" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:NULL];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:NULL];
    }];
    [alert addAction:cancelAction];
    [alert addAction:okAction];
}
#endif
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
//        if (self.navigationController && self.progressView.superview != self.navigationController.navigationBar) {
//            [self updateFrameOfProgressView];
//            [self.navigationController.navigationBar addSubview:self.progressView];
//        }
        [self.progressView setProgress:self.estimatedProgress animated:YES];
    } else if ([keyPath isEqualToString:@"scrollView.contentOffset"]) {
        CGPoint contentOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
        self.backgroundLabel.transform = CGAffineTransformMakeTranslation(0, -contentOffset.y-self.scrollView.contentInset.top);
    } else if ([keyPath isEqualToString:@"title"]) {
        [self _updateTitleOfWebVC];
//        if (self.navigationType == LYWebViewControllerNavigationBarItem) {
//            [self updateNavigationItems];
//        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - replaced method calling

- (void)webView:(BrowserWebView *)webView gotTitleName:(NSString*)titleName{
    self.webModel.title = titleName;
    [[DelegateManager sharedInstance] performSelector:@selector(webView:gotTitleName:) arguments:@[webView,titleName] key:kDelegateManagerWebView];
    if ([[webView.URL absoluteString] isEqualToString:DEFAULT_CARD_CELL_URL]) {
        [[DelegateManager sharedInstance] performSelector:@selector(webView:hideTopToolBar:) arguments:@[webView,@1] key:kDelegateManagerWebView];
    }else{
        [[DelegateManager sharedInstance] performSelector:@selector(webView:hideTopToolBar:) arguments:@[webView,@0] key:kDelegateManagerWebView];
    }
    
}


#pragma mark - Menu Action

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    if (action == @selector(copy:)) {
        return YES;
    }
    if (action == @selector(selectAll:)) {
        return YES;
    }
    return NO;
}

#pragma mark - Dealloc

- (void)dealloc{
    [_indicatorView removeFromSuperview];
    _indicatorView = nil;
    _longPressGestureRecognizer = nil;
    _webModel = nil;
	[_homePage release];
    _homePage = nil;
    self.UIDelegate = nil;
    self.navigationDelegate = nil;
    self.scrollView.delegate = nil;
    [self stopLoading];
    [self loadHTMLString:@"" baseURL:nil];
    
    DDLogDebug(@"BrowserWebView dealloc");

    [super dealloc];
}

#pragma mark - Initialize

+ (void)initialize{
    Class browserClass = [BrowserWebView class];
    if (self == browserClass) {
        @autoreleasepool {

        }
    }
}

#pragma mark - Helper
-(NSString *)readCurrentCookie{
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"%@=%@;", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    return cookieValue;
}
- (void)_updateTitleOfWebVC
{
    self.webModel.title = [self title];
    if(![self.webModel.title isKindOfClass:[NSString class]])
        return;
    [self webView:self gotTitleName:self.webModel.title];
    
}
@end



