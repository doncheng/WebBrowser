//
//  BrowserViewController.h
//  WebBrowser
//
//  Created by kkyun.com on 16/7/30.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BrowserViewController : BaseViewController<UIScrollViewDelegate>

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(BrowserViewController)

- (void)findInPageDidUpdateCurrentResult:(NSInteger)currentResult;
- (void)findInPageDidUpdateTotalResults:(NSInteger)totalResults;
- (void)findInPageDidSelectForSelection:(NSString *)selection;

@end
