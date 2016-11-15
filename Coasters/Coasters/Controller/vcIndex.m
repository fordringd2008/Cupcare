//
//  vcIndex.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcIndex.h"
#import "vcLeft.h"
#import <QuartzCore/QuartzCore.h>
#import "CCProgressView.h"
#import <CoreMotion/CoreMotion.h>
#import "tvcIndex.h"
#import "MdIndex.h"
#import "NSString+ToString.h"
#import "NSMutableArray+Sort.h"
#import "IOPowerSources.h"  //  随陀螺仪 波动
#import "IOPSKeys.h"
#import "SkyWaitingView.h"
#import "vcSearch.h"
#import "DFToAppStore.h"

#define EPSILON                                     1e-6
#define kDuration                                   0.35   // 动画持续时间(秒)
#define tableViewHeight                             Bigger(RealHeight(100), 50)

#define circleDefaultFrame                          CGRectMake((ScreenWidth  - RealWidth(280)) / 2, 0, RealWidth(280), RealWidth(280))
#define circleDefaultCenter                         CGPointMake(self.viewHeadCircleChart.center.x, self.viewHeadCircleChart.center.y * lblPromptHeightRadio)


#define bg_waterColor_connected                     RGB(56, 145, 210)
#define bg_waterColor_disconnected                  RGB(132, 146, 155)
void *vcIndexObserver = &vcIndexObserver;

const NSInteger segmentMiniTopInsetValue = 64;
const CGFloat lblPromptHeightRadio       = 0.75;

@interface vcIndex ()<vcLeftDelegate, UITableViewDelegate, UITableViewDataSource, tvcIndexDelegate, UIAlertViewDelegate>
{
    CGAffineTransform       currentTransform;
    CGAffineTransform       newTransform;
    double                  r;
    CGFloat                 water;                       // 今日的喝水量
    NSTimer *               timerM;                      // 循环读取硬件数据
    NSTimer *               timerU;                      // 循环读取ChanelID 和 推送数据
    MdIndex *               mmd;                         // 当前操作对象
    BOOL                    isGetApply;                  // 是否已经拉去了好友申请
    BOOL                    isLeft_index;                // 是否离开
    MdIndex *               lastMd;                      // 上一次的数据源的第一个模型  用于高亮
    BOOL                    isTableFirstLineHightLight;  // 第一条是否高亮
    BOOL                    isAcceptTap;                 // 允许firstView 触发事件
    BOOL                    isFirstLoad;                 // 是否是第一次显示
    CCProgressView *        circleChart;                 // 水波纹
    UIView *                viewMask;                    // 遮罩
    BOOL                    isLoadOK;                    // 是否初始化界面， 网络，数据完成， 防止过急跳转崩溃
    BOOL                    isWaterChange;               // 饮水量是否有变化  用于刷新列表
    
    UILabel *               _lblNumber;                  // 图标中间的字
    UILabel *               _lblRemind;                  // 今日的喝水总量
    NSInteger               countInTab;                  // tableView的总行数
    
    CADisplayLink*          _motionDisplayLink;
    BOOL                    isCheckNoData;               // 今天没有喝水数据
    NSTimer *               timerAutoLink;               // 连接循环器
    NSDate *                lastReloadDate;              // 上次刷新的时间
    CGFloat                 lastPercent;                 // 上一次的得分
    CGFloat                 alpha;                       // 当前的透明度
}


@property (nonatomic, strong) CMMotionManager*              motionManager;
@property (assign, nonatomic) CGFloat                       percent;        // 0 - 100 当前的百分比
@property (nonatomic, strong) NSTimer *                     theTimer;
@property (nonatomic, assign) float                         motionLastYaw;
@property (nonatomic, strong) UILabel *                     lblNumber;      // 图标中间的字
@property (nonatomic, strong) UILabel *                     lblRemind;      // 今日的喝水总量
@property (nonatomic, strong) NSMutableArray *              arrData;        // 数据源

@property (strong, nonatomic) SkyLabelWaitingView *          lv;            // 大菊花


@property (nonatomic, strong) UIView<ARSegmentPageControllerHeaderProtocol>  *viewHeadCircleChart; //   头部视图
@property (nonatomic, strong) UITableViewController<ARSegmentControllerDelegate> * table;          //   tabaleView控制器


@property (nonatomic, assign) BOOL                          isSearchTag;   // 搜索界面成功连接的的标记

@end

@implementation vcIndex

