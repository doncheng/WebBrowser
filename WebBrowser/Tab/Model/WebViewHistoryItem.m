//
//  WebViewHistoryItem.m
//  WebBrowser
//
//  Created by kkyun.com on 2017/3/15.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "WebViewHistoryItem.h"

@interface WebViewHistoryItem ()

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *title;

@end

@implementation WebViewHistoryItem

- (instancetype)initWithURLString:(NSString *)URLString title:(NSString *)title{
    if (self = [super init]) {
        _URLString = URLString;
        _title = title;
    }
    return self;
}

@end
