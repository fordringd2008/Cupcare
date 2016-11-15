//
//  vcBase.m
//  ListedDemo
//
//  Created by 丁付德 on 15/6/22.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

#define NavRightButtonFrame                         CGRectMake(0, 0, 30, 30)

@interface vcBase () <BLEManagerDelegate, aLiNetDelegate>
{
    CGFloat             fontSize;
    NSDate *            lastBeginLinkDate;
    NSTimer *           timerAutoLink;                   // 连接循环器
    NSDate *            lastDateInAll;                   // 最后更新时间
    NSInteger           todayWaterConutLast;             // 上次刷新界面时 今日的喝水总量
}

@end

@implementation vcBase

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isPop = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.Bluetooth = [BLEManager sharedManager];
    self.Bluetooth.delegate = self;                                     // 这里改动， 可能影响很多
    self.Bluetooth.isFailToConnectAgain = YES;
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.windowView = self.appDelegate.window;
    self.userInfo = myUserInfo;
    
    
    if (!self.alinet) {
        self.alinet = [[aLiNet alloc] init];
        self.alinet.delegate = self;
    }
    
    //  http://bbs.yusian.com/thread-10352-1-1.html
    if (SystemVersion >=8.0) self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.navigationController.navigationBar.translucent = NO;           // 不透明
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:DidConnectColor];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.Bluetooth.delegate = self;
    self.userInfo = myUserInfo;
    
    __block vcBase *blockSelf = self;
    timerAutoLink = [NSTimer DF_sheduledTimerWithTimeInterval:1 block:^{
        if (!blockSelf.Bluetooth.isLink && blockSelf.userInfo.pUUIDString
            && [GetUserDefault(isNotRealNewBLE) boolValue] && blockSelf.Bluetooth.isOn)// 防止用户推出登录后仍会连接
        {
            NextWaitInGlobal(
                 [blockSelf.Bluetooth retrievePeripheral:blockSelf.userInfo.pUUIDString];);
        }
    } repeats:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    if (timerAutoLink) {
        [timerAutoLink DF_stop];
        timerAutoLink = nil;
    }
    [super viewDidDisappear:animated];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self toolCancelBtnClick];
}

-(void)setNavTitle:(UIViewController *)vc title:(NSString *)title
{
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lblTitle.text = kString(title);
    //Border(lblTitle, DRed);
    //lblTitle.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:20];
    lblTitle.font = [UIFont systemFontOfSize:20];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.textColor = [UIColor whiteColor];
    vc.navigationItem.titleView = lblTitle;
}


-(void)resetBLEDelegate
{
    self.Bluetooth.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
{
    NSString *img = imgName ? imgName : @"back";
    if (!text && imgName)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 20, 20);
        [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else if(!imgName && text)
    {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 22)]; // 150
//        Border(btn, DRed);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleLabel.font = [UIFont systemFontOfSize:15];
        btn.titleLabel.textColor = DWhite;
        
        if([img isEqualToString:@"back"])
        {
            [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
            [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
        }
        
        [btn setTitle:kString(text) forState: UIControlStateNormal];
        [btn setImageEdgeInsets: UIEdgeInsetsMake(0, -5, 0, 0)];
        [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];   // 防止字太多， 无法显示
        [btn setTitleColor:DWhite forState:UIControlStateNormal];
        [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    else
    {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
    }
}

-(void)back
{
    if (self.isPop) [self.navigationController popViewControllerAnimated:YES];
    else
    {
        YRSideViewController *sideViewController = [self.appDelegate sideViewController];
        [sideViewController showLeftViewController:true];
    }
}


-(void)initRightButton:(NSString *)imgName text:(NSString *)text
{
    if (imgName || text)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 22, 22);
        [button addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
        if (imgName)
            [button setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        else if (text)
        {
            if ([text isEqualToString:@"相册"]) {
                button.frame = CGRectMake(0, 0, 80, 22);
                if([DFD getLanguage] == 1){
                    button.titleEdgeInsets = UIEdgeInsetsMake(0, 30 , 0, 0);
                }else{
                    button.titleEdgeInsets = UIEdgeInsetsMake(0, 20 , 0, -10);
                }
            }else if([text isEqualToString:@"全球排行榜"]) {
                button.frame = CGRectMake(0, 0, 100, 22);
                
                if([DFD getLanguage] == 1){
                    button.titleEdgeInsets = UIEdgeInsetsMake(0, 15 , 0, -15);
                }else{
                    button.titleEdgeInsets = UIEdgeInsetsMake(0, 10 , 0, -10);
                }
            }
            
            [button setTitle:kString(text) forState:UIControlStateNormal];
            [button setTitleColor:DWhite forState:UIControlStateNormal];
            [button setBackgroundColor:DClear];
            [button.titleLabel setFont:[UIFont systemFontOfSize:16]];
        }
        
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
        self.navigationItem.rightBarButtonItem = item;
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UILabel alloc] init]];
    }
}

