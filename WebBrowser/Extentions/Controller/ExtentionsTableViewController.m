//
//  ExtentionsTableViewController.m
//  WebBrowser
//
//  Created by 钟武 on 2017/10/27.
//  Copyright © 2017年 钟武. All rights reserved.
//

#import "ExtentionsTableViewController.h"
#import "SettingSwitchTableViewCell.h"
#import "PreferenceHelper.h"
#import "SettingActivityTableViewCell.h"
#import "NSFileManager+ZWUtility.h"
static NSString *const kExtentionsTableViewSwitchCellIdentifier = @"ExtentionsTableViewSwitchCellIdentifier";
static NSString *const kExtentionsTableViewDefaultCellIdentifier = @"ExtentionsTableViewDefaultCellIdentifier";

static NSString *const kSettingActivityTableViewCellIdentifier = @"SettingActivityTableViewCellIdentifier";
static NSString *const kSettingPlaceholderTableViewCellIdentifier   = @"SettingPlaceholderTableViewCellIdentifier";
typedef NS_ENUM(NSUInteger, ExtentionsTableViewCellKind) {
    ExtentionsTableViewCellKindOfNoImage,
    ExtentionsTableViewCellKindOfBlockBaiduAD,
    ExtentionsTableViewCellKindOfEyeProtective
};

@interface ExtentionsTableViewController ()

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, copy) NSArray *footerDescriptionArray;
@property (nonatomic, copy) NSArray *dataKeyArray;
@property (nonatomic, strong) NSIndexPath *eyeColorIndexPath;

@end

@implementation ExtentionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.dataArray = @[@"无图模式",@"去除百度广告",@"护眼模式",@"清除缓存"];
    //self.footerDescriptionArray = @[@"注意：无图模式仅对图片进行了隐藏，浏览器依然会发起图片资源请求",@"去除百度搜索页面广告及banner推广,基于https://greasyfork.org/scripts/24192-kill-baidu-ad/code/Kill%20Baidu%20AD.user.js代码修改,感谢作者@hoothin",@"护眼扩展,修改网页背景色,关闭护眼功能需刷新页面才能生效",@"清除浏览数据"];
    self.footerDescriptionArray = @[@"",@"",@"护眼扩展,修改网页背景色,关闭护眼功能需刷新页面才能生效",@""];
    self.dataKeyArray = @[KeyNoImageModeStatus, KeyBlockBaiduADStatus, KeyEyeProtectiveStatus];
    self.tableView.sectionHeaderHeight = 0;
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingSwitchTableViewCell class]) bundle:nil] forCellReuseIdentifier:kExtentionsTableViewSwitchCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kExtentionsTableViewDefaultCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SettingActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:kSettingActivityTableViewCellIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kSettingPlaceholderTableViewCellIdentifier];
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(closeView)];
    self.navigationItem.rightBarButtonItem = closeItem;
    self.title = @"设置";
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAutomatic;
    } else {
        // Fallback on earlier versions
    }
}

