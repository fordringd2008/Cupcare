//
//  vcSecond.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcSecond.h"
#import "SHLineGraphView.h"
#import "SHPlot.h"
#import "vcShare.h"
#import "vcFriendDetails.h"

#define viFirstHeight                           (IPhone4 ? RealHeight(400) :  RealHeight(575))

@interface vcSecond ()
{
    NSInteger           coutDaysOfMonth;      // 当前年的 当前月 有多少天
    int                 k_date_min;           //  有数据的最小日期
    int                 k_date_max;           //  有数据的最大日期
    
    NSString *          k_date_min_str;       //  最小的时间   20150204；
    NSString *          k_date_max_str;
    
    BOOL                isLeft;                    // 是否离开
    SHPlot *            _plot1;
    SHLineGraphView *   _lineGraph;
    CGRect              rect;
}

@property (weak, nonatomic) IBOutlet UIView *               viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   viewMainHeight;
@property (weak, nonatomic) IBOutlet UILabel *              lblTime;
@property (weak, nonatomic) IBOutlet UIView *               viewFirst;
@property (weak, nonatomic) IBOutlet UIView *               viewSecond;

@property (weak, nonatomic) IBOutlet UIButton *             btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *             btnRight;
@property (weak, nonatomic) IBOutlet UIImageView *          imvLeft;
@property (weak, nonatomic) IBOutlet UIImageView *          imvRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   viewFirstHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   lblStarLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   lblTimeHeight;

- (IBAction)btnClick:(UIButton *)sender;
@property (strong, nonatomic) NSMutableArray * arrData;                             // 数据源

@end

@implementation vcSecond

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [self initView];
    });  
}