-(void)rightButtonClick
{
    // 用来重写
}

-(void)clearLocalData
{
    [DFD returnUserNil];
    self.Bluetooth.isFailToConnectAgain = NO;
    SetUserDefault(isNotRealNewBLE, @0);
    [self.Bluetooth stopLink:nil];
    NSDictionary *dicData = @{};
    SetUserDefault(userInfoData, dicData);
    self.userInfo = nil;
}


-(void)gotoMainStoryBoard
{
    SetUserDefault(isNotRealNewBLE, @1);
    [timerAutoLink DF_stop];
    timerAutoLink = nil;
    [self bindJPush:YES];
    self.appDelegate.customTb.selectedIndex = 0;
    [self changeRootViewController:self.appDelegate.sideViewController];
}


-(void)gotoLoginStoryBoard:(NSString *)storyName
{
    SetUserDefault(isNotRealNewBLE, @0);
    SetUserDefault(ExitUserOnce, @0);
    [timerAutoLink DF_stop];
    timerAutoLink = nil;
    [self bindJPush:NO];             // 退出登录的时候， 要接触绑定

    if (storyName)
    {
        UIStoryboard *login = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        vcBase *vc = [login instantiateViewControllerWithIdentifier:storyName];
        [self.appDelegate.loginNavigationController pushViewController:vc animated:NO];
    }
    [self changeRootViewController:self.appDelegate.loginNavigationController];
}

-(void)changeRootViewController:(UIViewController *)vc
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    self.windowView.rootViewController = vc;
    [self.windowView.layer addAnimation:transition forKey:@"animation"];
    [self.windowView makeKeyAndVisible];
}

-(void)setSideslip:(BOOL)isSlip
{
    self.appDelegate.sideViewController.needSwipeShowMenu = isSlip;
}

// BLEManagerDelegate
-(void)Found_CBPeripherals:(NSMutableDictionary *)recivedTxt
{
    NSMutableString *str = [NSMutableString string];
    for (NSString *key in recivedTxt.allKeys)
    {
        [str appendString:@"UUID:"];
        [str appendString:key];
        [str appendString:@"  name:"];
        [str appendString: ((CBPeripheral *)recivedTxt[key]).name];
        [str appendString:@"   "];
    }
    //NSLog(@"%@", str);
    
    self.dicBLEFound = recivedTxt;
    [self Found_Next:recivedTxt];
}

-(void)CallBack_ConnetedPeripheral:(NSString *)uuidString
{
    NSLog(@"已经连接 ---%@", uuidString);
    if (self.isFirstLink)
    {
        __block vcBase *blockSelf = self;
        NextWaitInMain(
           blockSelf.isFirstLink = NO;
           blockSelf.userInfo.pUUIDString = uuidString;
           blockSelf.userInfo.pName = ((CBPeripheral *)blockSelf.dicBLEFound[uuidString]).name;
           DBSave;
           MBHide
           LMBShowInBlock(@"绑定成功, 开始同步");
        );
    }
    NSLog(@"----- > 同步开始 时间: %@", DNow);
    [self.Bluetooth begin:uuidString];
    self.isLink = YES;
}



