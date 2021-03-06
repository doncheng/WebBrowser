//
//  NSFileManager+ZWUtility.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/1/10.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ZWUtility)

- (long long)getAllocatedSizeOfCacheDirectoryAtURL:(NSURL *)directoryURL error:(NSError **)error;

- (long long)getAllocatedSizeOfCacheDirectoryAtURLS:(NSArray<NSURL *> *)directoryURLs error:(NSError **)error;

- (long long)getAllocatedSizeOfDirectoryAtURL:(NSURL *)directoryURL error:(NSError **)error;

- (long long)getAllocatedSizeOfDirectoryAtURLS:(NSArray<NSURL *> *)directoryURLs error:(NSError **)error;

@end