-(instancetype)init
{
    self.table = (UITableViewController<ARSegmentControllerDelegate> *)[[UITableViewController alloc] init];
    self.table.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.table.tableView.delegate = self;
    self.table.tableView.dataSource = self;
    self.table.tableView.showsVerticalScrollIndicator = NO;
    self = [super initWithControllers:self.table, nil];
    if (self) {
        self.segmentMiniTopInset = segmentMiniTopInsetValue;
    }
    [self setVcLeftDelegate];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNavTitle:self title:@"今日"];
    self.isPop = NO;
    self.navigationController.navigationBarHidden = NO;
    
    [self initLeftButton:@"menu" text:nil];
    [self initRightButton:@"cupcare-Data" text:nil];
    
    isLeft_index = NO;
    isFirstLoad = YES;
    self.isLink = self.Bluetooth.isLink;
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isLeft_index = NO;
    isLoadOK = NO;
    isFirstLoad = YES;
    
    if (self.Bluetooth.isLink && self.userInfo.pUUIDString && !self.isSearchTag){
        [self resetColor:YES];
    }else{
        [self resetColor:NO];
    }
    
    if (![GetUserDefault(IsLogined) boolValue])
    {
        __block vcIndex *blockSelf = self;
        NextWaitInMainAfter([blockSelf nextLogin];, 1);
    }
    else [self getPushInfoList];


    [self addTarget];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!self.userInfo.pUUIDString)
        {
            water = 0;
            if (self.percent != 0) self.percent = 0;
            [self refreshNumber];
        }
        SetUserDefault(IndexTabelReload, @YES);
        [self refreshData];
        [self refreshView];
        [self readIndexData];
        [DFD setIconNumber:0];
    });
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self checkUserInfo];
    
    if (self.Bluetooth.isLink && self.userInfo.pUUIDString){
        [self resetColor:YES];
    }else{
        [self resetColor:NO];
    }
    self.isSearchTag = NO;
    
    if([GetUserDefault(TipsIn) boolValue] && self.appDelegate.tips)// 检验 是否是 点击通知栏 进入的
    {
        //[self JumpToOtherView:@"Main" storyboardID:@"vcTipsDetails"];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [story instantiateViewControllerWithIdentifier:@"vcTipsDetails"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        __block vcIndex *blockSelf = self;
        timerM = [NSTimer DF_sheduledTimerWithTimeInterval:5 block:^{
            if ([blockSelf.Bluetooth.dicConnected.allKeys containsObject:blockSelf.userInfo.pUUIDString] && blockSelf.userInfo.pUUIDString && !blockSelf->isLeft_index && !blockSelf.Bluetooth.isLock)
            {
                [blockSelf.Bluetooth readToday:blockSelf.userInfo.pUUIDString];
                if(!blockSelf->isLeft_index || blockSelf.isReadBLEChange)
                {
                    NextWaitInMainAfter([blockSelf refreshWait];, 1);
                }
            }
        } repeats:YES];
        
        timerU = [NSTimer DF_sheduledTimerWithTimeInterval:1 block:^{
            if([GetUserDefault(NewPushData) boolValue])
            {
                [blockSelf getPushInfoList];
                SetUserDefault(NewPushData, @NO);
            }
        } repeats:YES];
    }
    
