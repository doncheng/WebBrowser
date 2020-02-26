//
//  HttpHelper.h
//  WebBrowser
//
//  Created by kkyun.com on 2016/11/10.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpHelper : NSObject

+ (BOOL)canAppHandleURL:(NSURL *)url;

+ (BOOL)isURL:(NSString *)content;

@end
