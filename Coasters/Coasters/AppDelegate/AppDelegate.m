//
//  AppDelegate.m
//  Coasters
//
//  Created by 丁付德 on 15/8/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "AppDelegate.h"

#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <FacebookConnection/ISSFacebookApp.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <SMS_SDK/SMSSDK.h>                              // 短信
#import <SMS_SDK/SMSSDK+AddressBookMethods.h>
#import <MOBFoundation/MOBFoundation.h>
#import "JPUSHService.h"
#import "LxxPlaySound.h"
#import <Bugtags/Bugtags.h>
#import <JSPatch/JSPatch.h>
#import "NetManager.h"
#import "MobClick.h"
#import "XMLHelper.h"
#import "vcStart.h"


#import <UserNotifications/UserNotifications.h>
@interface AppDelegate() <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [JSPatch startWithAppKey:JSPatchKey];
    #if isDevelemont == 1
    [JSPatch setupDevelopment];
    #endif
    [JSPatch sync];

    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord enableShorthandMethods];
    [self persistentStoreCoordinator];
    
    [Bugtags startWithAppKey:BugTagsAppKey invocationEvent:BTGInvocationEventNone options:({
        BugtagsOptions *options = [[BugtagsOptions alloc] init];
        options.trackingCrashes = YES;
        options;
    })];
    
    [MobClick startWithAppkey:UMengKey reportPolicy:BATCH channelId:nil];
    
    [NetManager observeNet];
    [self initInitData:launchOptions];
    [self initializePlat];
    [self initRootView:launchOptions];
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    return YES;
}


//  applicationDidBecomeActive是app在后台运行，通知时间到了，你从通知栏进入，或者直接点app图标进入时，会走的方法。
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    SetUserDefault(NewPushData, @YES);         // 重新拉去 不能删
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
}

//添加两个回调方法,return的必须要ShareSDK的方法
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}


// 是app在前台运行，通知时间到了，调用的方法。如果程序在后台运行，时间到了以后是不会走这个方法的。
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self setNoti:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [JPUSHService registerDeviceToken:deviceToken];
}

// 当 DeviceToken 获取失败时，系统会回调此方法
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"DeviceToken 获取失败，原因：%@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self setNoti:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
//    if (notification.userInfo && [notification.userInfo.allKeys containsObject:DFD_Notif_LongTime]) return;
//    [self setIconNumber:0];
}

-(void)setNoti:(NSDictionary *)userInfo
{
    [[[LxxPlaySound alloc] initForPlayingVibrate] play];
    [JPUSHService handleRemoteNotification:userInfo];
    NSLog(@"------------------------------------ > 收到通知了  %@", userInfo);
    SetUserDefault(NewPushData, @YES);
}


