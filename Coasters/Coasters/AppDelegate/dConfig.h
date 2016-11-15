//
//  dConfig.h
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#ifndef aerocom_dConfig_h
#define aerocom_dConfig_h

#import <Availability.h>

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif


#define isGift                              0           // 是否是礼品项目
#define isHaveBalance                       0           // 是否包含电子称功能
#define isDevelemont                        1           // 是否是开发版   （发布版）

// 发布时屏蔽NSLog
#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
//#define NSLog(...) NSLog(@"%s 第%d行 -> %@",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...) {}
#endif


//#warning 1, 礼品公司的名称需要是中英文的
#define AppNameForServer                    (isGift ? @"healthmate":@"cupcare")

#define RGBA(_R,_G,_B,_A)                   [UIColor colorWithRed:_R / 255.0f green:_G / 255.0f blue:_B / 255.0f alpha:_A]
#define RGB(_R,_G,_B)                       RGBA(_R,_G,_B,1)

// ------- 本地存储
#define GetUserDefault(key)                 [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define SetUserDefault(k, v)                [[NSUserDefaults standardUserDefaults] setObject:v forKey:k]; [[NSUserDefaults standardUserDefaults]  synchronize];
#define RemoveUserDefault(k)                [[NSUserDefaults standardUserDefaults] removeObjectForKey:k]; [[NSUserDefaults standardUserDefaults] synchronize];

#define DDWeak(type)                        __weak typeof(type) weak##type = type;
#define DDStrong(type)                      __strong typeof(type) type = weak##type;

#define MBShowAll                           [MBProgressHUD showHUDAddedTo:self.windowView animated:YES];
#define MBShowAllInBlock                    [MBProgressHUD showHUDAddedTo:blockSelf.windowView animated:YES];
#define MBShowAllWithText(_k)               [MBProgressHUD showHUDAddedTo:self.windowView animated:YES text:_k];
#define MBShowAllInBlockWithText(_k)        [MBProgressHUD showHUDAddedTo:blockSelf.windowView animated:YES text:_k];

#define MBHide                              [MBProgressHUD hideAllHUDsForView:self.windowView animated:YES];
#define MBHideInBlock                       [MBProgressHUD hideAllHUDsForView:blockSelf.windowView animated:YES];
#define LMBShow(message)                    [MBProgressHUD show:kString(message) toView:self.windowView];
#define LMBShowInBlock(message)             [MBProgressHUD show:kString(message) toView:blockSelf.windowView];
#define HDDAF                               DDWeak(self) NextWaitInMainAfter(DDStrong(self);MBHide, 20);

// ------- 系统相关
#define IPhone4                             (ScreenHeight == 480) 
#define IPhone5                             (ScreenHeight == 568)
#define IPhone6                             (ScreenHeight == 667)
#define IPhone6P                            (ScreenHeight == 736)


#define SystemVersion                       [[[UIDevice currentDevice] systemVersion] doubleValue]  // 当前系统版本
#define IOS7Later                           (SystemVersion>=7.0)?YES:NO                  // 系统版本是否是iOS7+
#define IS_Only_IOS_7                       (SystemVersion>=7.0 && SystemVersion<8.0)?YES:NO     // 系统版本是否是iOS7.
//#define IS_IPad                             [[UIDevice currentDevice].model rangeOfString:@"iPad"].length > 0    // 是否是ipad
#define IS_IPad                             0    // 是否是ipad

// 中英文
#define kString(_S)                         NSLocalizedString(_S, @"")

// ------- 宽高
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define StateBarHeight                      20
#define NavBarHeight                        64
#define BottomHeight                        49
#define RealHeight(_k)                      ScreenHeight * (_k / 1280.0)
#define RealWidth(_k)                       ScreenWidth * (_k / 720.0)
#define ScreenRadio                         0.562                           // 屏幕宽高比


// ------- 控件相关
#define dHeightForBigView                   200
#define dCellHeight                         44
#define dTextSize(_key)                     [UIFont systemFontOfSize:_key]



#define myUserInfo                          [DFD getUserInfo]
#define myUserInfoAccess                    GetUserDefault(userInfoAccess)
#define NavButtonFrame                      CGRectMake(0, 0, 20, 20)

