//
//  ArrowActivityView.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/9/12.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ArrowActivityKinds) {
    ArrowActivityKindLeft,
    ArrowActivityKindRight
};

@interface ArrowActivityView : UIView

- (instancetype)initWithFrame:(CGRect)frame kind:(ArrowActivityKinds)kind;
- (void)setOn:(BOOL)on;
- (BOOL)isOn;
- (void)setKind:(ArrowActivityKinds)kind;

@end