-(void)initData
{
    _year   = DDYear;
    _month = DDMonth;
    NSArray *arrAll = [DataRecord findAllSortedBy:@"date" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ ", self.acc] inContext:DBefaultContext];
    
    k_date_max = [DFD HmF2KNSDateToInt:DNow];
    k_date_max_str = [DFD toStringFromDateValue:k_date_max];
    k_date_min = arrAll.count > 0 ? [((DataRecord *)arrAll[arrAll.count - 1]).dateValue intValue] : [DFD HmF2KNSDateToInt:DNow];
    k_date_max_str = [DFD toStringFromDateValue:k_date_max];
    k_date_min_str = [DFD toStringFromDateValue:k_date_min];
    
    _arrData = [NSMutableArray new];
    if (IPhone4)      rect = CGRectMake(5, -20, ScreenWidth - 10, viFirstHeight + 30);
    else if (IPhone5) rect = CGRectMake(5, -50, ScreenWidth - 10, viFirstHeight + 60);
    else if (IPhone6) rect = CGRectMake(5, -53, ScreenWidth - 10, viFirstHeight + 63);
    else if (IPhone6P)rect = CGRectMake(5, -63, ScreenWidth - 10, viFirstHeight + 73);
    else              rect = CGRectMake(5, -100, ScreenWidth - 10, viFirstHeight + 110); // IPAD
    
    [self refreshData];
}


-(void)initView
{
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewFirstHeight.constant = viFirstHeight-1; // 因为这个最顶层的line宽度比vcFirst 高1
    _viewMain.backgroundColor = DidConnectColor;
    _lblTimeHeight.constant = Bigger(RealHeight(50) * 2.5, 75);
    _lblStarLeft.constant =  IPhone4 ? 20 : RealWidth(30);
    
    _lblTime.text = [DNow toString:@"YYYY-MM"];
    _lblScore.text = kString(@"我的星级评分:");
    _lbl1.text = kString(@"平均分");
    _lbl2.text = kString(@"日均喝水量");
    _lbl3.text = kString(@"喝水量总排名");
    _lbl6.text = [myUserInfo.rank description];
    [self initLbl];
    [self updateStar];
}

-(void)refreshView
{
    
}

-(void)refreshData
{
    NSArray *arrDr = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d", myUserInfoAccess, _year, _month] inContext:DBefaultContext];
    coutDaysOfMonth = [DFD getDaysByYearAndMonth:_year month:_month];
    
    [self resetData];
    _percent = 0;
    for (int i = 0; i < arrDr.count; i++)
    {
        DataRecord *dr = arrDr[i];
        NSInteger percent = [dr.waterCount integerValue] / [myUserInfo.user_drink_target doubleValue] * 100;
        //NSLog(@"target = %@", myUserInfo.user_drink_target);
        percent  = percent < 50 ? 50 : percent;
        percent = percent > 100 ? 100: percent;
        _arrData[[dr.day integerValue] - 1] = @(percent);
    }
    
    
    [self updatlblTime];
    [self checkData];
    [self changeUUChart];
    
//    Border(lineGraph, DRed);
//    Border(_lblTime, DYellow);
}

-(void)resetData
{
    [_arrData removeAllObjects];
    NSInteger count = coutDaysOfMonth;
    if (DDYear == _year && DDMonth == _month)
        count = DDDay;
    for (int i = 0; i < count; i++)
        [_arrData addObject:@(50)];
}

-(void)changeUUChart
{
    if (_lineGraph) [_lineGraph removeFromSuperview];
    
    _lineGraph = [[SHLineGraphView alloc] initWithFrame:rect];
    NSDictionary *_themeAttributes = @{
                                       kXAxisLabelColorKey : DWhite,
                                       kXAxisLabelFontKey : [UIFont systemFontOfSize: 10],
                                       kYAxisLabelColorKey : DWhite,
                                       kYAxisLabelFontKey : [UIFont systemFontOfSize: 10],
                                       kYAxisLabelSideMarginsKey : @20,
                                       kPlotBackgroundLineColorKey : DWhite3,
                                       kDotSizeKey : @10
                                       };
    _lineGraph.themeAttributes = _themeAttributes;
    _lineGraph.yAxisRange = @100;
    _lineGraph.yAxisSuffix = @"K";
    
    NSMutableArray *arrX = [NSMutableArray new];
    for (int i = 1; i < coutDaysOfMonth+1 ; i++)
    {
        NSDictionary *dicSub = @{ @(i) : [NSString stringWithFormat:@"%d", i] };
        [arrX addObject:dicSub];
    }

    _lineGraph.xAxisValues = [NSArray arrayWithArray:arrX];
    _plot1 = [[SHPlot alloc] init];
    
    NSMutableArray *arrP = [NSMutableArray new];
    for (int i = 0; i < coutDaysOfMonth ; i++)
    {
        if (i < _arrData.count)
            [arrP addObject:@{ @(i+1) : _arrData[i] }];
        else
            [arrP addObject:@{ @(i+1) : @0 }];
    }

    _plot1.plottingValues = [NSArray arrayWithArray:arrP];
    
    NSDictionary *_plotThemeAttributes = @{
                                           kPlotFillColorKey : DWhiteA(0.3),
                                           kPlotStrokeWidthKey : @2,
                                           kPlotStrokeColorKey : DWhiteA(0.8),
                                           kPlotPointFillColorKey : DClear,
                                           kPlotPointValueFontKey : [UIFont systemFontOfSize: 10]
                                           };
    
    _plot1.plotThemeAttributes = _plotThemeAttributes;
    [_lineGraph addPlot:_plot1];
    [_lineGraph setupTheView];
    [self.viewFirst addSubview:_lineGraph];
}


// 检查预备数据有没有， 没有的话隐藏左边 或者右边的按钮
-(void)checkData
{
    NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
    NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
    
    NSInteger yearLeft = _month == 1 ? _year - 1 : _year;
    NSInteger monthLeft = _month == 1 ? 12 : _month - 1;
    
    NSString *strMonthLeft = monthLeft < 10 ? [NSString stringWithFormat:@"0%ld", (long)monthLeft]: [NSString stringWithFormat:@"%ld", (long)monthLeft];
    NSInteger intLeft = [[NSString stringWithFormat:@"%ld%@", (long)yearLeft, strMonthLeft] integerValue];
    if (intLeft < min)
    {
        [_btnLeft setHidden:YES];
        [_imvLeft setHidden:YES];
    }
    else
    {
        [_btnLeft setHidden:NO];
        [_imvLeft setHidden:NO];
    }
    
    NSInteger yearRight = _month == 12 ? _year + 1 : _year;
    NSInteger monthRight = _month == 12 ? 1 : _month + 1;
    
    NSString *strMonth = monthRight < 10 ? [NSString stringWithFormat:@"0%ld", (long)monthRight]: [NSString stringWithFormat:@"%ld", (long)monthRight];
    NSInteger intRight = [[NSString stringWithFormat:@"%ld%@", (long)yearRight, strMonth] integerValue];
    
    if (intRight > max)
    {
        [_btnRight setHidden:YES];
        [_imvRight setHidden:YES];
    }
    else
    {
        [_btnRight setHidden:NO];
        [_imvRight setHidden:NO];
    }
}

//  左右点击
-(void)refreshTime:(BOOL)isBefore
{
    if (isBefore)
    {
        _year = _month == 1 ? _year - 1 : _year;
        _month = _month == 1 ? 12 : _month - 1;
    }
    else
    {
        _year = _month == 12 ? _year + 1 : _year;
        _month = _month == 12 ? 1 : _month + 1;
    }
    
    [self refreshData];
}

-(void)updateStar
{
    NSInteger count = 0;
    if (_percent == 0)
        count = 0;
    else if (_percent < 60)
        count = 1;
    if (_percent >= 60 && _percent < 70)
        count = 2;
    else if (_percent >= 70 && _percent < 80)
        count = 3;
    else if (_percent >= 80 && _percent < 90)
        count = 4;
    else if (_percent >= 90)
        count = 5;
    
    for (int i = 0 ; i < 5; i++)
    {
        UIImageView *imgLight = _viewStar.subviews[i];
        imgLight.image = [UIImage imageNamed:@"stars02"];
        if (count > i)
            imgLight.image = [UIImage imageNamed:@"stars"];
    }
}

// 更新
-(void)initLbl
{
    NSArray *arr = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", myUserInfoAccess] inContext:DBefaultContext];
    if (arr.count > 0)
    {
        NSInteger sumWaterCount = 0;
        NSInteger avgWaterCount = 0;
        NSInteger avgPercent = 0;
        NSInteger drCount = 0;
        for (int i = 0; i < arr.count; i++)
        {
            DataRecord *dr = arr[i];
            if([dr.waterCount integerValue])
            {
                sumWaterCount += [dr.waterCount integerValue];
                drCount++;
            }
        }
        avgWaterCount = sumWaterCount / (double)drCount;
        
        avgPercent = avgWaterCount / [myUserInfo.user_drink_target doubleValue] * 100;
        //avgPercent = avgPercent < 50 ? 50 : avgPercent;   // 和安卓统一
        avgPercent = avgPercent > 100 ? 100 : avgPercent;
        _percent = avgPercent;
        _lbl4.text = [NSString stringWithFormat:@"%ld", (long)avgPercent];
        _lbl5.text = [NSString stringWithFormat:@"%ldml", (long)avgWaterCount];
        
        static BOOL isSoQuick = NO;
        if (isSoQuick) return;
        isSoQuick = YES;
        NextWaitInMainAfter(isSoQuick = NO;, 60);
        
        __block vcSecond *blockSelf = self;
        RequestCheckNoWaring(
              [net getDrinkRank:myUserInfoAccess day_water_num:avgWaterCount];,
              [blockSelf dataSuccessBack_getDrinkRank:dic];);
    }
    else                    //  没有这个用户的数据
    {
        _lbl4.text = _lbl5.text = _lbl6.text =  @"---";
    }
}

-(void)updatlblTime
{
    NSString *strMonth = _month < 10 ? [NSString stringWithFormat:@"0%ld", (long)_month] :  [NSString stringWithFormat:@"%ld", (long)_month];
    NSString *strResult = [NSString stringWithFormat:@"%ld-%@", (long)_year, strMonth];
    _lblTime.text = strResult;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)btnClick:(UIButton *)sender
{
    static BOOL isSoQuick = NO;
    if (isSoQuick) return;
    isSoQuick = YES;
    NextWaitInMainAfter(isSoQuick = NO;, 0.5);
    
    [self refreshTime:(sender.tag == 1)];
}


-(void)dataSuccessBack_getDrinkRank:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSString *rank = dic[@"rank"];
        if (!rank) return;
        if (!isLeft)
        {
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext)
             {
                 self.userInfo = [UserInfo findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:localContext];
                 //NSLog(@"---->  rank : %@", self.userInfo.rank);
                 self.userInfo.rank = @([rank integerValue]);
                 //NSLog(@"---->  rank : %@", self.userInfo.rank);
                 DLSave;
                 DBSave;
                 __block vcSecond *blockSelf = self;
                 __block NSString *blockrank = rank;
                 NextWaitInMain(blockSelf.lbl6.text = blockrank;);
             }];
        }
    }
    else
    {
        NSLog(@"出错了-----------------");
    }
}




@end
