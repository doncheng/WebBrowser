//
//  SettingSwitchTableViewCell.m
//  WebBrowser
//
//  Created by kkyun.com on 2017/2/14.
//  Copyright © 2017年 kkyun.com. All rights reserved.
//

#import "SettingSwitchTableViewCell.h"

@implementation SettingSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.switchControl addTarget:self action:@selector(handleSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    
    self.valueChangedBlock = nil;
}

- (void)handleSwitchValueChanged:(UISwitch *)switchControl{
    if (self.valueChangedBlock) {
        self.valueChangedBlock(switchControl);
    }
}

@end
