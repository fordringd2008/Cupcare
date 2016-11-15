//
//  vcEditClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcEditClock.h"
#import "tvcEditClock.h"
#import "vcEditRepeat.h"

@interface vcEditClock () <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate, vcEditRepeatDelegate>
{
    NSDate *        dateSelected;                   // 暂存的数据，  保存时 赋值
    NSMutableArray *arrRepeat;
    NSInteger       typeSelect;                     // 选中的 1 2 4
    
    NSString *      dateString;
    NSString *      repeatSttring;
    
    NSInteger       typeFromPick;                   // 下拉产生的  点击确定按钮，才会赋值给暂存
    
    NSString *      typeString;
    BOOL            isEditTime;                     // 是否要修改时间
}

@property (nonatomic, weak) IBOutlet UITableView *              tabView;
@property (nonatomic, strong) NSArray *                         arrTitle;
@property (nonatomic, strong) NSArray *                         arrValue;
@property (nonatomic, strong) NSArray *                         arrPicker;
@property (nonatomic, strong) UIDatePicker *                    datePicker;
@property (nonatomic, strong) UIPickerView *                    pickerView;

@end

@implementation vcEditClock

- (void)viewDidLoad
{
    NSLog(@"加载时间");
    [super viewDidLoad];
    if(self.isAdd)
        [self initLeftButton:nil text:@"新增闹钟"];
    else
        [self initLeftButton:nil text:@"修改闹钟"];
    
    [self initRightButton:@"save" text:nil];
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    [self refreshData];
    [self.tabView reloadData];
}

-(void)dealloc
{
    [self.ViewEffectBody removeFromSuperview];
    [self.ViewEffectHead removeFromSuperview];
    NSLog(@"vcEditClock 销毁了");
}


-(void)initData
{
    if(!self.clock)
    {
        self.clock = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"type == %@", @0]] firstObject];
        NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@", self.clock.isOn, self.clock.strRepeat, self.clock.strTime, self.clock.type);
    }
    
    self.arrTitle = @[ kString(@"时间"), kString(@"重复"), kString(@"类型") ];
    self.arrPicker = @[ kString(@"普通闹钟"), kString(@"吃药提醒"), kString(@"要事提醒") ];
    
    NSInteger hour_ = [self.clock.hour intValue];
    NSInteger minute_ = [self.clock.minute intValue];
    
    if (hour_ == 0 && minute_ == 0 && [self.clock.type intValue] == 0) {
        dateSelected = [DNow getNowDateFromatAnDate];
    }else
    {
        dateSelected = [DFD getDateFromArr:@[ @(hour_), @(minute_), @0, @0]];
    }
    
    arrRepeat = [[self.clock.repeat componentsSeparatedByString:@"-"] mutableCopy];
    typeSelect = [self.clock.type intValue];
}

-(void)refreshData
{
    dateString = [DFD getTimeStringFromDate:dateSelected];
    NSMutableString *strRepeat = [NSMutableString new];
    if ([arrRepeat[0] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周日")]];
    if ([arrRepeat[1] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周一")]];
    if ([arrRepeat[2] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周二")]];
    if ([arrRepeat[3] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周三")]];
    if ([arrRepeat[4] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周四")]];
    if ([arrRepeat[5] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周五")]];
    if ([arrRepeat[6] intValue])
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"周六")]];
    if (!strRepeat.length)
        [strRepeat appendString:[NSString stringWithFormat:@" %@", kString(@"不重复")]];
    else if(![arrRepeat containsObject:@"0"])
        strRepeat = [NSMutableString stringWithFormat:kString(@"每天")];
    repeatSttring = [NSString stringWithFormat:@"%@", strRepeat];
    
    switch (typeSelect) {
        case 0:
        case 1:
            typeString = self.arrPicker[0];
            break;
        case 2:
            typeString = self.arrPicker[1];
            break;
        case 4:
            typeString = self.arrPicker[2];
            break;
            
        default:
            break;
    }
    self.arrValue = @[ dateString, repeatSttring, typeString ];
}

-(void)initView
{
    self.tabView.rowHeight = Bigger(RealHeight(120), 70);
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
    __block vcEditClock *blockSelf = self;
    NextWaitInMain(
           [blockSelf initViewCover:300];
           [blockSelf initDatePickerView];
           [blockSelf initPickerView];);
}



- (void)initDatePickerView
{
    self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256 - NavBarHeight)];
    [_datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:([DFD getLanguage] == 1 ? @"zh_Hans_CN":@"en_US")]];
    _datePicker.backgroundColor = DWhite;
    _datePicker.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    [_datePicker setDatePickerMode:[DFD isSysTime24] ? UIDatePickerModeCountDownTimer : UIDatePickerModeTime];
    _datePicker.date = [dateSelected clearTimeZone];
    [self.ViewCover addSubview:_datePicker];
}

- (void)initPickerView
{
    self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickerView.backgroundColor = DWhite;
    _pickerView.tintColor = [UIColor colorWithRed:0.0f green:0.35f blue:0.91f alpha:1.0f];
    [self.ViewCover addSubview:_pickerView];
}


-(void)rightButtonClick
{
    if (!self.isChange && !self.isAdd) {
        LMBShow(@"没有修改");
        return;
    }
    
    self.clock.hour = @([[dateSelected clearTimeZone] getFromDate:4]);
    self.clock.minute = @([[dateSelected clearTimeZone] getFromDate:5]);
    self.clock.repeat = [arrRepeat componentsJoinedByString:@"-"];
    self.clock.type = @(typeSelect == 0 ? 1 : typeSelect);
    self.clock.isOn = @(YES);
    [self.clock perfect];
    DBSave;
    
    [self.Bluetooth setClock:self.userInfo.pUUIDString isFirst:([self.clock.iD intValue] < 4)];
    LMBShow(@"保存成功");
    
     __block vcEditClock *blockSelf = self;
    NextWaitInMainAfter([blockSelf back];, 1);
}



#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcEditClock *cell = [tvcEditClock cellWithTableView:tableView];
    cell.lblTitle.text = self.arrTitle[indexPath.row];
    cell.lblValue.text = self.arrValue[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    _datePicker.hidden = YES;
    _pickerView.hidden = YES;
    
    switch (indexPath.row)
    {
        case 0:
            isEditTime = YES;
            _datePicker.hidden = NO;
            [self showViewCover];
            break;
        case 1:
            self.isChange = YES;
            [self performSegueWithIdentifier:@"editClock_to_editRepeat" sender:nil];
            break;
        case 2:
            isEditTime = NO;
            _pickerView.hidden = NO;
            _pickerView.delegate   = self;
            _pickerView.dataSource = self;
            [self showViewCover];
            break;
    }
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.arrPicker.count;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return  self.arrPicker[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    typeFromPick = row == 2 ? 4 : row + 1;
}



#pragma mark vcEditRepeatDelegate
-(void)changeRepeat:(NSMutableArray *)arr
{
    self.isChange = YES;
    arrRepeat = [arr mutableCopy];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"editClock_to_editRepeat"])
    {
        vcEditRepeat *vc = (vcEditRepeat *)segue.destinationViewController;
        vc.delegate = self;
        vc.clock = self.clock;
    }
}



-(void)toolOKBtnClickAnimation
{
    self.isChange = YES;
    if (isEditTime)
        dateSelected = [self.datePicker.date getNowDateFromatAnDate];
    else
        typeSelect = typeFromPick;
    
    [self refreshData];
    [self.tabView reloadData];
}

-(void)toolCancelBtnClickCompleted
{
    _pickerView.delegate = nil;
    _pickerView.delegate = nil;
}


@end
