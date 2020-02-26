//
//  NSCharacterSet+ZWUtility.m
//  WebBrowser
//
//  Created by kkyun.com on 2017/3/23.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "NSCharacterSet+ZWUtility.h"

@implementation NSCharacterSet (ZWUtility)

+ (NSCharacterSet *)URLAllowedCharacterSet{
    return [NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~:/?#[]@!$&'()*+,;=%"];
}

@end
