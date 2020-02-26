//
//  SearchTableViewCell.h
//  WebBrowser
//
//  Created by kkyun.com on 2017/1/7.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewCell : UITableViewCell

- (void)updateCellWithString:(NSString *)text;
- (NSString *)cellText;

@end
