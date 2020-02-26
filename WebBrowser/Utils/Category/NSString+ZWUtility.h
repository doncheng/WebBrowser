//
//  NSString+ZWUtility.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/1/7.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ZWUtility)

- (BOOL)isValidURL;
- (BOOL)isLocal;
- (BOOL)isHTTPProtocol;
- (NSString *)ellipsizeWithMaxLength:(NSInteger)maxLength;
- (NSDictionary *)getWebViewJSONDicWithPrefix:(NSString *)prefix;

@end