//    static dispatch_once_t onceTokenUpdateVersion;
//    dispatch_once(&onceTokenUpdateVersion, ^
//    {
//        [[[DFToAppStore alloc] initWithAppID:APPID] updateGotoAppStore:self];
//    });
//    
    
    NextWaitOnce(
                     [[[DFToAppStore alloc] initWithAppID:APPID] updateGotoAppStore:self];
                 );
    
    if (![GetUserDefault(ExitUserOnce) boolValue] && self.userInfo.access)
    {
        __block vcIndex *blockSelf = self;
        NextWaitInGlobal(
                         RequestCheckNoWaring(
                                              [net getFriendApplyList:blockSelf.userInfo.access];,
                                              [blockSelf dataSuccessBack_getFriendApplyList:dic];);
                         RequestCheckNoWaring(
                                              [net getGroupApplyList:blockSelf.userInfo.access];,
                                              [blockSelf dataSuccessBack_getGroupApplyList:dic];);
                         );
    }
    
    if (!viewMask) {
        viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [self.view addSubview:viewMask];
        __block vcIndex *blockSelf = self;
        NextWaitInMainAfter([blockSelf removeViewMask];, 0.5);
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [timerM DF_stop];
    timerM = nil;
    [timerU DF_stop];
    timerU = nil;
    [self releaseCCP];
    _motionManager = nil;
    
    isLeft_index = YES;
    lastPercent = 0;    // 离开后，清空，为了下一次，防止水波纹不显示
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.Bluetooth name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    
    @try
    {
        [self.Bluetooth removeObserver:self forKeyPath:@"isBeginOK"];
        [self.Bluetooth removeObserver:self forKeyPath:@"isBeginOver"];
    }@catch(id anException){}
    
    
    [self stopGravity];
    currentTransform = circleChart.transform = CGAffineTransformMakeRotation(0);
    [super viewWillDisappear:animated];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

-(void)checkUserInfo
{
    if ([self.userInfo.isNeedUpdate boolValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kString(@"提示") message:kString(@"去完善个人资料?") delegate:self cancelButtonTitle:kString(@"使用默认") otherButtonTitles:kString(@"去完善"), nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void)back
{
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;               // 防止导航条出错
    if (isLoadOK)
    {
        YRSideViewController *sideViewController = [self.appDelegate sideViewController];
        [sideViewController showLeftViewController:true];
    }
}

-(void)rightButtonClick
{
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;
    if(isLoadOK && !isLeft_index)
    {
        isLeft_index = YES;
        [self performSegueWithIdentifier:@"index_to_chart" sender:nil];
    }
}

-(void)removeViewMask
{
    [viewMask removeFromSuperview];
    viewMask = nil;
    isLoadOK = YES;
}

-(void)getPushInfoList
{
    long long interval = (long long)[[DFD getDateFromArr:@[@0,@0,@0,@0]] timeIntervalSince1970] * 1000;
    __block vcIndex *blockSelf = self;
    RequestCheckNoWaring(
          [net getPushInfoList:blockSelf.userInfo.access time:interval];,
          [blockSelf dataSuccessBack_getPushInfoList:dic];);
}

-(void)addTarget
{
    [self.Bluetooth addObserver:self forKeyPath:@"isBeginOK"
                        options:NSKeyValueObservingOptionNew context:nil];
    [self.Bluetooth addObserver:self forKeyPath:@"isBeginOver"
                        options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"segmentToInset"
              options:NSKeyValueObservingOptionNew context:vcIndexObserver];
    [self addObserver:self forKeyPath:@"percent"
              options:NSKeyValueObservingOptionNew context:nil];
}

-(void)dealloc
{
    NSLog(@"vcIndex 被销毁");
}

-(void)readIndexData
{
    if (isLeft_index)return;
    NSDictionary *dic = GetUserDefault(IndexData);
    if ([dic.allKeys containsObject:self.userInfo.access] && self.userInfo.pUUIDString) // 这里是为了解绑后
    {
        NSArray *arr = dic[self.userInfo.access];
        if([arr[2] integerValue] == DDDay)          // 判断是否是今天
        {
            //NSLog(@"water : %f,  %f", water, [arr[0] doubleValue]);
            isWaterChange = water != [arr[0] floatValue];      // 判断是否有变化     //  这里作为一个刷新的判断  ！！！
            //NSLog(@"isWaterChange -------------> %hhd", isWaterChange);
            water = [arr[0] doubleValue];
            [self refreshNumber];
            self.lblRemind.text = kString(@"今日喝水总量");
            if (_percent != [arr[1] doubleValue])
            {
                CGFloat newPercent = water / [self.userInfo.user_drink_target doubleValue] * 100;
                if (newPercent != self.percent) {    // 这里防止频繁刷新 波纹抖动
                    self.percent = newPercent;
                }
            }
        }
        else
        {
            water = 0;
            if (self.percent != 0) self.percent = 0;
        }
        
    }
    else
    {
        water = 0;
        if (self.percent != 0) self.percent = 0;
    }
}

-(void)readBLEData
{
    if ([self.Bluetooth.dicConnected.allKeys containsObject:self.userInfo.pUUIDString] && self.userInfo.pUUIDString && !isLeft_index && !self.Bluetooth.isLock)
    {
        [self.Bluetooth readToday:self.userInfo.pUUIDString];
        __block vcIndex *blockSelf = self;
        if(!isLeft_index || self.isReadBLEChange)
        {
            NextWaitInMainAfter([blockSelf refreshWait];, 1);
        }
    }
}

// 设置代理
-(void)setVcLeftDelegate
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    vcLeft *left = (vcLeft *)delegate.left;
    left.delegate = self;
}

-(void)initData
{
    isAcceptTap = YES;
    _arrData = [NSMutableArray new];
}

-(void)refreshData
{
    lastMd = _arrData.count > 0 ? _arrData[0] : nil;
    NSUInteger lastCount = _arrData.count;   // 纪录上一次的数据总数  用于判断是否有变动 来决定刷新
    [_arrData removeAllObjects];
    
    int year  = DDYear;
    int month = DDMonth;
    int day   = DDDay;
    [_arrData removeAllObjects];
    
//#warning 测试数据
//    for(int i = 0; i < 20; i++)
//    {
//        MdIndex *model = [MdIndex new];
//        model.type = 2;
//        model.msg = kString(@"喝水");
//        model.date = DNow;
//        model.msgML = [NSString stringWithFormat:@"%@ml.", @(100)];
//        [_arrData addObject:model];
//    }

    if (self.userInfo.pUUIDString)  // 在用户绑定的情况下 才显示喝水数据 //  && !self.Bluetooth.isLock
    {
        NSArray *drinkData = [SynData findAllSortedBy:@"date" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@ ", self.userInfo.access,  @(year), @(month), @(day)] inContext:DBefaultContext];
        
        BOOL isInsertHalf = NO;
        BOOL isInsertAll = NO;
        bool isHaveLastFive = NO;
        for (int i = 0; i < drinkData.count; i++)
        {
            SynData *syn = drinkData[i];
            MdIndex *model = [MdIndex new];
            model.type = 2;
            
             // 只判断最后一个
            if (i == drinkData.count - 1 && -[[syn.date clearTimeZone] timeIntervalSinceNow] < 5 * 60 && !isHaveLastFive)
            {
                model.type = 1;
                model.msg = kString(@"最近喝水");
                isHaveLastFive = YES;
            }
            else
            {
                model.msg = kString(@"喝水");
            }
            
            model.date = syn.date;
            model.msgML = [NSString stringWithFormat:@"%@ml.", syn.water];
            [_arrData addObject:model];
            
            
            if (!isInsertAll && [syn.waterCount integerValue] >= [self.userInfo.user_drink_target integerValue])
            {
                MdIndex *model_half = [MdIndex new];
                model_half.type = 4;
                model_half.date = [NSDate dateWithTimeInterval:2 sinceDate:syn.date];
                model_half.msg = kString(@"您已经完成今天喝水目标了.");
                model_half.msgML = @"";
                [_arrData addObject:model_half];
                isInsertAll = YES;
            }
            
            if (!isInsertHalf && [syn.waterCount integerValue] >= [self.userInfo.user_drink_target integerValue] / 2)
            {
                MdIndex *model_half = [MdIndex new];
                model_half.type = 4;
                model_half.date = [NSDate dateWithTimeInterval:1 sinceDate:syn.date];//syn.date ;
                model_half.msg = kString(@"您已经完成今天喝水目标一半了.");
                model_half.msgML = @"";
                [_arrData addObject:model_half];
                isInsertHalf = YES;
            }
        }
        
        if (_arrData.count > 0)
        {
            MdIndex *lastModel = _arrData[_arrData.count - 1];
            CGFloat interval = -[[lastModel.date clearTimeZone] timeIntervalSinceNow];
            NSInteger hour = [[lastModel.date clearTimeZone] getFromDate:4];                        // 在 8点以后
            //NSLog(@"--------------------------hour: %d", hour);
            if (interval > DrinkWarnIntervel && hour >= 10 && hour <= 20)
            {
                MdIndex *model_3 = [MdIndex new];
                model_3.type = 4;
                model_3.date = [DNow getNowDateFromatAnDate];
                NSInteger interHour = (NSInteger)floor(interval);
                interHour = interHour /  ( DrinkWarnIntervel / 2 ) ;
                NSString *str1 = kString(@"您已经");
                NSString *str2 = kString(@"小时没有喝水了.");
                model_3.msg = [NSString stringWithFormat:@"%@%ld%@", str1, (long)interHour, str2];
                model_3.msgML = @"";
                
                [_arrData insertObject:model_3 atIndex:0];
            }
        }
        
        if (!_arrData.count && !self.Bluetooth.isLink) {
            
            MdIndex *md = [MdIndex new];
            md.type = 4;
            md.date = [DNow getNowDateFromatAnDate];
            md.msg = kString(@"杯垫未连接.");
            [_arrData addObject:md];
        }
    }

    NSArray *requestData = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d and day == %d", self.userInfo.access, year, month, day] inContext:DBefaultContext];
    for (int i = 0; i < requestData.count; i++)
    {
        // 这里要把同一个人，同一个个类型的进行过滤  服务器已经过滤了
        FriendRequest *fr = requestData[i];   // 1:申请我  2:接受我  3:提醒我  4:回复提醒喝水
        MdIndex *model = [MdIndex new];       // 5:点赞    6:申请加入圈子   7:已经加入圈子
        model.fr = fr;
        model.uerid = fr.friend_id;
        model.name = fr.friend_name;
        model.isOver = [fr.isOver boolValue];
        switch ([fr.type integerValue])
        {
            case 1:
                model.type = 5;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"申请加您为好友")];
                break;
            case 2:
                model.type = 6;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"已经接受了你的好友申请")];
                break;
            case 3:
                model.type = 3;
                model.msg = fr.friend_msg;
                break;
            case 4:
                model.type = 4;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"已经看到了你的喝水提醒信息")];
                break;
            case 5:
                model.type = 4;
                model.msg = [NSString stringWithFormat:@"%@ %@.", fr.friend_name, kString(@"为您点了个赞")];
                break;
            case 6:
                model.type = 5;
                model.msg = fr.friend_msg;
                break;
            case 7:
                model.type = 4;
                model.msg = fr.friend_msg;
                break;
        }
        
        model.date = [fr.dateTime getNowDateFromatAnDate];
        [_arrData addObject:model];
    }
    
    _arrData = [_arrData startArraySort:@"date" isAscending:NO];
    
    if (_arrData.count > 0)
    {
        MdIndex *nowLast = _arrData[0];
        if(nowLast.type == lastMd.type
           && ([nowLast.msgML isEqualToString:lastMd.msgML] || (!nowLast.msgML && !lastMd.msgML))
           && ([nowLast.date compare:lastMd.date] == NSOrderedSame || nowLast.type == 4 || isWaterChange))
            isTableFirstLineHightLight = NO;
        else
            isTableFirstLineHightLight = YES;
    }
    // 在第二次加载刷新方法之后 检查是否没有数据  解决 当天没有数据的时候一直显示正在加载的问题
    else if(self.userInfo.pUUIDString && GetUserDefault(isSynDataOver))
    {                                  // self.isReadBLEBack &&
        MdIndex *model = [MdIndex new];
        model.type = 4;
        model.msg = kString(@"今天没有喝水哟.");
        model.date = [DNow getNowDateFromatAnDate];
        model.msgML = @"";
        [_arrData addObject:model];
    }
    
    countInTab = _arrData.count + (self.userInfo.pUUIDString ? 0 : 2); // isReadBLEChange
    if(lastCount != _arrData.count || isWaterChange || self.isReadBLEChange || GetUserDefault(IndexTabelReload))
    {
        NSLog(@"刷新界面 时间");
        [self.table.tableView reloadData];
        if (GetUserDefault(IndexTabelReload)) RemoveUserDefault(IndexTabelReload);
        RemoveUserDefault(readBLEBack);
    }
}


