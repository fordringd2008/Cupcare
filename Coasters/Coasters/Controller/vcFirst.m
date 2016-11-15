//
//  vcFirst.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcFirst.h"
#import "UUChart.h"
#import "SRMonthPicker.h"

#define  viFirstHeight                           (IPhone4 ? RealHeight(400) :  RealHeight(575))

@interface vcFirst () <UUChartDataSource, SRMonthPickerDelegate>
{
    int             k_dateSub1;           // 日期value  选中的日期值
    
    int             beginInt, endInt;           // 起止时间value

    int             yMax;                 //  计算得出 y轴的合理值
    
    int             k_date_min;           //  有数据的最小日期
    int             k_date_max;           //  有数据的最大日期
    NSDate *        date_min;
    NSDate *        date_max;
    
    NSString *      k_date_min_str;       //  最小的时间   20150204；
    NSString *      k_date_max_str;
    
    NSArray *       arrDataForFriend;      //  朋友的数据
    NSInteger       indexInArrData;       //  选中的天， 在朋友的数据中 的索引
    
    UUChart *       _uuchart;
    
    UIDatePicker *  _datePicker;
    SRMonthPicker*  _monthPicker;            // 只显示年月的日期选择器
}

@property (weak, nonatomic) IBOutlet UIView *                   viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewMainHeight;
@property (weak, nonatomic) IBOutlet UIButton *                 btnDay;
@property (weak, nonatomic) IBOutlet UIButton *                 btnMonth;
@property (weak, nonatomic) IBOutlet UIButton *                 btnYear;
@property (weak, nonatomic) IBOutlet UILabel *                  lblTime;
@property (weak, nonatomic) IBOutlet UIView *                   viewFirst;
@property (weak, nonatomic) IBOutlet UIButton *                 btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *                 btnRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblTimeTop;
@property (weak, nonatomic) IBOutlet UIView *                   line2;
@property (weak, nonatomic) IBOutlet UIView *                   line1;
@property (weak, nonatomic) IBOutlet UIView *                   line3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewFirstTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       btnMonthHeight;
@property (weak, nonatomic) IBOutlet UIImageView *              imvCalendar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       imvCalendarRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblStarLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;

@property (nonatomic, strong) UIView                        *   bgView;



- (IBAction)btnClick:(UIButton *)sender;

@property (nonatomic, strong) NSMutableArray *                  arrX;          // x轴 集合  （数组中嵌套数组）
@property (nonatomic, strong) NSMutableArray *                  arrDay;        //
@property (nonatomic, strong) NSMutableArray *                  arrMonth;      //
@property (nonatomic, strong) NSMutableArray *                  arrYear;       //
@property (weak, nonatomic) IBOutlet UIImageView *              imvLeft;
@property (weak, nonatomic) IBOutlet UIImageView *              imvRight;


@end

@implementation vcFirst

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
}

-(void)dealloc
{
    [self.ViewEffectBody removeFromSuperview];
    [self.ViewEffectHead removeFromSuperview];
    NSLog(@"vcFirst 销毁了");
}


