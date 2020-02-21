//
//  AppDelegate.m
//  WebBrowser
//
//  Created by 钟武 on 16/7/29.
//  Copyright © 2016年 钟武. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "AppDelegate.h"
#import "KeyboardHelper.h"
#import "MenuHelper.h"
#import "BrowserViewController.h"
#import "WebServer.h"
#import "ErrorPageHelper.h"
#import "SessionRestoreHelper.h"
#import "TabManager.h"
#import "PreferenceHelper.h"
#import "BaseNavigationViewController.h"

#import <UMCommon/UMCommon.h>
#import <UMPush/UMessage.h>
#import <UserNotifications/UserNotifications.h>
#import <UMShare/UMShare.h>
#import <UMAnalytics/MobClick.h>

static NSString * const kUserAgentOfiOS = @"Mozilla/5.0 (iPhone; CPU iPhone OS %ld_0 like Mac OS X) AppleWebKit/602.1.38 (KHTML, like Gecko) Version/%ld.0 Mobile/14A300 Safari/602.1";

@interface AppDelegate ()

@property (nonatomic, assign) NSInteger pasteboardChangeCount;

@end

@implementation AppDelegate

- (void)dealloc {
    [Notifier removeObserver:self name:UIPasteboardChangedNotification object:nil];
}

- (void)setAudioPlayInBackgroundMode {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}

- (void)handlePasteboardNotification:(NSNotification *)notify {
    self.pasteboardChangeCount = [UIPasteboard generalPasteboard].changeCount;
}

- (void)presentPasteboardChangedAlertWithURL:(NSURL *)url {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"新窗口打开剪切板网址" message:@"您是否需要在新窗口中打开剪切板中的网址？" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        NSNotification *notify = [NSNotification notificationWithName:kOpenInNewWindowNotification object:self userInfo:@{@"url": url}];
        [Notifier postNotification:notify];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)makeWebViewSafariLike {
	NSOperatingSystemVersion systemVersion = [[NSProcessInfo processInfo] operatingSystemVersion];
	NSInteger version = systemVersion.majorVersion;

	NSString *userAgent = [NSString stringWithFormat:kUserAgentOfiOS, version, version];
	//解决WebView首次加载页面时间过长问题,设置UserAgent减少跳转和判断
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : userAgent}];
}

- (void)applicationStartPrepare {
    [self setAudioPlayInBackgroundMode];
    [[KeyboardHelper sharedInstance] startObserving];
    [[MenuHelper sharedInstance] setItems];
    
    [Notifier addObserver:self selector:@selector(handlePasteboardNotification:) name:UIPasteboardChangedNotification object:nil];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    DDLogDebug(@"Home Path : %@", HomePath);
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
                                                         diskCapacity:32 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    BrowserViewController *browserViewController = BrowserVC;
    
    BaseNavigationViewController *navigationController = [[BaseNavigationViewController alloc] initWithRootViewController:browserViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    
    [ErrorPageHelper registerWithServer:[WebServer sharedInstance]];
    [SessionRestoreHelper registerWithServer:[WebServer sharedInstance]];
    
    [[WebServer sharedInstance] start];
    
	[self makeWebViewSafariLike];
    
    [TabManager sharedInstance];    //load archive data in advance
    
    // Delay some operations
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self applicationStartPrepare];
    });
    
    [UMConfigure setLogEnabled:YES];
    
    
    [UMConfigure initWithAppkey:@"5e4ea006895ccac57600012c" channel:@"App Store"];
    
    // Push组件基本功能配置
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            
        }else{
        }
    }];
    
    NSString * deviceID =[UMConfigure deviceIDForIntegration];
    NSLog(@"集成测试的deviceID:%@", deviceID);
    NSData * jsonData =[NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: nil];
    NSLog(@"%@", [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding]);
    
    // U-Share 平台设置
    [self configUSharePlatforms];
    [self confitUShareSettings];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if (self.pasteboardChangeCount != pasteboard.changeCount) {
        self.pasteboardChangeCount = pasteboard.changeCount;
        NSURL *url = pasteboard.URL;
        if (url && ![[PreferenceHelper URLForKey:KeyPasteboardURL] isEqual:url]) {
            [PreferenceHelper setURL:url forKey:KeyPasteboardURL];
            [self presentPasteboardChangedAlertWithURL:url];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Enable WebView video landscape
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    static NSString *kAVFullScreenViewControllerStr = @"AVFullScreenViewController";
    UIViewController *presentedViewController = [window.rootViewController presentedViewController];

    if (presentedViewController && [presentedViewController isKindOfClass:NSClassFromString(kAVFullScreenViewControllerStr)] && [presentedViewController isBeingDismissed] == NO) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Preseving and Restoring State

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder{
    return YES;
}

#pragma mark - 分享
- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    [UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxcaeb49c2e82d7302" appSecret:@"13394f81e0d927e3194016b539273f9b" redirectURL:@"http://kkyun.com"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"101536069"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://kkyun.com"];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"http://kkyun.com"];
    
    
}
@end