-(void)initView
{
    [self refreshCircleChart];
    
    if (_lblNumber)
        [_lblNumber removeFromSuperview];
    _lblNumber = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    _lblNumber.center = circleChart.center;
    _lblNumber.textAlignment = NSTextAlignmentCenter;
    _lblNumber.textColor = DWhite;
    _lblNumber.backgroundColor = DClear;
    [self refreshNumber];
    [self.viewHeadCircleChart addSubview:_lblNumber];
    
    if (self.lblRemind)  [self.lblRemind removeFromSuperview];
    self.lblRemind = [[UILabel alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 200) / 2,
                                                               ScreenHeight * 0.4 * lblPromptHeightRadio,
                                                               200, 30)];
    self.lblRemind.textAlignment = NSTextAlignmentCenter;
    self.lblRemind.textColor = DWhite;
    self.lblRemind.backgroundColor = DClear;
    self.lblRemind.font = [UIFont systemFontOfSize:14];
    self.lblRemind.text = kString(@"今日未更新");
    
    [self.viewHeadCircleChart addSubview:self.lblRemind];
}

-(void)refreshCircleChart
{
    if (!circleChart)
    {
        circleChart = [[CCProgressView alloc] initWithFrame:circleDefaultFrame];
        circleChart.backgroundColor = bg_waterColor_disconnected; // [UIColor clearColor];
        circleChart.center = circleDefaultCenter;
        [self.viewHeadCircleChart addSubview:circleChart];
        r = circleChart.frame.size.height;
        
    }else{
        [circleChart removeFromSuperview];
        circleChart = [[CCProgressView alloc] initWithFrame:circleDefaultFrame];
        circleChart.backgroundColor = [UIColor clearColor];
        circleChart.center = circleDefaultCenter;
        circleChart.isOnly = YES;
        circleChart.backgroundColor = (self.userInfo.pUUIDString && self.Bluetooth.isLink) ? bg_waterColor_connected : bg_waterColor_disconnected;
        [self.viewHeadCircleChart insertSubview:circleChart belowSubview:_lblNumber];
        r = circleChart.frame.size.height;
    }
}

-(void)refreshView
{
    [self batteryLevel];
//    [self addObserver:self forKeyPath:@"percent" options:NSKeyValueObservingOptionNew context:nil];
    
    [self stopGravity];
    [self startGravity];
    currentTransform = circleChart.transform;
}

#pragma mark - override
-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    self.viewHeadCircleChart = (UIView<ARSegmentPageControllerHeaderProtocol> *)[[UIView alloc] init];
    return self.viewHeadCircleChart;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (isLeft_index)return;
    __block vcIndex *blockSelf = self;
    if ([object isEqual:self] && [keyPath isEqual:@"percent"])
    {
        NSLog(@"-- > 分数是 ： %f", self.percent);
        NextWaitInMain(
            [blockSelf batteryLevel];
        );
    }
    else if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isBeginOK"] )
    {
        if(self.Bluetooth.isBeginOK && self.Bluetooth.isLink && self.Bluetooth.isOn && self.userInfo.pUUIDString)
             NextWaitInMain(
                blockSelf.lblNumber.text = kString(@"正在同步");
                [blockSelf resetLv:NO];
                [blockSelf resetColor:YES];);
        else
            NextWaitInMain( [blockSelf resetColor:NO]; );
    }