#define KgToLb                              0.4532
#define CmToFt                              0.0328             // cm -> ft 英尺
#define Picture_Limit_KB                    100
#define DefaultLogo                         @"person_default"
#define DefaultCircleLogo                   @"circle_head_01"
#define DefaultLogo_boy                     @"boy_default"
#define DefaultLogo_girl                    @"girl_default"
#define CurrentLanguage                     @"CurrentLanguage"
#define JPushBindLanguage                   @"JPushBindLanguage"    // 极光绑定的语言
#define LoadImage                           @"logo"
#define DefaultLogoImage                    [UIImage imageNamed:DefaultLogo]
#define DefaultCircleLogoImage              [UIImage imageNamed:DefaultCircleLogo]
#define DefaultLogo_Gender(_k)              [UIImage imageNamed:(_k ? DefaultLogo_girl:DefaultLogo_boy)]
#define LoadingImage                        [UIImage imageNamed:LoadImage]

#define NONetTip                            @"网络异常,请检查网络"
#define version_Local                       @"version_Local"


#define CheckIsOK                           [dic[@"status"] isEqualToString:@"0"]




#define RequestCheckBefore(_k1, _k2, _k3, _k4)        [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {_k3} inView:blockSelf.windowView isShowError:_k4];

#define RequestCheckAfter(_k1, _k2)            [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {} inView:blockSelf.windowView isShowError:YES];

#define RequestCheckNoWaring(_k1, _k2)        [NetManager DF_requestWithAction:^(NetManager *net) {_k1} success:^(NSDictionary *dic) {  _k2} failError:^(NSError *erro) {} inView:blockSelf.windowView isShowError:NO];


#define IMG(_k)                             [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]]] ? [UIImage imageWithData:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", [self getDomentURL], _k]]] : [UIImage imageNamed:_k]                          // 优先考虑Document中的文件

#define NextWaitInMain(_k)                  [DFD performBlockInMain:^{ _k }]
#define NextWaitInMainAfter(_k, _v)         [DFD performBlockInMain:^{ _k } afterDelay:_v]
#define NextWaitInCurrentTheard(_k, _v)     [DFD performBlockInCurrentTheard:^{ _k } afterDelay:_v]
#define NextWaitInGlobal(_k)                [DFD performBlockInGlobal:^{ _k }]
#define NextWaitInGlobalAfter(_k, _v)       [DFD performBlockInGlobal:^{ _k } afterDelay:_v]
#define NextWaitOnce(_k)                    [DFD performBlockOnce:^{ _k }]


#define LastSysDateTime                     (NSDate *)(GetUserDefault(LastSysDateTimeData)[myUserInfoAccess])  // 获取上次更新时间


#define plantNameLength                     20                       // 字节不能超过20

#define DDYear                              [DNow getFromDate:1]       // 当前的年份
#define DDMonth                             [DNow getFromDate:2]       // 当前的月份
#define DDDay                               [DNow getFromDate:3]       // 当前的日
#define DDHour                              [DNow getFromDate:4]       // 当前的时
#define DDMinute                            [DNow getFromDate:5]       // 当前的分
#define DDSecond                            [DNow getFromDate:6]       // 当前的秒


#define DidConnectColor                     RGB(17,127,216)    // 已连接的颜色
#define DidDisconnectColor                  RGB(68,81,100)     // 未连接的颜色
#define ConnectImg                          [UIImage imageFromColor:DidConnectColor]
#define DisConnectImg                        [UIImage imageFromColor:DidDisconnectColor]

#define GirlColor                           RGB(252,132,247)         // 粉色
#define DLightGrayBlackGroundColor          RGBA(240,240,240,1)
#define DButtonCurrentColor                 RGBA(170, 170, 170, 0.3)
#define btnRegisterBackColor1               RGBA(51, 169, 230, 0.8)
#define btnRegisterBackColor2               RGBA(37, 146, 237, 0.8)
#define DButtonHighlight                    RGB(19, 89, 209)


#define DWhite3                             [UIColor colorWithWhite:255 alpha:0.3]
#define Bigger(_a, _b)                      ((_a) > (_b) ? _a : _b)
#define Smaller(_a, _b)                     ((_a) < (_b) ? _a : _b)

#define Border(_label, _color)              _label.layer.borderWidth = 1; _label.layer.borderColor = _color.CGColor;

#define TipsListPangeCount                  10

// 默认图片地址
#define DEFAULTIMAGEADDRESS                 @"ios"
#define DEFAULTIMG                          [UIImage imageNamed:DEFAULTIMAGEADDRESS]

#define DEFAULTLOGOADDRESS                  @"thedefault"
#define DEFAULTTHTDEFAULT                   [UIImage imageNamed:DEFAULTLOGOADDRESS]


#define DBefaultContext                     [NSManagedObjectContext MR_defaultContext]
#define DBSave                              [DBefaultContext MR_saveToPersistentStoreAndWait];
#define DLSave                              [localContext MR_saveToPersistentStoreAndWait];