- (void)closeView{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == ExtentionsTableViewCellKindOfEyeProtective) {
        return [PreferenceHelper boolForKey:KeyEyeProtectiveStatus] ? 5 : 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ExtentionsTableViewCellKindOfEyeProtective && indexPath.row > 0) {
        return [self configureEyeProtectiveCellAtIndexPath:indexPath];
    }
    if (indexPath.section < 3) {
        SettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kExtentionsTableViewSwitchCellIdentifier forIndexPath:indexPath];
        
        ValueChangedBlock valueChangedBlock = nil;
        
        if (indexPath.section == ExtentionsTableViewCellKindOfNoImage) {
            valueChangedBlock = ^(UISwitch *sw){
                [Notifier postNotification:[NSNotification notificationWithName:kNoImageModeChanged object:nil]];
            };
        }
        else if (indexPath.section == ExtentionsTableViewCellKindOfEyeProtective) {
            valueChangedBlock = ^(UISwitch *sw){
                NSMutableArray<NSIndexPath *> *array = [NSMutableArray arrayWithCapacity:4];
                for (int i = 1; i < 5; i++) {
                    [array addObject:[NSIndexPath indexPathForRow:i inSection:ExtentionsTableViewCellKindOfEyeProtective]];
                }
                if (sw.on) {
                    [tableView insertRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationTop];
                }
                else {
                    [tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationBottom];
                }
            };
        }
        
        [self configureExtentionCell:cell section:indexPath.section valueChangedBlock:valueChangedBlock];
        return cell;
    }else{
        SettingActivityTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kSettingActivityTableViewCellIdentifier];
        
        cell.leftLabel.text = self.dataArray[indexPath.section];
        [cell.activityIndicatorView startAnimating];
        
        [cell setCalculateBlock:^{
            NSArray *urlArray = [NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil];

            long long size = [[NSFileManager defaultManager] getAllocatedSizeOfCacheDirectoryAtURLS:urlArray error:NULL];
            
            if (size == -1)
                return @"0M";
            
            NSString *sizeStr = [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleBinary];
            
            return sizeStr;
        }];
        
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    return self.footerDescriptionArray[section];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.eyeColorIndexPath && !([self.eyeColorIndexPath compare:indexPath] == NSOrderedSame)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:self.eyeColorIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [Notifier postNotificationName:kEyeProtectiveModeChanged object:nil];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [PreferenceHelper setInteger:indexPath.row forKey:KeyEyeProtectiveColorKind];
    
    self.eyeColorIndexPath = indexPath;
    if (indexPath.section == 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"您确定清除缓存？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            SettingActivityTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
            [cell.activityIndicatorView startAnimating];
            cell.rightLabel.text = @"";
            
            [self cleanCacheWithURLs:[NSArray arrayWithObjects:[NSURL URLWithString:CachePath], [NSURL URLWithString:TempPath], nil] completionBlock:^{
                [cell.activityIndicatorView stopAnimating];
                [cell.rightLabel setText:@"0M"];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){}];
        
        [alert addAction:defaultAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}
#pragma mark - Clean Cache Method

- (void)cleanCacheWithURLs:(NSArray<NSURL *> *)array completionBlock:(SettingVoidReturnNoParamsBlock)completionBlock{
    if (array.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [array enumerateObjectsUsingBlock:^(NSURL *diskCacheURL, NSUInteger idx, BOOL *stop){
            @autoreleasepool {
                NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:diskCacheURL includingPropertiesForKeys:nil options:0 error:NULL];
                foreach(path, array) {
                    if (![[path lastPathComponent] isEqualToString:@"Snapshots"]) {
                        [[NSFileManager defaultManager] removeItemAtURL:path error:NULL];
                    }
                }
            }
        }];
        
        if (completionBlock) {
            dispatch_main_safe_async(^{
                completionBlock();
            })
        }
    });
}
#pragma mark - Helper method

- (void)configureExtentionCell:(SettingSwitchTableViewCell *)cell section:(NSInteger)section valueChangedBlock:(ValueChangedBlock)block{
    cell.leftLabel.text = self.dataArray[section];
    
    NSString *dataKey = self.dataKeyArray[section];
    if ([dataKey isEqualToString:KeyBlockBaiduADStatus]) {
        [cell.switchControl setOn:[PreferenceHelper boolDefaultYESForKey:KeyBlockBaiduADStatus]];
    }
    else {
        [cell.switchControl setOn:[PreferenceHelper boolForKey:dataKey]];
    }
    
    ValueChangedBlock valueChangedBlock = ^(UISwitch *sw){
        [PreferenceHelper setBool:sw.on forKey:dataKey];
        
        if (block) {
            block(sw);
        }
    };
    
    cell.valueChangedBlock = valueChangedBlock;
}

- (UITableViewCell *)configureEyeProtectiveCellAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<NSString *> *titleArray = @[@"",@"乡土黄",@"豆沙绿",@"浅色灰",@"淡橄榄"];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kExtentionsTableViewDefaultCellIdentifier];
    cell.textLabel.text = titleArray[indexPath.row];
    
    if ([PreferenceHelper integerDefault1ForKey:KeyEyeProtectiveColorKind] == indexPath.row) {
        self.eyeColorIndexPath = indexPath;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