-(void)initData
{
    _indexSub = 1;
    _yearSub1  = _yearSub2 = _yearSub3 = DDYear;
    _monthSub1 = _monthSub2 = DDMonth;
    _daySub1   = DDDay;
    k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub1), @(_monthSub1), @(_daySub1)] mutableCopy]];
    
    if(_model)
    {
        //   --------------------------------------  判断
        //   这里如果要缓存 好友的数据就要  大量修改  暂时不改
        int endDate = [DFD HmF2KNSDateToInt:DNow];
        __block vcFirst *blockSelf = self;
        
        RequestCheckAfter(
              [net getDrinkData:blockSelf.userInfo.access user_id:_model.user_id k_date_from:(endDate - 6) k_date_to:endDate];,
              [blockSelf dataSuccessBack_getDrinkData:dic];);
        
        int todayValue = [DFD HmF2KNSDateToInt:DNow];
        k_date_max = todayValue;
        k_date_min = k_date_max - 6;
        k_date_max_str = [DFD toStringFromDateValue:k_date_max];
        
        
        k_date_min_str = [DFD toStringFromDateValue:k_date_min];
    }
    else
    {
        NSArray *arrAll = [DataRecord findAllSortedBy:@"date" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        
        k_date_max = [DFD HmF2KNSDateToInt:DNow];
        k_date_min = arrAll.count > 0 ? [((DataRecord *)arrAll[arrAll.count - 1]).dateValue intValue] : [DFD HmF2KNSDateToInt:DNow];
        
        k_date_max_str = [DFD toStringFromDateValue:k_date_max];
        k_date_min_str = [DFD toStringFromDateValue:k_date_min];
    }
    
    date_min = [DFD HmF2KNSIntToDate:k_date_min];
    date_max = [DFD HmF2KNSIntToDate:k_date_max];
    
    _arrDay = [NSMutableArray new];
    _arrMonth = [NSMutableArray new];
    _arrYear = [NSMutableArray new];
}