//  ------------------------------------------------------------  常用颜色 -----
#define DWhite                              [UIColor whiteColor]
#define DRed                                [UIColor redColor]
#define DBlue                               [UIColor blueColor]
#define DBlack                              [UIColor blackColor]
#define DYellow                             [UIColor yellowColor]
#define DBlack                              [UIColor blackColor]
#define DClear                              [UIColor clearColor]
#define DLightGray                          [UIColor lightGrayColor]
#define DWhiteA(_k)                         [UIColor colorWithWhite:255 alpha:_k]
#define DNow                                [NSDate date]

#define ISFISTRINSTALL                      @"ISFISTRINSTALL"   // 第一次运行标记
#define UserUnit                            @"UserUnit"
#define SystemPromptBegin                   @"SystemPromptBegin"
#define SystemPromptFinish                  @"SystemPromptFinish"
#define RangeUnit                           @"RangeUnit"
#define TemperatureUnit                     @"TemperatureUnit"
#define Latitude_Longitude                  @"Latitude_Longitude"
#define IsGetUserAddress                    @"IsGetUserAddress"
#define IndexData                           @"IndexData"     // 字典 ： key : access  value: 数组  1：水量 2 百分比 3 天
#define isFirstSys                          @"isFirstSys"                   // 默认为1   每次进入app的时候同步 同步完改为0
#define RemindCount                         @"RemindCount"                  // key flowerID string   value : 报警次数 numbe
#define CheckRemind                         @"CheckRemind"
#define HelpUrlVersion                      @"HelpUrlVersion"
#define isNotRealNewBLE                     @"isNotRealNewBLE"              //默认为O  在index设置为1
#define BLEisON                             @"BLEisON"

#define IsLogined                           @"IsLogined"                    // 是否登录过  每次打开APP， 都要重新登录 YES 登录过  NO 没有
#define LastSysDateTimeData                 @"LastSysDateTimeData"          // 上次同步的时间  字典 key: access value: 时间
#define LastUpLoadDateTimeData              @"LastUpLoadDateTimeData"       // 上次上传服务器时间  字典 key: access value: 时间
#define DFD_Notif_LongTime                  @"DFD_Notif_LongTime"           // 本地推送 3天不登陆的推送
#define DFD_Notif_Clock                     @"DFD_Notif_Clock"              // 一次性闹钟提醒
#define is24                                @"is24"
#define isFirstReadTimeSection              @"isFirstReadTimeSection"       // 是否是第一次读喝水提醒时间段
#define SysData                             @"SysData"          // 舍弃
#define TipsIn                              @"TipsIn"           //小贴士进入
#define NewPushData                         @"NewPushData"      //有新的推送消息
#define IndexFirstLoad                      @"IndexFirstLoad"   //首页的第一次加载
#define dicRemindWater                      @"dicRemindWater"   // 喝水提醒  key: uuid  value: NSArray[2] 1:工作日 2: 休息日
#define userInfoAccess                      @"userInfoAccess"
#define PushAlias                           @"PushAlias"
#define userInfoData                        @"userInfoData"// key ：access  value: 数组：0: email 1:密码 2：uerid
                                                                // value:0 email 或者 电话 或者第三方ID
                                                                // value:1 密码
                                                                // value:2 uerid
                                                                // value:3 登陆的类型 0 邮箱 1 电话 2 QQ 3 微博 4 face 5 twi


#define readBLEBack                         @"readBLEBack"    // 新数据更新
#define DNet                                @"DNet"           // 网络更新
#define IndexTabelReload                    @"IndexTabelReload"     // 强制首页刷新
#define isTag_                              @"isTag_"
#define isSynDataOver                       @"isSynDataOver"     // 同步结束
#define dateLastPostSMS                     @"dateLastPostSMS"   // 数组 0：5856 2： 上一次发短信的时间 3，第几次
#define JPushBind                           @"JPushBind"        // 本地表示，nil：未绑定
#define ExitUserOnce                        @"ExitUserOnce"     // 退出登录标示符 用于拉去首页第一次数据
                                                                // 0 表示要拉去， 1，不用拉去


//#define LastSetTarget                       @"LastSetTarget"        // 最后一次本地设置目标值的时间戳， key:access value: 13位时间戳



//  ------------------------------------------------------------  首页列表图片   -----

#define MDIndexType1                    @"water"
#define MDIndexType2                    @"water"
#define MDIndexType3                    @"news"
#define MDIndexType4                    @"remind"
#define MDIndexType5                    @"news"
#define MDIndexType6                    @"news"