-(void)CallBack_DisconnetedPerpheral:(NSString *)uuidString
{
    self.isLink = NO;
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    if(!self.userInfo.access)
        return;
    switch (type) {
        case 210:                   // 闹钟读取完毕后的回调 // 检查是否好友一次性闹钟 并设置本地通知  // TODO  这里 因为误差太久 舍弃
            break;
        case 206:                   // 大数据读取完毕了    // 读取完相信数据后的回调
        {
            // 判断是否有最新数据，  如果有， 上传  ，没有不上传
            lastDateInAll = (NSDate *)obj;
            NSArray *arrDataRecord = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
            
            self.isReadBLEBack = YES;
            
            if (!arrDataRecord.count)
            {
                self.isReadBLEChange = NO;
                NSLog(@"没有需要上传的数据");
                obj = @YES;
                
                [DFD setLastSysDateTime:lastDateInAll access:self.userInfo.access];                      // 设置最后的更新时间
            }
            else
            {
                DataRecord *dr = arrDataRecord[0];
                NSLog(@"没上传的 %@-%@-%@， watercount : %@",dr.year, dr.month, dr.day, dr.waterCount);
                if ([dr.waterCount integerValue] != todayWaterConutLast) {
                    self.isReadBLEChange = YES;
                    todayWaterConutLast = [dr.waterCount integerValue];
                }else
                {
                    self.isReadBLEChange = NO;
                }
                NSMutableArray *arrSub = [NSMutableArray new];
                NSMutableDictionary *dicSub;
                
                for (DataRecord *dr in arrDataRecord)
                {
                    dicSub = [NSMutableDictionary new];
                    [dicSub setObject:dr.dateValue forKey:@"k_date"];
                    [dicSub setObject:dr.time_array forKey:@"time_array"];
                    [dicSub setObject:dr.water_array forKey:@"water_array"];
                    [dicSub setObject:dr.cout forKey:@"counts"];
                    [arrSub addObject:[dicSub mutableCopy]];
                }
                
                NSString *drink_data_jsonString = [DFD toJsonStringForUpload:arrSub];
                
                /*
                 k_date	int	今天的设备日期，例：5725
                 drink_num	int	今天的喝水量
                 month_k_date	int	当月的1号设备日期
                 month_drink_num	int	当月的喝水量
                 */
                
                //[DFD HmF2KNSDateToInt:DNow]
                
                int kDateToday = [DFD HmF2KNSDateToInt:DNow];
                int todayWaterCount = 0;
                
                DataRecord *drToday = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", self.userInfo.access, @(kDateToday)] inContext:DBefaultContext];
                if (drToday) todayWaterCount = [drToday.waterCount intValue];
                
                int kDate1 = [DFD HmF2KNSDateToInt:[DFD getDateFromArr:@[@([DFD getFromDate:DNow type:1]), @([DFD getFromDate:DNow type:2]), @1]]];
                
                int waterCountAllMonth = 0;
                NSArray *arrDr = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue >= %d and dateValue <= %d", self.userInfo.access, kDate1, kDateToday] inContext:DBefaultContext];
                for (DataRecord *drTag in arrDr) {
                    waterCountAllMonth += [drTag.waterCount intValue];
                }
                
                NSDictionary *dic_drink_num = @{@"k_date":@(kDateToday),
                                                @"drink_num":@(todayWaterCount),
                                                @"month_k_date":@(kDate1),
                                                @"month_drink_num":@(waterCountAllMonth)};
                NSString *drink_num_jsonString = [DFD toJsonStringForUpload:dic_drink_num];
                
                __block vcBase *blockSelf = self;
                RequestCheckBefore(
                       [net updateDrinkData:self.userInfo.access
                                 drink_data:drink_data_jsonString
                                  drink_num:drink_num_jsonString];,
                       [blockSelf dataSuccessBack_updateDrinkData:dic];,
                       blockSelf.isReadBLEChange = NO;,NO)
            }
        }
            break;
        case 204:                   // 记录读取完毕    // 这里 在硬件修复后再修改 TODO
        {
            NSArray *arr = (NSArray *)obj;
            NSArray *arr_1 = arr[0];
            NSInteger indSub = [arr[1] integerValue];
            CGFloat water = [arr_1[3][indSub] doubleValue];
            //CGFloat target = [arr_1[4][indSub] doubleValue];
            NSInteger percent = water / [self.userInfo.user_drink_target doubleValue] * 100;
            
            if(self.userInfo.access)
            {
                NSDictionary *dic = @{ self.userInfo.access : @[ @(water), @(percent), @(DDDay)]};   //  这里 0
                SetUserDefault(IndexData, dic);
            }
            
        }
            break;
        case 2044:                  // 刷新今天的喝水总量和比例  // 这里已经读取完毕了  有更新的回调
        {
            NSArray *arr = (NSArray *)obj;
//            NSArray *arr_1 = arr[0];
//            NSInteger indSub = [arr[1] integerValue];
            NSInteger newWaterCount = [arr[2] integerValue];
            if (newWaterCount > 2000) return;
            NSInteger percent = newWaterCount / [self.userInfo.user_drink_target doubleValue] * 100;
            if(self.userInfo.access)
            {
                NSDictionary *dic = @{ self.userInfo.access : @[ @(newWaterCount), @(percent), @(DDDay) ]};
                SetUserDefault(IndexData, dic);
            }
        }
            break;
        case 250:  // 设置 灯光 声音 的回调
        {
            __block vcBase *blockSelf = self;
            NextWaitInMain(
                   UserInfo *us = [UserInfo findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:DBefaultContext];
                   NSArray *arr = (NSArray *)obj;
                   NSLog(@"  %@,  %@", arr[0], arr[1]);
                   blockSelf.userInfo.swithLight = us.swithLight = arr[0];
                   blockSelf.userInfo.swithSound = us.swithSound = arr[1];
                   
                   DBSave;
                           );
        }
            break;
        default:
            break;
    }
    //[self CallBack_Data_Next:type uuidString:uuidString obj:obj];
}


