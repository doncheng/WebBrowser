//
//  ZWDatabase.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/4/6.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "FMDatabase.h"

@interface ZWDatabase : FMDatabase

- (FMResultSet *)executeZWQuery:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeZWUpdate:(NSString *)sql withArgumentsInArray:(NSArray *)arguments;
- (BOOL)executeZWUpdate:(NSString*)sql;
- (BOOL)executeZWStatements:(NSString *)sql;

@end
