//
//  NSNumber+ZWUtility.m
//  WebBrowser
//
//  Created by kkyun.com on 2017/1/9.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "NSNumber+ZWUtility.h"

@implementation NSNumber (ZWUtility)

- (CGFloat)CGFloatValue
{
#if (CGFLOAT_IS_DOUBLE == 1)
    CGFloat result = [self doubleValue];
#else
    CGFloat result = [self floatValue];
#endif
    return result;
}

- (id)initWithCGFloat:(CGFloat)value
{
#if (CGFLOAT_IS_DOUBLE == 1)
    self = [self initWithDouble:value];
#else
    self = [self initWithFloat:value];
#endif
    return self;
}

+ (NSNumber *)numberWithCGFloat:(CGFloat)value
{
    NSNumber *result = [[self alloc] initWithCGFloat:value];
    return result;
}

@end
