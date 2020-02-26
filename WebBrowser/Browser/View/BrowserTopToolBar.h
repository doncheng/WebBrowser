//
//  BrowserTopToolBar.h
//  WebBrowser
//
//  Created by kkyun.com on 2016/10/12.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserWebView.h"

@interface BrowserTopToolBar : UIView <WebViewDelegate>

- (void)setTopURLOrTitle:(NSString *)urlOrTitle;

@end