// 发现回调后的 接下来操作，
-(void)Found_Next:(NSMutableDictionary *)recivedTxt
{
//    if(self.Bluetooth.dicConnected.count == 0)
//        [self.Bluetooth retrievePeripheral:self.userInfo.pUUIDString];
}

// 连接上后 接下来操作，
-(void)Conneted_Next:(NSString *)uuidString
{
    NSLog(@"连接上后 接下来操作，");
}

-(void)CallBack_Data_Next:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    NSLog(@"回调回来的 接下来操作，");
}


-(void)getTokenAndUpload                                            // 先获取权限， 然后上传
{
    self.isUpdataPhoto = NO;
    __block vcBase *blockSelf = self;
    RequestCheckBefore(
           [net getToken_distribute_server:blockSelf.userInfo.access];,
           [blockSelf dataSuccessBack_getToken:dic];,
           blockSelf.image = nil;,YES)
}


#pragma mark aLiNetDelegate
-(void)upload:(BOOL)isOver url:(NSString *)url
{
    NSLog(@"上传结果： %@ url :%@", @(isOver), url);
    if (isOver) {
        self.image = nil;
        self.isUpdataPhoto = YES;
        if (self.upLoad_Next) {
            self.upLoad_Next(isOver ? url : @"");
        }else{
            NSLog(@"这里出错了");
        }
    }
}


