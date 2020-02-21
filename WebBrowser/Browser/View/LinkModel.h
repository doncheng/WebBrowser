//
//  LinkModel.h
//  WebBrowser
//
//  Created by yaowan on 2020/2/16.
//  Copyright © 2020 钟武. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LinkModel : NSObject

@property (nonatomic, copy) NSString        *linkId;
@property (nonatomic, copy) NSString        *title;
@property (nonatomic, copy) NSString        *url;
@property (nonatomic, copy) NSString        *iconUrl;
@property (nonatomic, copy) NSString        *color;
@property (nonatomic, copy) NSString        *placeholder;
@property (nonatomic, assign) BOOL          isSystem;

@end

NS_ASSUME_NONNULL_END
