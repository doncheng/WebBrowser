//
//  URLConnectionDelegateProxy.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/10/31.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

typedef void(^SuccessBlock)(void);
typedef void(^FailureBlock)(void);

#import <Foundation/Foundation.h>

@interface URLConnectionDelegateProxy : NSObject <NSURLConnectionDelegate>

- (instancetype)initWithURL:(NSURL *)url success:(SuccessBlock)success failure:(FailureBlock)failure;

@end
