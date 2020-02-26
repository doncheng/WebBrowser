//
//  BrowserBottomToolBar.h
//  WebBrowser
//
//  Created by kkyun.com on 2016/11/6.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowserWebView.h"
#import "BrowserBottomToolBarHeader.h"

@interface BrowserBottomToolBar : UIToolbar

@property (nonatomic, weak) id<BrowserBottomToolBarButtonClickedDelegate> browserButtonDelegate;

@end