// 1是关闭  2是修改星期 3 新增时间段
// 1:      2:YES/NO  3, YES/NO
// 2:      2:无所谓   3, 工作日的字符串 11111000 8位
// 3:      2:YES/NO  3, [1] 说明是添加   [2]说明是修改  修改的时候， [0]新  [1]旧
-(void)setWaterRemind:(int)type isWork:(BOOL)isWork obj:(id)obj       // 设置 喝水提醒
{
    NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
    if (!dicremindWater) dicremindWater = [[NSDictionary alloc] init];
    NSArray *arrData;
    if (dicremindWater && [dicremindWater.allKeys containsObject:self.userInfo.pUUIDString])
        arrData = dicremindWater[self.userInfo.pUUIDString];
    if (!arrData)
    {
        NSLog(@"这里报错了，  为空");
    }
    else
    {
        NSMutableArray *workArray = [arrData[0] mutableCopy];              // 0:NSString  后面的 全部是字典
        NSMutableArray *restArray = [arrData[1] mutableCopy];
        
        NSString *strRepeatWork = [workArray[0] mutableCopy];                       // 101110101
        NSString *strRepeatRest = [restArray[0] mutableCopy];
        if (type == 1)                  // 开关
        {
            BOOL isOn = [obj boolValue];
            if (isWork)
                strRepeatWork = [strRepeatWork stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:isOn ? @"1" : @"0"];
            else
                strRepeatRest = [strRepeatRest stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:isOn ? @"1" : @"0"];
            
            [workArray replaceObjectAtIndex:0 withObject:strRepeatWork];
            [restArray replaceObjectAtIndex:0 withObject:strRepeatRest];
        }
        else if (type == 2)             // 修改工作日
        {
            NSString *str = (NSString *)obj;
            strRepeatWork = [str mutableCopy];
            strRepeatRest = [str stringByReplacingOccurrencesOfString:@"1" withString:@"3"];
            strRepeatRest = [strRepeatRest stringByReplacingOccurrencesOfString:@"0" withString:@"1"];
            strRepeatRest = [strRepeatRest stringByReplacingOccurrencesOfString:@"3" withString:@"0"];
            strRepeatWork = [strRepeatWork stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
            strRepeatRest = [strRepeatRest stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"0"];
            
            [workArray replaceObjectAtIndex:0 withObject:strRepeatWork];
            [restArray replaceObjectAtIndex:0 withObject:strRepeatRest];
        }
        else if (type == 3)             // 添加/修改 提醒时间段
        {
            NSArray *arr = (NSArray *)obj;
            NSDictionary *dicNew = (NSDictionary *)(((NSArray *)obj)[0]);
            NSDictionary *dicOld = arr.count > 1 ? (NSDictionary *)(((NSArray *)obj)[1]) : @{ @(24*60): @(24*60) };
            
            NSArray *arrTag = isWork ? workArray : restArray;
            int indexSub = 0;
            for (int i = 1; i < arrTag.count; i++)
            {
                NSDictionary *dicTag = arrTag[i];
                if ([dicTag.allKeys[0] integerValue] == [dicOld.allKeys[0] integerValue]) {
                    indexSub = i;
                    break;
                }
            }
            [(isWork ? workArray : restArray) replaceObjectAtIndex:indexSub withObject:dicNew];
        }
        
        workArray = [DFD sort:workArray];
        restArray = [DFD sort:restArray];
        arrData = @[ workArray, restArray ];
        
        NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dicremindWater];
        [newDic setObject:arrData forKey:self.userInfo.pUUIDString];
        SetUserDefault(dicRemindWater, [DFD dicToData:newDic]);
    }
}



-(void)dataSuccessBack_updateDrinkData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        [DFD setLastUpLoadDateTime:lastDateInAll access:self.userInfo.access]; // 设置最后的上传时间
        NSArray *arrDataRecord = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == %@", self.userInfo.access, @(NO)] inContext:DBefaultContext];
        for (int i = 0; i < arrDataRecord.count; i++)
        {
            DataRecord *dr = arrDataRecord[i];
            dr.isUpload = @YES;
        }
        self.isReadBLEChange = NO;
        DBSave;
    }
    else
    {
        NSLog(@"上传异常");
    }
}

-(void)dataSuccessBack_getToken:(NSDictionary *)dic
{
    [self.alinet initAndupload:self.image dic:dic];
}

-(void)bindJPush:(BOOL)isBind
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ((delegate.isBind && !isBind) || (!delegate.isBind && isBind))
    {
        NSLog(@"------ > 去极光操作 : %@", @(isBind));
        [delegate repeatBind:isBind];
    }
}

