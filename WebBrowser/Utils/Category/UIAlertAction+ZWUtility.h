//
//  UIAlertAction+ZWUtility.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/9/25.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertAction (ZWUtility)

+ (UIAlertAction *)actionCopyLinkWithURL:(NSURL *)linkURL;
+ (UIAlertAction *)actionOpenNewTabWithCompletion:(void (^)(void))completion;
+ (UIAlertAction *)actionDismiss;
+ (UIAlertAction *)actionSettings;

@end
