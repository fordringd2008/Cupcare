//
//  DFToAppStore.m
//  Bracelet
//
//  Created by 丁付德 on 16/5/23.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "DFToAppStore.h"

#define updateTitle    kString(@"发现新版本")
#define updateMessage  kString(@"优化蓝牙连接，提升用户体验")
#define updateLater    kString(@"暂不更新")
#define updateGo       kString(@"去更新")


#define commentTitle   kString(@"致用户的一封信")
#define commentMessage kString(@"有了您的支持才能更好的为您服务，提供更加优质的，更加适合您的App，当然您也可以直接反馈问题给到我们")
#define commentRefuse  kString(@"残忍拒绝")
#define commentGod     kString(@"好评赞赏")
#define commentBad     kString(@"我要吐槽")


@implementation DFToAppStore

-(instancetype)initWithAppID:(int)appID
{
    self = [super init];
    if (self) {
        self.myAppID = [NSString stringWithFormat:@"%d", appID];
    }
    return self;
}

-(void)updateGotoAppStore:(UIViewController *)VC
{
    NSString *nowVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", self.myAppID]];
    NSString * file =  [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    NSRange substr = [file rangeOfString:@"\"version\":\""];
    NSRange range1 = NSMakeRange(substr.location+substr.length,10);
    NSRange substr2 =[file rangeOfString:@"\"" options:NSCaseInsensitiveSearch range:range1];
    NSRange range2 = NSMakeRange(substr.location+substr.length, substr2.location-substr.location-substr.length);
    NSString *newVersion =[file substringWithRange:range2];
    if (!newVersion) return; // 这里说明没有网络

    //userDefaults里的天数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int udtheDays = [[userDefaults objectForKey:@"theDaysUpdate"] intValue];
    
    NSDate *today = DNow;
    NSInteger nowtheDays = [self getFromDate:today type:1] * 10000 + [self getFromDate:today type:2] * 100 + [self getFromDate:today type:3];
    
    BOOL isSure;
    
    NSArray *arrNew = [newVersion componentsSeparatedByString:@"."];
    NSArray *arrNow = [nowVersion componentsSeparatedByString:@"."];
    if (arrNew.count == 3 && arrNow.count == 3) {
        int intNew = [arrNew[0] intValue] * 10000 + [arrNew[1] intValue] * 100 + [arrNew[2] intValue];
        int intNow = [arrNow[0] intValue] * 10000 + [arrNow[1] intValue] * 100 + [arrNow[2] intValue];
        isSure = intNew <= intNow;
    }else{
        isSure = [newVersion isEqualToString:nowVersion];
    }

    
    if (newVersion && isSure) {
        [userDefaults removeObjectForKey:@"theDaysUpdate"];
    }
    else if (nowtheDays != udtheDays)
    {
        [self updateAlertUserCommentView:VC];
    }
}

- (void)commentGotoAppStore:(UIViewController *)VC
{
    //当前版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
    //userDefaults里的天数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int udtheDays = [[userDefaults objectForKey:@"theDays"] intValue];
    //userDefaults里的版本号
    float udAppVersion = [[userDefaults objectForKey:@"appVersion"] intValue];
    //userDefaults里用户上次的选项
    int udUserChoose = [[userDefaults objectForKey:@"userOptChoose"] intValue];
    //时间戳的天数
    NSTimeInterval interval = [DNow timeIntervalSince1970];
    int daySeconds = 24 * 60 * 60;
    NSInteger theDays = interval / daySeconds;
    
    //版本升级之后的处理,全部规则清空,开始弹窗
    if (udAppVersion && appVersion>udAppVersion) {
        [userDefaults removeObjectForKey:@"theDays"];
        [userDefaults removeObjectForKey:@"appVersion"];
        [userDefaults removeObjectForKey:@"userOptChoose"];
        [self commentAlertUserCommentView:VC];
    }
    //1,从来没弹出过的
    //2,用户选择😓我要吐槽，7天之后再弹出
    //3,用户选择😭残忍拒绝后，7天内，每过1天会弹一次
    //4,用户选择😭残忍拒绝的30天后，才会弹出
    else if (!udUserChoose ||
             (udUserChoose==2 && theDays-udtheDays>7) ||
             (udUserChoose>=3 && theDays-udtheDays<=7 && theDays-udtheDays>udUserChoose-3) ||
             (udUserChoose>=3 && theDays-udtheDays>30))
    {
        [self commentAlertUserCommentView:VC];
    }
    
}

-(void)commentAlertUserCommentView:(UIViewController *)VC
{
    __block DFToAppStore *blockSelf = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //当前时间戳的天数
        NSTimeInterval interval = [DNow timeIntervalSince1970];
        int daySeconds = 24 * 60 * 60;
        NSInteger theDays = interval / daySeconds;
        //当前版本号
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
        //userDefaults里版本号
        float udAppVersion = [[userDefaults objectForKey:@"appVersion"] intValue];
        //userDefaults里用户选择项目
        int udUserChoose = [[userDefaults objectForKey:@"userOptChoose"] intValue];
        //userDefaults里用户天数
        int udtheDays = [[userDefaults objectForKey:@"theDays"] intValue];
        
        //当前版本比userDefaults里版本号高
        if (appVersion>udAppVersion) {
            [userDefaults setObject:[NSString stringWithFormat:@"%f",appVersion] forKey:@"appVersion"];
        }
        
        alertController = [UIAlertController alertControllerWithTitle:@"致开发者的一封信" message:@"有了您的支持才能更好的为您服务，提供更加优质的，更加适合您的App，当然您也可以直接反馈问题给到我们" preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:@"😭残忍拒绝" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            [userDefaults setObject:@"1" forKey:@"userOptChoose"];
            [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"😄好评赞赏" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            [userDefaults setObject:@"2" forKey:@"userOptChoose"];
            [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
            
            [blockSelf gotoAppStore];
        }];
        
        UIAlertAction *showAction = [UIAlertAction actionWithTitle:@"😓我要吐槽" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
            
            if (udUserChoose<=3 || theDays-[[userDefaults objectForKey:@"theDays"] intValue]>30) {
                [userDefaults setObject:@"3" forKey:@"userOptChoose"];
                [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
            }else{
                [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)(theDays-udtheDays+3)] forKey:@"userOptChoose"];
            }
            [blockSelf gotoAppStore];

        }];
        
        
        [alertController addAction:refuseAction];
        [alertController addAction:okAction];
        [alertController addAction:showAction];
        
        
        [VC presentViewController:alertController animated:YES completion:nil];
        
    }else{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        alertViewTest = [[UIAlertView alloc] initWithTitle:commentTitle
                                                         message:commentMessage
                                                        delegate:self
                                               cancelButtonTitle:[NSString stringWithFormat:@"😭%@", commentRefuse]
                                               otherButtonTitles:[NSString stringWithFormat:@"😄%@", commentGod], [NSString stringWithFormat:@"😓%@", commentBad], nil];
        
        [alertViewTest show];
#endif
    }
    
}


