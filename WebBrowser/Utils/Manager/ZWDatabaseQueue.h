//
//  ZWDatabaseQueue.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/4/6.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "FMDatabaseQueue.h"
#import "ZWSQLiteHeader.h"
#import "ZWDatabase.h"

@interface ZWDatabaseQueue : FMDatabaseQueue

- (void)inZWDatabase:(void (^)(ZWDatabase *))block;

@end
