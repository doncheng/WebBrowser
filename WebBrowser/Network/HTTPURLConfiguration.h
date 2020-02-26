//
//  HTTPURLConfiguration.h
//  ZhihuDaily
//
//  Created by kkyun.com on 16/8/3.
//  Copyright © 2016年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPURLConfiguration : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(HTTPURLConfiguration)

- (NSString *)baiduURLWithPath:(NSString *)path;

@end