-(void)updateAlertUserCommentView:(UIViewController *)VC
{
    __block DFToAppStore *blockSelf = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate *today = DNow;
    NSInteger nowtheDays = [self getFromDate:today type:1] * 10000 + [self getFromDate:today type:2] * 100 + [self getFromDate:today type:3];
    [userDefaults setObject:[NSString stringWithFormat:@"%@", @(nowtheDays)] forKey:@"theDaysUpdate"];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        alertController = [UIAlertController alertControllerWithTitle:updateTitle message:updateMessage preferredStyle:(UIAlertControllerStyleAlert)];
        
        UIAlertAction *refuseAction = [UIAlertAction actionWithTitle:updateLater style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:updateGo style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action)
        {
            [blockSelf gotoAppStore];
        }];
        
        [alertController addAction:refuseAction];
        [alertController addAction:okAction];
        
        [VC presentViewController:alertController animated:YES completion:nil];
    }else{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
        alertViewTestUpdate = [[UIAlertView alloc] initWithTitle:updateTitle
                                                         message:updateMessage
                                                        delegate:self
                                               cancelButtonTitle:updateGo
                                               otherButtonTitles:updateLater, nil];
        
        [alertViewTestUpdate show];
#endif
    }
    
}



#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    __block DFToAppStore *blockSelf = self;
    if ([alertView isEqual:alertViewTest])
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //当前时间戳的天数
        NSTimeInterval interval = [DNow timeIntervalSince1970];
        int daySeconds = 24 * 60 * 60;
        NSInteger theDays = interval / daySeconds;
        //当前版本号
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        float appVersion = [[infoDictionary objectForKey:@"CFBundleShortVersionString"] floatValue];
        //userDefaults里版本号
        float udAppVersion = [[userDefaults objectForKey:@"appVersion"] intValue];
        //userDefaults里用户选择项目
        int udUserChoose = [[userDefaults objectForKey:@"userOptChoose"] intValue];
        //userDefaults里用户天数
        int udtheDays = [[userDefaults objectForKey:@"theDays"] intValue];
        
        //当前版本比userDefaults里版本号高
        if (appVersion>udAppVersion) {
            [userDefaults setObject:[NSString stringWithFormat:@"%f",appVersion] forKey:@"appVersion"];
        }
        
        switch (buttonIndex)
        {
            case 0: //残忍的拒绝
                if (udUserChoose<=3 || theDays-[[userDefaults objectForKey:@"theDays"] intValue]>30) {
                    [userDefaults setObject:@"3" forKey:@"userOptChoose"];
                    [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
                }else{
                    [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)(theDays-udtheDays+3)] forKey:@"userOptChoose"];
                }
                break;
            case 1:{ //好评
                [userDefaults setObject:@"1" forKey:@"userOptChoose"];
                [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
                [blockSelf gotoAppStore];
            }
                break;
            case 2:{ //不好用，我要提意见
                [userDefaults setObject:@"2" forKey:@"userOptChoose"];
                [userDefaults setObject:[NSString stringWithFormat:@"%d",(int)theDays] forKey:@"theDays"];
                [blockSelf gotoAppStore];
            }
                break;
                
            default:
                break;
        }
    }else{
        [blockSelf gotoAppStore];
    }
}



#endif


-(NSInteger)getFromDate:(NSDate *)date type:(int)type
{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit |
    NSMonthCalendarUnit |
    NSDayCalendarUnit |
    NSWeekdayCalendarUnit |
    NSHourCalendarUnit |
    NSMinuteCalendarUnit |
    NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
    switch (type) {
        case 1:
            return [comps year];
            break;
        case 2:
            return [comps month];
            break;
        case 3:
            return [comps day];
            break;
        case 4:
            return [comps hour];
            break;
        case 5:
            return [comps minute];
            break;
        case 6:
            return [comps second];
            break;
        case 7:
            return ([comps weekday] - 1);
            break;
        default:
            break;
    }
    return 0;
}

-(void)gotoAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:
                                                                     @"https://itunes.apple.com/cn/app/id%@?mt=8",
                                                                     _myAppID ]]];
}



@end
