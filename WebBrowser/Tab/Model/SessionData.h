//
//  SessionData.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/3/15.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SessionData : NSObject

@property (nonatomic, readonly) NSDictionary *jsonDictionary;

- (instancetype)initWithCurrentPage:(NSInteger)currentPage urls:(NSArray <NSString *> *)urls;

@end