//    else if([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isLock"] )
//    {
//        NextWaitInMain(blockSelf.lblInSyn.text = blockSelf.Bluetooth.isLock ? kString(@"正在同步中") : @"";);
//    }
    else if([keyPath isEqual:@"contentOffset"] || [keyPath isEqual:@"segmentToInset"] ) //contentOffset
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        if (context == vcIndexObserver)
        {
            CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
            //NSLog(@"inset is %f",inset);
            
            [self.viewHeadCircleChart setFrame:CGRectMake(0, 0, ScreenWidth, inset)];
            circleChart.center = circleDefaultCenter;
            self.lblNumber.center = circleChart.center;
            
            alpha = circleChart.alpha = (inset - segmentMiniTopInsetValue) / (ScreenHeight * 0.4 - segmentMiniTopInsetValue);
            //NSLog(@"inset:%f", inset);
            if (inset > ScreenHeight * 0.4) {
                [self.lblRemind setFrame:CGRectMake((ScreenWidth - 200) / 2, inset * lblPromptHeightRadio, 200, 30)];
            }
            
            if (self.lv) {
                self.lv.center = circleChart.center;
                self.lv.alpha = alpha;
            }
        }
    }
}

// 刷新 菊花
- (void)resetLv:(BOOL)isHidden
{
    if (!self.lv)
    {
        self.lv = [[SkyLabelWaitingView alloc] initWithFrame:CGRectMake((ScreenWidth  - RealWidth(280)) / 2, 0, RealWidth(280), RealWidth(280))];self.lv.ringColor = [UIColor whiteColor];
        self.lv.ringWidth = 2.f;
        self.lv.r = (self.lv.bounds.size.height - self.lv.ringWidth ) / 2 ;
        self.lv.center = circleChart.center;
        [self.viewHeadCircleChart insertSubview:self.lv aboveSubview:circleChart];
    }
    
    if (self.lv.isStartAnimation && !isHidden)
    {
        NSLog(@"hidden : %@, isHidden : %@  ---  太频繁了", @(self.lv.hidden), @(isHidden));
    }
    
    if (!isHidden)
    {
        NSLog(@"----------- > 菊花开始");
        [self.lv start];
        self.lv.hidden = NO;
    }else
    {
        self.lv.hidden = YES;
        NSLog(@"----------- > 菊花结束");
        [self batteryLevel];  // 重置水波纹，防止第一刷新时，条件不满足，而没有生效
        [self.lv stopWithHidRing:YES];
        [self.lv removeFromSuperview];
        self.lv = nil;
    }
}


-(void)resetColor:(BOOL)isBeginOK
{
    if (isLeft_index) return;
    if (isBeginOK)
    {
        [self changeNavigationBar:DidConnectColor];
        self.viewHeadCircleChart.backgroundColor = DidConnectColor;
        circleChart.backgroundColor = bg_waterColor_connected;
        
        
    }
    else
    {
        [self changeNavigationBar:DidDisconnectColor];
        self.viewHeadCircleChart.backgroundColor = DidDisconnectColor;
        circleChart.backgroundColor = bg_waterColor_disconnected;
        [circleChart setProgress:0 animated:NO];
    }
}


- (double) batteryLevel
{
    if (self.Bluetooth.isLink && self.Bluetooth.isOn) {
        if (_percent == lastPercent )
        {
            return _percent;
        }else
        {
            NSLog(@"水波纹设置生效， 原来的分数：%f, 现在的分数：%f", lastPercent, _percent);
            lastPercent = _percent;
            [self refreshCircleChart];
            [circleChart setProgress:_percent / 100.0 animated:YES];
        }
    }else
    {
        [self refreshCircleChart];
        [circleChart setProgress: 0 / 100.0 animated:YES];
    }
    
    circleChart.alpha = alpha;
    return _percent;
}
- (BOOL)isGravityActive
{
    return _motionDisplayLink != nil;
}

- (void)startGravity
{
    if (![self isGravityActive])
    {
        _motionManager = nil;
        _motionManager = [CMMotionManager new];
        _motionManager.deviceMotionUpdateInterval = 0.1;
        
        self.motionLastYaw = 0;
        _theTimer= [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(motionRefresh:) userInfo:nil repeats:YES];
    }
    if ([_motionManager isDeviceMotionAvailable])
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
}
- (void)motionRefresh:(id)sender
{
    CMQuaternion quat = _motionManager.deviceMotion.attitude.quaternion;
    double yaw = asin(2*(quat.x*quat.z - quat.w*quat.y));

    yaw *= -1;
    if (_motionLastYaw == 0) {
        _motionLastYaw = yaw;
    }
    
    //NSLog(@"%.1f", _motionLastYaw);
    
    // kalman filtering
    static float q = 0.1;   // process noise
    static float s = 0.1;   // sensor noise
    static float p = 0.1;   // estimated error
    static float k = 0.5;   // kalman filter gain
    
    float x = _motionLastYaw;
    p = p + q;
    k = p / (p + s);
    x = x + k*(yaw - x);
    p = (1 - k)*p;
    
    newTransform=CGAffineTransformRotate(currentTransform,-x);
    circleChart.transform=newTransform;
    _motionLastYaw = x;
}

- (void)stopGravity
{
    if ([self isGravityActive])
    {
        [self releaseCCP];
    }
    if ([_motionManager isDeviceMotionActive])
        [_motionManager stopDeviceMotionUpdates];
}

-(void)releaseCCP
{
    [_motionDisplayLink invalidate];
    _motionDisplayLink = nil;
    _motionLastYaw = 0;
    [_theTimer invalidate];
    _theTimer = nil;
    _motionManager = nil;
}