// 这里需要  加上延迟，  全局的延迟，  第一次 60s  第二次 80s  第三次 100  今天的以后都是 100 第二天重新 60 80 100
// 成功发送一次短信后，设置
-(void)setSMSInterval
{
    NSArray *arrSMS = GetUserDefault(dateLastPostSMS); // 1266
    int date = [DFD HmF2KNSDateToInt:DNow];
    int dateValue = 0;
    
    if ([arrSMS[0] intValue] == date)
    {
        dateValue = [arrSMS[2] intValue];
    }
    
    dateValue++;
    dateValue = dateValue > 3 ? 3 : dateValue;
    SetUserDefault(dateLastPostSMS, (@[@(date),DNow,@(dateValue)]));
}

// 返回当前的倒计时总秒数
-(int)getSMSInterval
{
    NSArray *arrSMS = GetUserDefault(dateLastPostSMS);
    int inter = (int)[(NSDate *)arrSMS[1] timeIntervalSinceNow] + 60 + ([arrSMS[2] intValue] - 1) * 20;
    return  inter;
}

-(void)changeNavigationBar:(UIColor *)color        // 改变导航条的颜色
{
    LSNavigationController *lnav = (LSNavigationController *)self.navigationController;
    [lnav.navigationBar setBackgroundImage:[UIImage imageFromColor:color] forBarMetrics:UIBarMetricsDefault];
    lnav.navigationBar.shadowImage = [UIImage imageFromColor:color];
    [lnav refreshBackgroundImage];
}


-(void)initViewCover:(CGFloat)toolViewHeight
{
    self.ViewCover = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    self.ViewCover.backgroundColor = DClear;
    
    if(SystemVersion >= 8)
    {
        self.ViewEffectBody = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        self.ViewEffectBody.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.ViewEffectBody.alpha = 0;
        [self.view addSubview:self.ViewEffectBody];
                
        self.ViewEffectHead = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
        self.ViewEffectHead.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        self.ViewEffectHead.alpha = 0;
        [self.windowView addSubview:self.ViewEffectHead];
    }
    
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.ViewCover.bounds.size.height - toolViewHeight, ScreenWidth, 44)];
    toolBarView.backgroundColor = DidConnectColor;
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(toolCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.frame = CGRectMake(10, 0, 80, 44);
    [toolBarView addSubview:CancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
    [confirmButton addTarget:self action:@selector(toolOKBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:confirmButton];
    [self.ViewCover addSubview:toolBarView];
    
    [self.view addSubview:self.ViewCover];
}

// 显示覆盖图层
-(void)showViewCover
{
    [UIView animateWithDuration:0.5 animations:^{
        [self.ViewCover setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
        self.ViewEffectBody.alpha = self.ViewEffectHead.alpha = 0.8;
    } completion:^(BOOL finished) {}];
}

-(void)toolCancelBtnClick
{
    [self toolCancelBtnClickAnimation];
    [UIView animateWithDuration:0.5 animations:^{
        if (self.ViewCover) {
            [self.ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
            self.ViewEffectBody.alpha = self.ViewEffectHead.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [self toolCancelBtnClickCompleted];
    }];
}

-(void)toolOKBtnClick
{
    [self toolOKBtnClickAnimation];
    [UIView animateWithDuration:0.5 animations:^{
        [self.ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
        self.ViewEffectBody.alpha = self.ViewEffectHead.alpha = 0;
    } completion:^(BOOL finished) {
        [self toolOKBtnClickCompleted];
        [self toolCancelBtnClickCompleted];
    }];
}


-(void)toolCancelBtnClickAnimation{}                 // 点击取消按钮后的操作，用于重写  和动画同步操作
-(void)toolOKBtnClickAnimation{}                     // 点击确定按钮后的操作，用于重写  和动画同步操作
-(void)toolCancelBtnClickCompleted{}                 // 点击取消按钮后的操作，用于重写  动画结束后
-(void)toolOKBtnClickCompleted{}                     // 点击确定按钮后的操作，用于重写  动画结束后


@end
