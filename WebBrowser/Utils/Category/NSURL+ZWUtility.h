//
//  NSURL+ZWUtility.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/2/18.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (ZWUtility)

- (BOOL)isErrorPageURL;
- (NSURL *)originalURLFromErrorURL;
- (BOOL)isLocal;
- (BOOL)isHTTPProtocol;

@end