#pragma mark - vcLeftDelegate
-(void)selected:(NSInteger)ind
{
    if (isLeft_index) return;
    isLeft_index = YES;
    
    if(isHaveBalance)
    {
        switch (ind)
        {
            case 0:
                [self performSegueWithIdentifier:@"index_to_user" sender:nil];
                break;
            case 1:
                [self performSegueWithIdentifier:@"index_to_friend" sender:nil];
                break;
            case 2:
                [self performSegueWithIdentifier:@"index_to_clock" sender:nil];
                break;
            case 3:
                [self performSegueWithIdentifier:@"index_to_balance" sender:nil];
                break;
            case 4:
                [self performSegueWithIdentifier:@"index_to_tips" sender:nil];
                break;
            case 5:
                [self performSegueWithIdentifier:@"index_to_set" sender:nil];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (ind)
        {
            case 0:
                [self performSegueWithIdentifier:@"index_to_user" sender:nil];
                break;
            case 1:
                [self performSegueWithIdentifier:@"index_to_friend" sender:nil];
                break;
            case 2:
                [self performSegueWithIdentifier:@"index_to_friendCircle" sender:nil];
                break;
            case 3:
                [self performSegueWithIdentifier:@"index_to_clock" sender:nil];
                break;
            case 4:
                [self performSegueWithIdentifier:@"index_to_tips" sender:nil];
                break;
            case 5:
                [self performSegueWithIdentifier:@"index_to_set" sender:nil];
                break;
        }
    }
}

// 刷新中间的喝水量label
-(void)refreshNumber
{
    //NSLog(@"--------------------- 更新label的时间  ");
    NSString *strWater = [NSString stringWithFormat:@"%.0fml", water];
    NSMutableAttributedString *strToString = [strWater toString:strWater
                                                      rangFirst:NSMakeRange(0, strWater.length - 2)
                                                     rangSecond:NSMakeRange(0, 0)
                                                        bigSize:25
                                                     littleSize:14];
    _lblNumber.attributedText = nil;
    _lblNumber.attributedText = strToString;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return countInTab;// ? countInTab : 1;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcIndex *cell = [tvcIndex cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (!self.userInfo.pUUIDString)
    {
        if (indexPath.row == 0)
        {
            cell.title2 = !isGift ? kString(@"欢迎使用 Cupcare"):kString(@"欢迎使用 HealthMate");
            [cell.imvRight setHidden:YES];
        }
        else if(indexPath.row == 1)
        {
            cell.title2 = kString(@"您还未绑定设备,点击绑定");
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        else
        {
            MdIndex *model = _arrData[indexPath.row - 2];
            cell.model = model;
            cell.delegate = self;
            if (!(indexPath.row - 2) && isTableFirstLineHightLight) //  && !isFirstLoad
            {
                if (isFirstLoad)
                    isFirstLoad = NO;
                else
                {
                    [cell hightLight];
                    isTableFirstLineHightLight = NO;
                }
            }
        }
    }
    else
    {
        if (self.arrData.count > indexPath.row) {
            MdIndex *model = _arrData[indexPath.row];
            cell.model = model;
            cell.delegate = self;
            if (!indexPath.row && isTableFirstLineHightLight) //  && !isFirstLoad
            {
                if (isFirstLoad)
                    isFirstLoad = NO;
                else
                {
                    [cell hightLight];
                    isTableFirstLineHightLight = NO;
                }
            }
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(!self.userInfo.pUUIDString && indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"index_to_search" sender:nil];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userInfo.pUUIDString || (!self.userInfo.pUUIDString && _arrData.count))
    {
        if((!self.userInfo.pUUIDString && indexPath.row < 2) || !_arrData.count)  // 正在加载的时候
            return tableViewHeight;
        MdIndex *model= _arrData[indexPath.row - (self.userInfo.pUUIDString ? 0 : 2)];
        if (model.type == 3 || model.type == 4 || model.type == 5|| model.type == 6) // || model.type == 5 || model.type == 6
        {
            NSString *str = [NSString stringWithFormat:@"%@%@", model.msg, model.msgML ? model.msgML : @""];
            CGFloat tag = (model.type == 3 || model.type == 5) ? 160 : 100;
            
            
            
            CGFloat titleHeight = [DFD getTextSizeWith:str fontNumber:14 biggestWidth:(ScreenWidth - tag)].height;
            titleHeight = (titleHeight > 21 ? titleHeight : 21) + (tableViewHeight - 21);
            return titleHeight;
        }
        return tableViewHeight;
    }
    else return tableViewHeight;
}


#pragma mark tvcIndexDelegate
-(void)btnClick:(tvcIndex *)sender
{
    MdIndex *md = sender.model;
    for (int i = 0 ; i < _arrData.count; i++)
    {
        mmd = _arrData[i];
        if (mmd.type == md.type && [mmd.msg isEqualToString:md.msg])
        {
            isWaterChange = YES;  // 让刷新
            mmd.isOver = YES;
            if (mmd.type == 5)          // 接受对方的好友申请  或者接受对方加入群组
            {
                FriendRequest *fr = mmd.fr;
                
                NSLog(@"fr.type : %@", fr.type);
                NSArray *arrFriendRequests = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", fr.access, fr.friend_id, fr.type] inContext:DBefaultContext];
                for (int i = 0; i < arrFriendRequests.count; i++) {
                    fr.isOver = @YES;
                }
                DBSave;
                
                __weak vcIndex *blockSelf = self;
                
                // 失败的回调
                void (^blockFail)() = ^{
                    FriendRequest *friendRequest = [[FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", fr.access, fr.friend_id, fr.type] inContext:DBefaultContext] lastObject];
                    friendRequest.isOver = @NO;
                    DBSave;
                    LMBShowInBlock(NONetTip);
                    [blockSelf refreshData];
                };
                
                
                if ([fr.type intValue] == 6) {
                    RequestCheckBefore(
                                       [timerM DF_pause];
                                       [net allowJoinGroup:blockSelf.userInfo.access
                                              apply_userid:fr.friend_id
                                                  group_id:fr.group_id
                                              allow_status:YES];,
                                       [blockSelf dataSuccessBack_allowJoinGroup:dic];,
                                       blockFail();
                                       ,NO)
                    
                }else{
                    RequestCheckBefore(
                           [timerM DF_pause];
                           [net updateFriendship:blockSelf.userInfo.access
                                       friend_id:mmd.uerid ship_status:@"1"
                                       nick_name:blockSelf.userInfo.user_nick_name];,
                           [blockSelf dataSuccessBack_updateFriendship:dic];,
                           blockFail();
                           ,NO)
                }
            }
            else if (mmd.type == 3)     // 知道了  对方提示喝水知道了
            {
                NSArray *arrFriengRequest = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", mmd.fr.access, mmd.fr.friend_id, @(mmd.type)] inContext:DBefaultContext];
                FriendRequest *fr;
                for (int i = 0; i < arrFriengRequest.count; i++)
                {
                    fr = arrFriengRequest[i];             // 先刷新界面  再 发起请求
                    fr.isOver = @YES;
                }
                
                NSString *content = [NSString stringWithFormat:@"%@%@", self.userInfo.user_nick_name, kString(@"已经看到了你的喝水提示信息")];
                __weak vcIndex *blockSelf = self;
                
                // 失败的回调
                void (^blockFail)() = ^{
                    FriendRequest *friendRequest = [[FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", mmd.fr.access, mmd.fr.friend_id, @(mmd.type)] inContext:DBefaultContext] lastObject];
                    friendRequest.isOver = @NO;
                    DBSave;
                    LMBShowInBlock(NONetTip);
                    [blockSelf refreshData];
                };
                
                
                RequestCheckBefore(
                      [timerM DF_pause];
                      [net pushDrinkHint:blockSelf.userInfo.access
                                    type:@"4"
                               friend_id:fr.friend_id
                                 content:content];,
                       [blockSelf dataSuccessBack_pushDrinkHint:dic];,
                       blockFail();
                                   ,NO)
            }
            else if (mmd.type == 6)     // 知道了   对方接受好友  知道了
            {
                NSArray *arrFriengRequest = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", mmd.fr.access, mmd.fr.friend_id, mmd.fr.type] inContext:DBefaultContext];
                FriendRequest *fr;
                for (int i = 0; i < arrFriengRequest.count; i++)
                {
                    fr = arrFriengRequest[i];             // 先刷新界面  再 发起请求
                    fr.isOver = @YES;
                }
            }
            DBSave;
            [self refreshData];
            break;
        }
    }
}


-(void)dataSuccessBack_getUserToken:(NSDictionary *)dic
{
    if(CheckIsOK && [self.userInfo.token isEqualToString:dic[@"token"]])
    {
        SetUserDefault(IsLogined, @YES);
        if (!isGetApply) [self getPushInfoList];
    }
    else    // 这里 说明 2：账号不存在；3：密码不正确 4 token 发生变化
    {
        NSLog(@"本地的密码不正确，跳转到登录页面  ———— 原始token: %@ 新的token：%@", self.userInfo.token, dic[@"token"]);
        [self clearLocalData];
        [self gotoLoginStoryBoard:nil];
    }
}

-(void)dataSuccessBack_updateFriendship:(NSDictionary *)dic
{
    [timerM DF_continue];
    if (CheckIsOK)
    {
        [self refreshData];
    }
}

-(void)dataSuccessBack_allowJoinGroup:(NSDictionary *)dic
{
    [timerM DF_continue];
    if (CheckIsOK)
    {
        [self refreshData];
    }
}

-(void)dataSuccessBack_getPushInfoList:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        isWaterChange = YES;
        NSArray *arrData_sub = dic[@"push_info_list"];
        if (!arrData_sub) return;
        
        // 删除本地今天的推送信息
        [FriendRequest MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@", self.userInfo.access, @(DDYear), @(DDMonth), @(DDDay)]  inContext:DBefaultContext];
        DBSave;
        for(int i = 0; i < arrData_sub.count; i++)
        {
            NSDictionary *dic_sub = arrData_sub[i];
            NSString *userid = dic_sub[@"friend_id"];
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:[dic_sub[@"time"] longLongValue] / 1000];
            
            FriendRequest *fr;
            int type = [dic_sub[@"type"] intValue];
            
            if (type < 6) // 1:申请我  2:接受我  3:提醒我  4:回复提醒喝水 5: 点赞
            {
                // 服务器已经过滤点掉了 同一个人的多次请求
                fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, @(type), dateFrom] inContext:DBefaultContext];
                if (!fr)
                {
                    fr           = [FriendRequest MR_createEntityInContext:DBefaultContext];
                    fr.dateTime  = dateFrom;
                    fr.access    = self.userInfo.access;
                    fr.friend_id = userid;
                    fr.type      = @(type);
                }
                
                fr.isOver       = @([dic_sub[@"push_status"] boolValue]);
                if (type != 1 && type != 3)
                    fr.isOver = @YES;
                
                fr.friend_name = dic_sub[@"friend_name"];
                fr.friend_msg  = dic_sub[@"push_content"];
                
                [fr perfect];
                DBSave;
            }
            else if(type == 6 || type == 7)
            {
                NSString *groupid = dic_sub[@"group_id"];
                fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and group_id == %@ and type == %@ and dateTime == %@", self.userInfo.access, userid, groupid, @(type), dateFrom] inContext:DBefaultContext];
                if (!fr)
                {
                    fr = [FriendRequest MR_createEntityInContext:DBefaultContext];
                    fr.isOver = @([dic_sub[@"push_status"] boolValue]);
                    if (type == 7)
                        fr.isOver = @YES;
                    fr.dateTime  = dateFrom;
                    fr.access    = self.userInfo.access;
                    fr.friend_id = dic_sub[@"apply_userid"];
                    fr.group_id  = groupid;
                    fr.type      = @(type);
                }
                
                fr.friend_name = dic_sub[@"apply_user_name"];
                fr.group_name  = dic_sub[@"group_name"];
                fr.friend_msg  = type == 6 ? [NSString stringWithFormat:@"%@ %@ %@", fr.friend_name, kString(@"申请加入"), fr.group_name ] : [NSString stringWithFormat:@"%@ %@", kString(@"您已加入"), fr.group_name];
                [fr perfect];
                DBSave;
            }
        }
        [self refreshData];
    }
}


-(void)dataSuccessBack_pushDrinkHint:(NSDictionary *)dic
{
    [timerM DF_continue];
    if (CheckIsOK)
    {
        NSLog(@"提示喝水，已经知道了");
    }
}

-(void)dataSuccessBack_updatePushInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSLog(@"推送channelId上传成功");
    }
}

-(void)dataSuccessBack_getFriendApplyList:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        SetUserDefault(ExitUserOnce, @1);
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
        {
            NSArray *arr_sub = dic[@"friend_apply_list"];
            if(arr_sub.count > 0)
            {
                for (int i = 0; i < arr_sub.count; i++)
                {
                    NSDictionary *dic_sub = arr_sub[i];
                    NSString *userid = dic_sub[@"userid"];
                    
                    FriendRequest *fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@ and type == %@", self.userInfo.access, userid, @1] inContext:localContext];
                    if (!fr)
                    {
                        fr           = [FriendRequest MR_createEntityInContext:localContext];
                        fr.dateTime  = DNow;
                        fr.type      = @1;
                        fr.friend_id = userid;
                        fr.access    = self.userInfo.access;
                    }
                    
                    fr.user_gender  = @([dic_sub[@"user_gender"] boolValue]);
                    fr.isOver       = @NO;
                    fr.friend_name  = dic_sub[@"user_nick_name"];
                    fr.user_pic_url = dic_sub[@"user_pic_url"];
                    [fr perfect];
                }
                DLSave
                DBSave
            }
        }];  
    }
}