-(void)loadData
{
    _lbl4.text = _lbl5.text = _lbl6.text = @"---";
    _percent = 0;
    if (!_model)
    {
        switch (_indexSub)
        {
            case 1:
            {
                NSDate *dateSelected = [DFD getDateFromArr:@[@(_yearSub1), @(_monthSub1), @(_daySub1)]];
                
                DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and date == %@", self.userInfo.access,  dateSelected] inContext:DBefaultContext];
                _arrDay = [@[ @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0" ] mutableCopy];
                SynData *synBiggest = [[SynData findAllSortedBy:@"water" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d and day == %d", self.userInfo.access, _yearSub1, _monthSub1, _daySub1 ] inContext:DBefaultContext] firstObject];
                SynData *synLast = [[SynData findAllSortedBy:@"waterCount" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %d and month == %d and day == %d", self.userInfo.access, _yearSub1, _monthSub1, _daySub1 ] inContext:DBefaultContext] firstObject];
                
                if (dr)
                {
                    NSArray *arrHour = [dr.water_array_Hours componentsSeparatedByString:@","];
                    _arrDay = [arrHour mutableCopy];
                    
                    _lbl4.text = [DFD getMaxWaterOnTime:dr.water_array time_array:dr.time_array];
                    if (synBiggest)
                    {
                        _lbl4.text = [DFD getTimeStringFromDate:synBiggest.date];
                    }
                    
                    _lbl5.text = [NSString stringWithFormat:@"%@ml", dr.waterCount];
                    _percent = [(synLast ? synLast.waterCount : dr.waterCount) intValue] / [self.userInfo.user_drink_target doubleValue] * 100;
                    _percent = _percent > 100 ? 100 : _percent;
                    
                    _lbl6.text = [NSString stringWithFormat:@"%ld%%", (long)_percent];
                    
                }
                else
                {
                    NSLog(@"没有今天的数据  ，，，， 擦擦擦");
                }
                
                if ([_lbl4.text isEqualToString:@" 00:00"] || [_lbl4.text isEqualToString:@"12:00AM"])
                    _lbl4.text = @"---";
                if ([_lbl5.text isEqualToString:@"0ml"])
                    _lbl5.text = @"---";
                if ([_lbl6.text isEqualToString:@"0%"])
                    _lbl6.text = @"---";
            }
                break;
            case 2:
            {
                NSArray *arrDays = [DataRecord findAllSortedBy:@"dateValue" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and  year == %@ and month == %@", self.userInfo.access, @(_yearSub2), @(_monthSub2)] inContext:DBefaultContext];
                [self initMonth];
                if (arrDays.count > 0)
                {
                    NSInteger sum_percent = 0;                      // 总分
                    NSInteger sumWaterCount = 0;                    // 所有的喝水量
                    NSInteger sumReachTargetDays = 0;               // 达到目标的天数总和
                    NSInteger sumWaterDay = 0;                      // 有喝水量的天数总和
                    for (int i = 0; i < arrDays.count; i++)
                    {
                        DataRecord *dr = arrDays[i];
                        if ([dr.waterCount integerValue])
                        {
                            sum_percent += [dr.waterCount integerValue] / [self.userInfo.user_drink_target doubleValue] * 100;
                            sumWaterCount += [dr.waterCount integerValue];
                            sumReachTargetDays += ([dr.waterCount integerValue] > [self.userInfo.user_drink_target integerValue] ? 1 : 0);
                            sumWaterDay ++;
                        }
                        _arrMonth[[dr.day integerValue] - 1] = [dr.waterCount description];
                        //NSLog(@"day = %@, dr.waterCount = %@", dr.day, dr.waterCount);
                    }
                    
                    _percent = sum_percent / sumWaterDay;
                    
                    _lbl4.text = [NSString stringWithFormat:@"%ldml", sumWaterCount / (long)sumWaterDay];
                    _lbl5.text = [NSString stringWithFormat:@"%ldml", (long)sumWaterCount];
                    _lbl6.text = [NSString stringWithFormat:@"%ld", (long)sumReachTargetDays];
                    
                    if ([_lbl4.text isEqualToString:@"0ml"])
                        _lbl4.text = @"---";
                    if ([_lbl5.text isEqualToString:@"0ml"])
                        _lbl5.text = @"---";
//                    if ([_lbl6.text isEqualToString:@"0"])
//                        _lbl6.text = @"---";
                }
                else
                {
                    NSLog(@"没有这个月的数据  ，，，， 擦擦擦");
                }
            }
                break;
            case 3:
            {
                NSArray *arrMonths = [DataRecord findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@", self.userInfo.access, @(_yearSub3)] inContext:DBefaultContext];
                _arrYear = [@[ @"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0" ] mutableCopy];
                if (arrMonths.count > 0)
                {
                    NSInteger sum_percent = 0;                       // 总得分
                    NSInteger count_percent = 0;                     // 有喝水量的天数总和
                    NSInteger sumWaterCount[12] = {0,0,0,0,0,0,0,0,0,0,0,0};                    // 每个月的喝水量
                    NSInteger sumReachTargetDays = 0;               // 达到的天数
                    NSInteger sumWaterCountAllYear = 0;             // 总喝水量
                    for (int i = 0; i < arrMonths.count; i++)
                    {
                        DataRecord *dr = arrMonths[i];
                        sum_percent += [dr.waterCount integerValue] / [self.userInfo.user_drink_target doubleValue] * 100;
                        count_percent += ([dr.waterCount integerValue] > 0 ? 1:0);
                        sumWaterCount[[dr.month integerValue] - 1] += [dr.waterCount integerValue];
                        sumReachTargetDays += ([dr.waterCount integerValue] > [self.userInfo.user_drink_target doubleValue] ? 1 : 0);
                    }
                    
                    for (int i = 0; i < 12 ; i++)
                    {
                        _arrYear[i] = [NSString stringWithFormat:@"%ld", (long)sumWaterCount[i]];
                        sumWaterCountAllYear += sumWaterCount[i];
                    }
                    
                    //_arrYear = [@[ @"14000", @"28000", @"42000", @"56000", @"55000", @"54000", @"53000", @"54500", @"53500", @"52500", @"53800", @"43700"] mutableCopy];
                    
                    _percent = sum_percent / count_percent;
                    
                    _lbl4.text = [NSString stringWithFormat:@"%ldml", sumWaterCountAllYear / (long)count_percent];
                    _lbl5.text = [NSString stringWithFormat:@"%ldml", (long)sumWaterCountAllYear];
                    _lbl6.text = [NSString stringWithFormat:@"%ld", (long)sumReachTargetDays];
                    
                    
                    
                }
                else
                {
                    NSLog(@"没有这一年的数据  ，，，， 擦擦擦");
                }
            }
                break;
        }
        
    }
    else
    {
        _arrDay = [@[ @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0" ] mutableCopy];
        
        if (arrDataForFriend)
        {
            [self getIndexFromFirendData];
            if (indexInArrData >= 0)
            {
                NSDictionary *dic_Sub = arrDataForFriend[indexInArrData];
                NSArray *arrHour = [dic_Sub[@"water_array_Hours"] componentsSeparatedByString:@","];
                
                _arrDay = [arrHour mutableCopy];
                _lbl4.text = [DFD getMaxWaterOnTime:dic_Sub[@"water_array"] time_array:dic_Sub[@"time_array"]];
                _lbl5.text = [NSString stringWithFormat:@"%@ml", dic_Sub[@"waterCount"]];
                _percent = [dic_Sub[@"_percent"] integerValue];
                _lbl6.text = [NSString stringWithFormat:@"%ld%%", (long)_percent];
                [self updateStar];
            }
        }
    }
    
    
    [self updateStar];
    [self refreshYMax];
    [self updatlblTime];
    [self checkData];
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

-(void)updatlblTime
{
    NSString *strMonth;
    NSString *strDay;
    NSString *strResult;
    switch (_indexSub)
    {
        case 1:
            strMonth = _monthSub1 < 10 ? [NSString stringWithFormat:@"%02d", (int)_monthSub1] :  [NSString stringWithFormat:@"%02d", (int)_monthSub1];
            strDay = _daySub1 < 10 ? [NSString stringWithFormat:@"0%ld", (long)_daySub1] :  [NSString stringWithFormat:@"%ld", (long)_daySub1];
            strResult = [NSString stringWithFormat:@"%ld-%@-%@", (long)_yearSub1, strMonth, strDay];
            break;
        case 2:
            strMonth = _monthSub2 < 10 ? [NSString stringWithFormat:@"0%ld", (long)_monthSub2] :  [NSString stringWithFormat:@"%ld", (long)_monthSub2];
            strResult = [NSString stringWithFormat:@"%ld-%@", (long)_yearSub2, strMonth];
            break;
        case 3:
            strResult = [NSString stringWithFormat:@"%ld", (long)_yearSub3];
            break;
    }
    _lblTime.text = strResult;
}

// 检查预备数据有没有， 没有的话隐藏左边 或者右边的按钮
-(void)checkData
{
    switch (_indexSub)
    {
        case 1:
        {
            NSInteger dayBefore = k_dateSub1 - 1;
            NSInteger dayAfter = k_dateSub1 + 1;
            if (dayBefore < k_date_min)
            {
                [_btnLeft setHidden:YES];
                [_imvLeft setHidden:YES];
            }
            else
            {
                [_btnLeft setHidden:NO];
                [_imvLeft setHidden:NO];
            }
            if (dayAfter > k_date_max)
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
            break;
        case 2:
        {
            NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
            NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
            
            NSInteger monthLeft = _monthSub2 == 1 ? 12 : _monthSub2 - 1;
            NSInteger yearLeft = _monthSub2 == 1 ? _yearSub2 - 1 : _yearSub2;
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
            
            NSInteger monthRight = _monthSub2 == 12 ? 1 : _monthSub2 + 1;
            NSInteger yearRight = _monthSub2 == 12 ? _yearSub2 + 1 : _yearSub2;
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
            break;
        case 3:
        {
            NSInteger min = [[k_date_min_str substringToIndex:4] integerValue];
            NSInteger max = [[k_date_max_str substringToIndex:4] integerValue];
            
            NSInteger intLeft = _yearSub3 - 1;
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
            
            
            NSInteger intRight = _yearSub3 + 1;
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
            break;
            
        default:
            break;
    }
}

//  左右点击
-(void)refreshTime:(BOOL)isBefore
{
    if (isBefore)
    {
        switch (_indexSub)
        {
            case 1:
            {
                k_dateSub1--;
                NSMutableArray *arr = [DFD HmF2KIntToDate:k_dateSub1];
                _yearSub1 = [arr[0] integerValue];
                _monthSub1 = [arr[1] integerValue];
                _daySub1 = [arr[2] integerValue];
            }
                break;
            case 2:
            {
                _monthSub2 = _monthSub2 == 1 ? 12 : _monthSub2 - 1;
                _yearSub2 = _monthSub2 == 12 ? _yearSub2 - 1 : _yearSub2;
            }
                break;
            case 3:
            {
                _yearSub3--;
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        switch (_indexSub)
        {
            case 1:
            {
                k_dateSub1++;
                NSMutableArray *arr = [DFD HmF2KIntToDate:k_dateSub1];
                _yearSub1 = [arr[0] integerValue];
                _monthSub1 = [arr[1] integerValue];
                _daySub1 = [arr[2] integerValue];
            }
                break;
            case 2:
            {
                _monthSub2 = _monthSub2 == 12 ? 1 : _monthSub2 + 1;
                _yearSub2 = _monthSub2 == 1 ? _yearSub2 + 1 : _yearSub2;
            }
                break;
            case 3:
            {
                _yearSub3++;
            }
                break;
                
            default:
                break;
        }
    }
    
    [self loadData];
    [self changeUUChart];
}

-(void)changeUUChart
{
    if (_uuchart) [_uuchart removeFromSuperview];
    CGRect rect = CGRectMake(5, 0, ScreenWidth - 10, viFirstHeight);
    _uuchart = [[UUChart alloc] initwithUUChartDataFrame:rect withSource:self withStyle:UUChartBarStyle];
    _uuchart.backgroundColor = DClear;
    _uuchart.Interval = _indexSub == 3 ? 1 : 3;
    [_uuchart showInView:_viewFirst];   
}


-(void)initView
{
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewMain.backgroundColor = DidConnectColor;
    _viewFirstHeight.constant = viFirstHeight;
    _btnMonthHeight.constant =  Bigger(RealHeight(50), 30);
    _lblTimeTop.constant = Bigger(RealHeight(50), 30) + 1;
    _lblStarLeft.constant = IPhone4 ? 20 : RealWidth(30);
    //Border(_lblScore, DRed);
    [_imvCalendar setHidden:NO];
    
    [_btnDay setTitle:kString(@"日") forState:UIControlStateNormal];
    [_btnMonth setTitle:kString(@"月") forState:UIControlStateNormal];
    [_btnYear setTitle:kString(@"年") forState:UIControlStateNormal];
    _lblTime.text = [DNow toString:@"YYYY-MM-dd"];
    
    
    if(_model)
    {
        [_line1 setHidden:YES];
        [_line2 setHidden:YES];
        [_line3 setHidden:YES];
        [_btnDay setHidden:YES];
        [_btnMonth setHidden:YES];
        [_btnYear setHidden:YES];
        _lblTimeTop.constant = Bigger(RealHeight(50), 30) / 2;
        _viewFirstTop.constant = Bigger(RealHeight(50), 30) + 1;
        
    }
    // 默认
    _btnDay.backgroundColor = DWhite3;
    [_btnLeft setHidden:YES];
    [_imvLeft setHidden:YES];
    [_btnRight setHidden:YES];
    [_imvRight setHidden:YES];
    
    // 延迟加载
    dispatch_async(dispatch_get_main_queue(), ^{
        [self selectTabIndex:1];
    });
}

-(void)selectTabIndex:(NSInteger)ind
{
    [self resetTopButton];
    [_imvCalendar setHidden:YES];
    switch (ind) {
        case 1:
        {
            _indexSub = 1;
            _btnDay.backgroundColor = DWhite3;
            _lblScore.text = kString(@"当日的星级评分:");
            _lbl1.text = kString(@"喝水最多");
            _lbl2.text = kString(@"日喝水量");
            _lbl3.text = kString(@"目标完成");
            _imvCalendarRight.constant = 0;
            if(!_model) [_imvCalendar setHidden:NO];
            
        }
            break;
        case 2:
        {
            _indexSub = 2;
            _btnMonth.backgroundColor = DWhite3;
            _lblScore.text = kString(@"当月的星级评分:");
            _lbl1.text = kString(@"日均喝水量");
            _lbl2.text = kString(@"月喝水总量");
            _lbl3.text = kString(@"达成目标天数");
            _imvCalendarRight.constant = -10;
            if(!_model) [_imvCalendar setHidden:NO];
        }
            break;
        case 3:
        {
            _indexSub = 3;
            _btnYear.backgroundColor = DWhite3;
            _lblScore.text = kString(@"年星级评分:");
            _lbl1.text = kString(@"日均喝水量");
            _lbl2.text = kString(@"年喝水总量");
            _lbl3.text = kString(@"达成目标天数");
        }
            break;
            
        default:
            break;
    }
    
    [self loadData];
    [self changeUUChart];
}

-(void)resetTopButton
{
    _btnDay.backgroundColor = _btnMonth.backgroundColor = _btnYear.backgroundColor = DClear;
}


// 刷新Y轴合理值
-(void)refreshYMax
{
    NSMutableArray *arrThis;
    switch (_indexSub)
    {
        case 1:
            arrThis = _arrDay;
            break;
        case 2:
            arrThis = _arrMonth;
            break;
        case 3:
            arrThis = _arrYear;
            break;
            
        default:
            break;
    }
    
    int biggest = arrThis.count ? [arrThis[0] intValue] : 100;
    for (int i = 0; i < arrThis.count; i++)
    {
        int intThis = [arrThis[i] intValue];
        if (biggest < intThis) {
            biggest = intThis;
        }
    }
    
    yMax = biggest;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (IBAction)btnClick:(UIButton *)sender
{
    if (sender.tag == _indexSub) return;
    static BOOL isSoQuick = NO;
    if (isSoQuick) return;
    isSoQuick = YES;
    NextWaitInMainAfter(isSoQuick = NO;, 0.5);
    
    switch (sender.tag) {
        case 1:
        case 2:
        case 3:
            [self selectTabIndex:sender.tag];
            break;
        case 4:
            [self refreshTime:YES];
            break;
        case 5:
            [self refreshTime:NO];
            break;
        case 6: // 单击日历
        {
            if (_model || _indexSub == 3) return;
            
            if (!self.bgView) {
                [self initViewCover:300];
                [self initDatePickerView];
            }
            if (_indexSub == 1)
            {
                [_monthPicker setHidden:YES];
                [_datePicker setHidden:NO];
            }
            else
            {
                [_monthPicker setHidden:NO];
                [_datePicker setHidden:YES];
            }
            
            self.btnTime.enabled = self.btnDay.enabled = self.btnMonth.enabled = self.btnYear.enabled = NO;
             __block vcFirst *blockSelf = self;
            NextWaitInMainAfter(
                    blockSelf.btnTime.enabled = blockSelf.btnDay.enabled = blockSelf.btnMonth.enabled = blockSelf.btnYear.enabled = YES;, 1);
            self.btnTime.enabled = NO;
            [self showViewCover];
        }
            break;
    }
}


#pragma mark UUChartDataSource
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
    switch (_indexSub)
    {
        case 1:
        {
            if([DFD isSysTime24])
                return [@[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23"] mutableCopy];
            else
                return [@[@"AM", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"PM", @"1", @"2", @"3", @"4",  @"5", @"6", @"7", @"8", @"9", @"10", @"11"] mutableCopy];
        }
            break;
        case 2:
            return [DFD getXarrList:_yearSub2 month:_monthSub2];
            break;
        case 3:
            return @[ @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12" ];
            break;
            
        default:
            break;
    }
    return nil;
}

//数值多重数组 (数组中嵌套数组)
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
    switch (_indexSub)
    {
        case 1:
            return  @[_arrDay];
            break;
        case 2:
            //NSLog(@"%@", _arrMonth);
            return  @[_arrMonth];
            break;
        case 3:
            return  @[_arrYear];
            break;
            
        default:
            break;
    }
    return nil;
}


//@optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[RGB(137, 202, 240)];
}

//
//显示数值范围  (Y轴区间)
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    //NSLog(@"yMax : %d", yMax);          // 这里是最大值，要算出合理值
    double radio = 0;
    switch (_indexSub) {
        case 1:
            radio = 400.0;
            break;
        case 2:
            radio = 2000.0;
            break;
        case 3:
            radio = 8000.0;
            break;
    }
    yMax = yMax == 0 ? 1 : yMax;                  // 防止没有数据时  Y轴坐标 为 12345
    yMax = ceil((double)yMax / radio) * radio;
    //NSLog(@"------- yMax : %d", yMax);          // 这里是最大值，要算出合理值
    return CGRangeMake(yMax, 0);
}


-(void)initMonth
{
    NSInteger days = [DFD getDaysByYearAndMonth:_yearSub2 month:_monthSub2];
    NSMutableArray *arr = [NSMutableArray new];
    for (int i = 0; i < days; i++)
        [arr addObject:[NSString stringWithFormat:@"%d", 0]];
    _arrMonth = arr;
}


-(void)dataSuccessBack_getDrinkData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSArray *arrData = dic[@"drink_data"];
        if (!arrData) return;
        NSMutableArray *arr_Friend = [NSMutableArray new];
        for (int i = 0; i < arrData.count; i++)
        {
            NSDictionary *dicData = arrData[i];
            NSString *k_date = dicData[@"k_date"];
            NSString *time_array = dicData[@"time_array"];
            NSString *water_array = dicData[@"water_array"];
            NSString *counts = dicData[@"counts"];
            
            NSMutableDictionary *dic_sub = [NSMutableDictionary new];
            [dic_sub setObject:@([k_date integerValue]) forKey:@"dateValue"];
            NSDate *date = [DFD HmF2KNSIntToDate:[k_date intValue]];
            [dic_sub setObject:date forKey:@"date"];
            [dic_sub setObject:@([counts integerValue]) forKey:@"cout"];
            NSInteger waterCount = [DFD getWaterCountFromWater_array:water_array time_array:time_array];
            [dic_sub setObject:@(waterCount) forKey:@"waterCount"];
            [dic_sub setObject:time_array forKey:@"time_array"];
            [dic_sub setObject:water_array forKey:@"water_array"];
            [dic_sub setObject:[DFD getWater_array_Hour_FromArray:water_array time_array:time_array] forKey:@"water_array_Hours"];
            int per = (double)waterCount / [self.userInfo.user_drink_target doubleValue] * 100;
            per = per > 100 ? 100 : per;
            [dic_sub setObject:@(per) forKey:@"_percent"];
            [dic_sub setObject:@([self.userInfo.user_drink_target integerValue]) forKey:@"target"];
            [dic_sub setObject:@([date getFromDate:3]) forKey:@"day"];                                                      // 天 方便查找
            
            [arr_Friend addObject:dic_sub];
        }
        arrDataForFriend = arr_Friend;
        [self selectTabIndex:1];
    }
    else
    {
        NSLog(@"出错了， ");
    }
}

-(void)getIndexFromFirendData
{
    indexInArrData = -1;
    for (int i = 0; i < arrDataForFriend.count; i++)
    {
        NSDictionary *dic_Sub = arrDataForFriend[i];
        if ([dic_Sub[@"day"] integerValue] == _daySub1 ) {
            indexInArrData = i;
            break;
        }
    }
}
//初始化DatePickerView
- (void)initDatePickerView
{
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256 - NavBarHeight)];
    _datePicker.locale = [[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" :@"en_US"];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
    _datePicker.date = DNow;
    _datePicker.backgroundColor = DWhite;
    _datePicker.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    _datePicker.minimumDate = date_min;
    _datePicker.maximumDate = date_max;
    [self.ViewCover addSubview:_datePicker];
    
    _monthPicker = [[SRMonthPicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256-NavBarHeight)];
    _monthPicker.monthPickerDelegate = self;
    _monthPicker.backgroundColor     = DWhite;
    _monthPicker.maximumYear         = [date_max getFromDate:1];
    _monthPicker.minimumYear         = [date_min getFromDate:1];
    
    _monthPicker.date = DNow;
    _monthPicker.yearFirst = YES;
    [self.ViewCover addSubview:_monthPicker];
}

-(void)toolOKBtnClickAnimation
{
    if(_indexSub == 1)
    {
        NSLog(@"选择的日期  %@", _datePicker.date);
        int yearTag  = [_datePicker.date getFromDate:1];
        int monthTag = [_datePicker.date getFromDate:2];
        int dayTag   = [_datePicker.date getFromDate:3];
        
        _yearSub1 = yearTag;
        _monthSub1 = monthTag;
        _daySub1 = dayTag;
        k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub1), @(_monthSub1), @(_daySub1)]mutableCopy] ];
    }
    else
    {
        NSLog(@"%ld", (long)[_monthPicker.date getFromDate:2]);
        _yearSub2 = [_monthPicker.date getFromDate:1];
        _monthSub2 = [_monthPicker.date getFromDate:2];
        k_dateSub1 = [DFD HmF2KDateToInt:[@[@(_yearSub2), @(_monthSub2), @(1)] mutableCopy]];
    }
    
    [self selectTabIndex:_indexSub];
}

-(void)showViewCover
{
    if (self.delegate)
        [self.delegate pageControlHidden:YES];
    [super showViewCover];
}

-(void)toolCancelBtnClickCompleted
{
    self.btnTime.enabled = YES;
    if (self.delegate)
        [self.delegate pageControlHidden:NO];
}

-(void)toolOKBtnClickCompleted
{
    self.btnTime.enabled = YES;
    if (self.delegate)
        [self.delegate pageControlHidden:NO];
}

-(void)pickerViewDisappear
{
    self.btnTime.enabled = YES;
    [UIView animateWithDuration:0.5 animations:^{
        if (self.ViewCover) {
            [self.ViewCover setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
            self.ViewEffectBody.alpha = self.ViewEffectHead.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (self.delegate)
            [self.delegate pageControlHidden:NO];
    }];
}


- (void)monthPickerDidChangeDate:(SRMonthPicker *)monthPicker
{
    NSInteger min = [[k_date_min_str substringToIndex:6] integerValue];
    NSInteger max = [[k_date_max_str substringToIndex:6] integerValue];
    NSInteger select = [[self formatDate:monthPicker.date] integerValue];
    if (select < min)
    {
        NSDateComponents* dateParts = [[NSDateComponents alloc] init];
        dateParts.month = [[k_date_min_str substringWithRange:NSMakeRange(4, 2)] integerValue];
        dateParts.year = [[k_date_min_str substringWithRange:NSMakeRange(0, 4)] integerValue];;
        _monthPicker.date = [[NSCalendar currentCalendar] dateFromComponents:dateParts];
    }
    else if(select > max)
    {
        NSDateComponents* dateParts = [[NSDateComponents alloc] init];
        dateParts.month = [[k_date_max_str substringWithRange:NSMakeRange(4, 2)] integerValue];
        dateParts.year = [[k_date_max_str substringWithRange:NSMakeRange(0, 4)] integerValue];;
        _monthPicker.date = [[NSCalendar currentCalendar] dateFromComponents:dateParts];
    }
}

- (NSString*)formatDate:(NSDate *)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYYMM";// @"MMMM y";
    return [formatter stringFromDate:date];
}




@end