// 初始化分享
-(void)initializePlat
{
    [ShareSDK registerApp:SHARESDKID];
    [ShareSDK connectSinaWeiboWithAppKey:SinaKEY
                               appSecret:SinaSECRET
                             redirectUri:ShareUrl
                             weiboSDKCls:[WeiboSDK class]];
    
    [ShareSDK connectQZoneWithAppKey:QQKEY
                           appSecret:QQSECRET
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    
    
    [ShareSDK connectQQWithQZoneAppKey:QQKEY
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    
    [ShareSDK connectWeChatWithAppId:WeiXinKEY
                           appSecret:WeiXinSECRET
                           wechatCls:[WXApi class]];
    
    
    [ShareSDK connectFacebookWithAppKey:FacebookKEY
                              appSecret:FacebookSECRET];
    
    [ShareSDK connectTwitterWithConsumerKey:TwitterKEY
                             consumerSecret:TwitterSECRET
                                redirectUri:ShareUrl];
    //开启Facebook网页授权开关
    id<ISSFacebookApp> facebookApp =(id<ISSFacebookApp>)[ShareSDK getClientWithType:ShareTypeFacebook];
    [facebookApp setIsAllowWebAuthorize:YES];
    
    
    [SMSSDK registerApp:SMSAppKey
             withSecret:SMSAppSecret];
    [[MOBFDataService sharedInstance] setCacheData:SMSAppKey forKey:@"appKey" domain:nil];
    [[MOBFDataService sharedInstance] setCacheData:SMSAppSecret forKey:@"appSecret" domain:nil];
}

//加载rootView
- (void)initRootView:(NSDictionary *)launchOptions
{
    self.sideViewController = [[YRSideViewController alloc] init];
    self.sideViewController.leftViewController = NSClassFromString(@"vcLeft").new;
    self.sideViewController.leftViewShowWidth = 260;
    self.sideViewController.needSwipeShowMenu = YES;
    
    self.customTb = [[CustomTabBarController alloc] init];
    self.sideViewController.rootViewController = self.customTb;
    
    UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:[NSBundle mainBundle]];
    self.loginNavigationController =  login.instantiateInitialViewController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (!GetUserDefault(ISFISTRINSTALL))
    {
        SetUserDefault(ISFISTRINSTALL, @"ISFISTRINSTALL");
        vcStart *start = [[vcStart alloc] init];
        __block AppDelegate *blockSelf = self;
        __block NSDictionary*blockLaunchOptions = launchOptions;
        start.getPermissions = ^{
            [blockSelf initPushData:blockLaunchOptions];
        };
        start.gotoMainStory = ^{
            blockSelf.window.rootViewController = blockSelf.loginNavigationController;
        };
        self.window.rootViewController = start;
    }
    else
    {
        [self resetNotification];
        [DFD setIconNumber:0];
        UserInfo *us = myUserInfo;
        if (us.access)
        {
            SetUserDefault(isNotRealNewBLE, @1);
            self.window.rootViewController = self.sideViewController;
        }
        else
        {
            self.window.rootViewController = self.loginNavigationController;
        }
        [self.window makeKeyAndVisible];
    }
}



-(void)initInitData:(NSDictionary *)launchOptions
{
    [Clock initClockData];
    SetUserDefault(isNotRealNewBLE, @0);
    SetUserDefault(IsLogined, @NO);
    
    if (GetUserDefault(is24))               RemoveUserDefault(is24);
    if (GetUserDefault(CurrentLanguage))    RemoveUserDefault(CurrentLanguage);
    NSLog(@"之前绑定的语言是 %@，现在的%@", @([GetUserDefault(JPushBindLanguage) intValue]),@([DFD getLanguage]));
    if([DFD getLanguage] != [GetUserDefault(JPushBindLanguage) intValue])
    {
        self.isBind = NO;
        [self repeatBind:YES];
    }
    SetUserDefault(CurrentLanguage, @([DFD getLanguage]))
    self.isBind = [GetUserDefault(JPushBind) boolValue];
    NSLog(@"是否已经绑定了推送 ：%@, 推送的语言为%@", @(self.isBind),@([GetUserDefault(JPushBindLanguage) intValue]));
    
    if (GetUserDefault(isSynDataOver)) RemoveUserDefault(isSynDataOver);
    if (!GetUserDefault(dateLastPostSMS)) SetUserDefault(dateLastPostSMS, (@[@0,DNow,@0]));
    if (GetUserDefault(userInfoData))   // 这里要考虑上一个版本的 如果 键值对中 值(数组)的个人小于5， 就移除
    {
        NSDictionary *dicSub = GetUserDefault(userInfoData);
        if (dicSub.allValues.count < 5) {
            RemoveUserDefault(userInfoData);
        }
    }
    
    NextWaitInGlobal([[XMLHelper shareManager] initCityData];);
}


-(void)repeatBind:(BOOL)isBinding{
    if(TARGET_IPHONE_SIMULATOR)
        return;
    if (self.timerR) {
        [self.timerR DF_stop];
        self.timerR = nil;
    }
    
    __block AppDelegate *blockSelf = self;
    [blockSelf bindChannel:isBinding];
    self.timerR = [NSTimer DF_sheduledTimerWithTimeInterval:5 block:^{
        [blockSelf bindChannel:isBinding];
    } repeats:YES];
}

-(void)bindChannel:(BOOL)isBinding
{
    static BOOL isFirstBind = YES;
    __block AppDelegate *blockSelf = self;
    NSString *alias = isBinding ? myUserInfoAccess : GetUserDefault(PushAlias);
    if (!alias) return;
    if (isBinding && (alias || isFirstBind))
    {
        NSLog(@"去极光绑定");
        isFirstBind = NO;
        NSSet *setThis = [[NSSet alloc] initWithObjects:[NSString stringWithFormat:@"%02d", [DFD getLanguage]], nil];
        [JPUSHService setTags:setThis alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            NSLog(@"绑定%@--->%d, 语言: %@, 别名: %@\n", iResCode?@"失败":@"成功", iResCode, iTags, iAlias);
            if (!iResCode) {
                blockSelf.isBind = YES;
                SetUserDefault(JPushBind, @YES);
                SetUserDefault(JPushBindLanguage, @([DFD getLanguage]));
                if (blockSelf.timerR) {
                    [blockSelf.timerR DF_stop];
                    blockSelf.timerR = nil;
                }
            }
        }];
    }
    else
    {
        NSLog(@"去极光解绑");
        [JPUSHService setTags:[NSSet set] alias:@"" fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            NSLog(@"解除绑定%@--->%d, 语言: %@, 别名: %@\n", iResCode?@"失败":@"成功", iResCode, iTags, iAlias);
            if (!iResCode) {
                blockSelf.isBind = NO;
                SetUserDefault(JPushBind, @NO);
                RemoveUserDefault(JPushBindLanguage);
                RemoveUserDefault(PushAlias);
                if (blockSelf.timerR) {
                    [blockSelf.timerR DF_stop];
                    blockSelf.timerR = nil;
                }
            }
        }];
    }
}

-(void)initPushData:(NSDictionary *)launchOptions
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
    [JPUSHService setupWithOption:launchOptions
                           appKey:JPushKEY
                          channel:SinaURL
                 apsForProduction:!isDevelemont];
    [JPUSHService setLogOFF];
    
}

-(void)setUpBackGroundReflash{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:1800];
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Coasters" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


-(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSLog(@"------------------------------- > 数据迁移");  // 数据迁移完成
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[DFD getDomentURL] stringByAppendingPathComponent: @"Coasters.sqlite"]];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
    }
    
    return persistentStoreCoordinator;
}

-(void)resetNotification
{
    // 要求 3天不打开APP的情况下，3天后每天通知一次
    [DFD clearNotification:DFD_Notif_LongTime];
    NSDate *time = [NSDate dateWithTimeIntervalSinceNow:3 * 24 * 60 * 60]; // 3天后的时间
    time = [[DFD getDateFromArr:@[ @([time getFromDate:1]), @([time getFromDate:2]), @([time getFromDate:3]), @8, @0, @0]] clearTimeZone];
    [DFD addLocalNotification:time
                       repeat:NSCalendarUnitDay
                    soundName:UILocalNotificationDefaultSoundName
                    alertBody:kString(@"美好的一天,从清晨的第一杯水开始")
   applicationIconBadgeNumber:0
                     userInfo:@{ DFD_Notif_LongTime : DFD_Notif_LongTime}];
}


@end