-(void)dataSuccessBack_getGroupApplyList:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
         {
             NSArray *arr_sub = dic[@"group_apply_list"];
             if(arr_sub.count > 0)
             {
                 for (int i = 0; i < arr_sub.count; i++)
                 {
                     NSDictionary *dic_sub = arr_sub[i];
                     NSString *userid      = dic_sub[@"userid"];
                     NSString *groupid     = dic_sub[@"group_id"];
                     
                     FriendRequest *fr = [FriendRequest findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and friend_id == %@ and group_id == %@ and isOver == %@", self.userInfo.access, @6, userid, groupid, @NO] inContext:localContext];
                     if (!fr)
                     {
                         fr           = [FriendRequest MR_createEntityInContext:localContext];
                         fr.access    = self.userInfo.access;
                         fr.dateTime  = DNow;
                         fr.isOver    = @NO;
                         fr.friend_id = userid;
                         fr.group_id  = dic_sub[@"group_id"];
                         fr.type      = @6;
                     }
                     
                     fr.user_gender  = @([dic_sub[@"user_gender"] boolValue]);
                     fr.friend_name  = dic_sub[@"user_nick_name"];
                     fr.user_pic_url = dic_sub[@"user_pic_url"];
                     fr.group_name   = dic_sub[@"group_name"];
                     [fr perfect];
                 }
                 DLSave
                 DBSave
             }
         }];
    }
}




