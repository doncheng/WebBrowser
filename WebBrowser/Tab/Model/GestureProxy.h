//
//  GestureProxy.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/9/20.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GestureProxy : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, assign) CGPoint point;

- (instancetype)initWithCGPoint:(CGPoint)point;

@end