#define DrinkWarnIntervel               (2 * 60 * 60)   // 多久没喝水 提醒一次




//  ------------------------------------------------------------  分享 -----
#if isGift == 0

#define orReaderPrefix                      @"http://www.sz-hema.com/download"

#define SHARESDKID                          @"fb1f0497d008"         // 这个在公司的账号下分享应用中
#define SMSAppKey                           @"fb166d8410f6"                         // 这个是Cupcare的
#define SMSAppSecret                        @"c4cf4b5bf8163f8a908d051167c0957d"
#define APPID                               1030210507
#define ShareContent                        @""
#define ShareDescription                    @""
#define ShareUrl                            @"http://www.sz-hema.com/"
#define SinaKEY                             @"792716411"
#define SinaSECRET                          @"d0972efe106a47f5341bb2627aab221b"
#define SinaURL                             @"http://www.sz-hema.com/"
#define QQKEY                               @"1104737683"   // QQ41D8F593
#define QQSECRET                            @"dpSU9sWfc77s4vXh"
#define WeiXinKEY                           @"wxe74cf85a732e85af"
#define WeiXinSECRET                        @"c3aed8a03c36f9e9fee6268993bde6a0"
#define TwitterKEY                          @"sfFnk1j3viN03KKiM7oueALbN"
#define TwitterSECRET                       @"hOFtUmBVp4aOmRIIzTC0WqpulCsiVBh46BtEQyrPaADdf7Rhvl"
#define FacebookKEY                         @"1512703895720996"  // fb1512703895720996
#define FacebookSECRET                      @"19ecf8d56c430c52884149649ccb0787"
#define BaiduPushKEY                        @"CVvcmDZMmQjKh7kd1BQTbMRG"  // 公司
#define BaiduPushSECRET                     @"hZ10wjQ4FKjU2FKIkcuCdU1012EvsqoM"
#define BugTagsAppKey                       @"1c0a0abd6f91a875e0e8cf02b4c52c8f"
#define BugTagsSecret                       @"8b7d2912418db3a2c0e94cc41f2d6bbe"
#define JSPatchKey                          @"1abfd1d0f4f7fa71"
#define UMengKey                            @"55e95c24e0f55a7b3300297f"
#define JPushKEY                            @"0e7f1fafd53d3fb3fa089601"   // 已OK
#define JPushSECRET                         @"964d02108655651435058314"   //

#else  // 礼品

#define orReaderPrefix                      @"http://www.marcosky.com"

#define SHARESDKID                          @"fb2060c124c4"         // 这个在公司的账号下分享应用中
#define SMSAppKey                           @"fb1c9d30e7a9"                         // 这个是HealthMate的
#define SMSAppSecret                        @"da19b0e37acd77faf52f128a4753e009"
#define APPID                               1076074269
#define ShareContent                        @""
#define ShareDescription                    @""
#define ShareUrl                            @"http://www.marcosky.com/"
#define SinaKEY                             @"2050967975"
#define SinaSECRET                          @"f3b06340bec486644312471aceca13ff"
#define SinaURL                             @"http://www.marcosky.com/"
#define QQKEY                               @"1105127164"   // QQ41DEE6FC
#define QQSECRET                            @"zIER9O7cPfU1uLJp"
#define WeiXinKEY                           @"wxd9478483d41218aa"
#define WeiXinSECRET                        @"6225f57f0d168128ad048bdf301a4e23"
#define TwitterKEY                          @"9qFEw7hbVzu200BzXOqBls6fx"
#define TwitterSECRET                       @"NfCI3SfDLkPUJBpDIVJ4TQDRvr8QrhNakZ3V6zzc2U73KoetdF"
#define FacebookKEY                         @"221635741510569"
#define FacebookSECRET                      @"8d3f1a5ee5b10040ea24003f348ec23c"
#define BaiduPushKEY                        @"tRv2ZkN7vsiu63SeYtmsbVCu"
#define BaiduPushSECRET                     @"PLqkpWDpArdxBkbY1nlQOReBjVb8Ueeu"
#define BugTagsAppKey                       @"2bb59ae5f1332a012d7fb3be7291f944"
#define BugTagsSecret                       @"f1ecdfefda11231d4167494df99eea9a"
#define JSPatchKey                          @"189f125cf166e112"                     // 1.4版本
#define UMengKey                            @"573c3adf67e58e1bcb0005b3"
#define JPushKEY                            @"0e222b921c8f567e8ba80c18"   //
#define JPushSECRET                         @"9fc097d8b95a41572bfa27fa"   //


#endif







#endif