-(void)scrollToTop:(BOOL)isTop
{
    [self.table.tableView setContentOffset:CGPointMake(0,0) animated:YES];
//    [self.tabView setContentOffset:CGPointMake(0,0) animated:NO];
    self.table.tableView.bouncesZoom = NO;
}



// 这里不靠谱
-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 206)
    {
        NSArray *arrDataRecord = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and isUpload == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
        if (arrDataRecord.count || self.isReadBLEBack)
        {
            NSLog(@"主页面 回调  回来了");
            [self refreshWait];
        }
    }
}

-(void)refreshWait
{
    if(GetUserDefault(isSynDataOver) && self.lv.isStartAnimation)   //这里 暂定
    {
        __block vcIndex *blockSelf = self;
        NextWaitInMain(
               [blockSelf resetLv:YES];
               [blockSelf refreshNumber];);
    }
    
    if (fabs([DNow timeIntervalSinceDate:lastReloadDate]) > 1.5 || !lastReloadDate)
    {
        lastReloadDate = DNow;
        __block vcIndex *blockSelf = self;
        NextWaitInMain(
               [blockSelf refreshData];
               [blockSelf readIndexData];);
    }
}

//- (IBAction)btnTabClick:(UIButton *)sender
//{
//    if (sender.tag == 1) {
//        [self back];
//    }
//    else if (sender.tag == 2 && isLoadOK)
//    {
//        [self performSegueWithIdentifier:@"index_to_chart" sender:nil];
//    }
//}


//  这里拉去token值  用来判断如果和当前用户的token值不一样，就是登陆过期了
-(void)nextLogin
{
    __block vcIndex *blockSelf = self;
    RequestCheckNoWaring(
          [net getUserToken:blockSelf.userInfo.access];,
          [blockSelf dataSuccessBack_getUserToken:dic];);
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        if (alertView.cancelButtonIndex == buttonIndex)
        {
            NSLog(@"使用默认");
            self.userInfo.isNeedUpdate = @NO;
            DBSave;
        }
        else if (alertView.firstOtherButtonIndex == buttonIndex)
        {
            [self gotoLoginStoryBoard:@"vcNewPerfectInfo"];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"index_to_search"]) {
        vcSearch *vc = (vcSearch *)[segue destinationViewController];
        __weak vcIndex *blockSelf = self;
        vc.blockBeforeDismissLink = ^(){
            blockSelf.isSearchTag = YES;
        };
    }
}





@end
