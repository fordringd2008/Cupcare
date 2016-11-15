//
//  vcRemindTimeEdit.m
//  Coasters
//
//  Created by 丁付德 on 15/10/20.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcRemindTimeEdit.h"
#import "tvcSetReminderWater.h"

@interface vcRemindTimeEdit () <UITableViewDelegate, UITableViewDataSource>
{
    NSDate *dateLeft;
    NSDate *dateRight;
    UILabel *lblNoData;                 //  没有数据的提示
    NSDictionary *dicEdit;              //  选中的， 在修改的时间段  有：证明是修改的， null：证明是添加的
    
    
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (nonatomic, strong) UITableView *                 tabView;
@property (nonatomic, strong) NSMutableArray *              arrData;
@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UIDatePicker                  *datePickerLeft;
@property (nonatomic, strong) UIDatePicker                  *datePickerRight;

@end

@implementation vcRemindTimeEdit

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButton:nil text:@"时间段设置"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    [self initData];
    [self initView];
    [self cheakRightButton];
}
-(void)initView
{
    self.viewMainHeight.constant = ScreenHeight - NavBarHeight;
    self.scrMain.scrollEnabled = NO;
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(120), 70);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tabView.scrollEnabled =  NO;
    self.tabView.sectionIndexBackgroundColor = DClear;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcSetReminderWater" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.viewMain addSubview:self.tabView];
    [self.viewMain insertSubview:self.tabView belowSubview:lblNoData];
    if(!self.arrData.count) lblNoData.hidden = NO;
    
    __block vcRemindTimeEdit *blockSelf = self;
    NextWaitInMain(
           [blockSelf initBigView];
           [blockSelf initDatePickerView];);
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self checkLink]) {
        self.tabView.userInteractionEnabled = NO;
    }
}

-(void)dealloc
{
    [self.ViewEffectHead removeFromSuperview];
    [self.ViewEffectBody removeFromSuperview];
    NSLog(@"vcRemindTimeEdit销毁了");
}

-(void)cheakRightButton
{
    if(self.arrData.count < 4)
    {
        [self initRightButton:@"Increase" text:nil];
    }
    else [self initRightButton:nil text:nil];
}

-(void)rightButtonClick
{
    dicEdit = nil;
    [self pickerViewPopAnimationsRelod];
}

-(void)initData
{
    dateLeft = DNow;
    dateRight= [NSDate dateWithTimeInterval:60 * 60 sinceDate:dateLeft];
    [self refreshData];
}

-(void)refreshData
{
    NSArray *arrDataRemindWater;
    NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
    if (dicremindWater && [dicremindWater.allKeys containsObject:self.userInfo.pUUIDString])
        arrDataRemindWater = dicremindWater[self.userInfo.pUUIDString];
    if (arrDataRemindWater.count == 2) {
        arrDataRemindWater = arrDataRemindWater[self.isWork ? 0:1];
    } else 
    {
        NSLog(@"这里出错了 -----------------------");
    }
    
    self.arrData = [[NSMutableArray alloc] init];
    for(int i = 1; i < arrDataRemindWater.count; i++)
    {
        NSDictionary *dicModel = arrDataRemindWater[i];
        if ([dicModel.allKeys[0] integerValue] != [dicModel.allValues[0] integerValue]) {
            [self.arrData addObject:dicModel];
        }
    }
    if (!self.arrData.count)
    {
        if (!lblNoData) {
            lblNoData = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, 30)];
            lblNoData.font = [UIFont systemFontOfSize:14];
            lblNoData.text = kString(@"未设置");
            lblNoData.textAlignment = NSTextAlignmentCenter;
            lblNoData.textColor =  DidConnectColor;
            [self.viewMain addSubview:lblNoData];
        }
        lblNoData.hidden = NO;
    }
    else lblNoData.hidden = YES;
}

-(BOOL)checkLink
{
    if (!self.userInfo.pUUIDString) {
        LMBShow(@"请先连接杯垫");
        return NO;
    }
    else if (![self.Bluetooth.dicConnected.allKeys containsObject:self.userInfo.pUUIDString]) {
        LMBShow(@"请先连接杯垫");
        
        return NO;
    }
    return  YES;
}


-(void)initBigView
{
    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
    _bgView.backgroundColor = DClear;
    
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
    
    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, _bgView.bounds.size.height - 324, _bgView.bounds.size.width, 44)];
    //toolBarView.tag = 453;
    toolBarView.backgroundColor = DidConnectColor;// _1;
    
    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
    [CancelButton addTarget:self action:@selector(pickerViewCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    CancelButton.frame = CGRectMake(10, 0, 80, 44);
    [toolBarView addSubview:CancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
    [confirmButton addTarget:self action:@selector(pickerViewConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    [toolBarView addSubview:confirmButton];
    [_bgView addSubview:toolBarView];
    [self.view addSubview:_bgView];
    
    UILabel *lblStartTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, _bgView.bounds.size.height - 280, ScreenWidth / 2, 40)];
    lblStartTitle.textAlignment = NSTextAlignmentCenter;
    lblStartTitle.textColor = DidConnectColor;
    lblStartTitle.backgroundColor = DWhite;
    lblStartTitle.font = [UIFont systemFontOfSize:14];
    lblStartTitle.text = kString(@"开始时间");
    [self.bgView addSubview:lblStartTitle];
    
    UILabel *lblEndTitle = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2, _bgView.bounds.size.height - 280, ScreenWidth / 2, 40)];
    lblEndTitle.textAlignment = NSTextAlignmentCenter;
    lblEndTitle.textColor = DidConnectColor;
    lblEndTitle.backgroundColor = DWhite;
    lblEndTitle.font = [UIFont systemFontOfSize:14];
    lblEndTitle.text = kString(@"结束时间");
    [self.bgView addSubview:lblEndTitle];
}

//初始化DatePickerView
- (void)initDatePickerView
{
    _datePickerLeft = [[UIDatePicker alloc] init];
    _datePickerLeft.frame = CGRectMake(0, ScreenHeight-256, ScreenWidth / 2, 256 - NavBarHeight);
    
    [_datePickerLeft setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" : @"en_US"]];
    _datePickerLeft.datePickerMode = [DFD isSysTime24] ? UIDatePickerModeCountDownTimer : UIDatePickerModeTime;;
    _datePickerLeft.date = dateLeft;
    _datePickerLeft.backgroundColor = DWhite;
    
    _datePickerRight = [[UIDatePicker alloc] init];
    _datePickerRight.frame = CGRectMake(ScreenWidth / 2, ScreenHeight-256, ScreenWidth / 2, 256 - NavBarHeight);
    [_datePickerRight setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" : @"en_US"]];
    _datePickerRight.datePickerMode = [DFD isSysTime24] ? UIDatePickerModeCountDownTimer : UIDatePickerModeTime;;
    _datePickerRight.date = dateRight;
    _datePickerRight.backgroundColor = DWhite;
    [self.bgView insertSubview:_datePickerLeft atIndex:0];
    [self.bgView insertSubview:_datePickerRight atIndex:0];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self pickerViewDisappear];
}

#pragma mark PickerView取消按钮事件
- (void)pickerViewCancelButtonClick
{
    [self pickerViewDisappear];
}
#pragma mark PickerView确定按钮事件
- (void)pickerViewConfirmButton
{
    NSInteger intervalLeft  = [DFD getIntervalFromTime:self.datePickerLeft.date];
    NSInteger intervalRight = [DFD getIntervalFromTime:self.datePickerRight.date];
    if (intervalLeft > intervalRight) {
        LMBShow(@"起始时间不能小于结束时间");
        return;
    }
    
    BOOL isCheck = YES;
    for (NSDictionary *dic in self.arrData)
    {
        if (dicEdit && [dicEdit.allKeys[0] intValue] == [dic.allKeys[0] intValue]
            && [dicEdit.allValues[0] intValue] == [dic.allValues[0] intValue]) {
            isCheck = YES;
        }
        else if (intervalLeft >= [dic.allValues[0] intValue] || intervalRight <= [dic.allKeys[0] intValue]) {
            isCheck = YES;
        }else
        {
            isCheck = NO;
            break;
        }
    }
    
    if (!isCheck) {
        LMBShow(@"时间段与其他时间段重叠,请重新选择");
    }
    else
    {
        if (!dicEdit)
            [self setWaterRemind:3 isWork:self.isWork obj:@[ @{ @(intervalLeft): @(intervalRight)}] ];
        else
            [self setWaterRemind:3 isWork:self.isWork obj:@[ @{ @(intervalLeft): @(intervalRight)}, dicEdit ]];
        [self.Bluetooth setWaterRemind:3 isWork:self.isWork uuid:self.userInfo.pUUIDString];
        [self pickerViewDisappear];
    }
    
    [self refreshData];
    [self cheakRightButton];
    [self.tabView reloadData];
}

//pickView弹出动画
-(void)pickerViewPopAnimationsRelod
{
    [UIView transitionWithView:_bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         [_bgView setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
         self.ViewEffectHead.alpha = self.ViewEffectBody.alpha = 0.8;
     } completion:^(BOOL finished) {}];
}

- (void)pickerViewDisappear
{
    [UIView transitionWithView:_bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [_bgView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
        self.ViewEffectHead.alpha = self.ViewEffectBody.alpha = 0;
    } completion:^(BOOL finished) {}];
}



#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcSetReminderWater *cell = [tvcSetReminderWater cellWithTableView:tableView];
    cell.lblNumber.text = [NSString stringWithFormat:@"%ld", (long)(indexPath.row + 1)];
    NSDictionary *dicModel = self.arrData[indexPath.row];
    cell.lblStart.text = [DFD getTimeStringFromInterval:[(NSNumber *)dicModel.allKeys[0] intValue]];
    cell.lblEnd.text   = [DFD getTimeStringFromInterval:[(NSNumber *)dicModel.allValues[0] intValue]];
    cell.selectedBackgroundView.backgroundColor = DClear;
    MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
    cell.rightButtons = @[btnDelete];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    __weak vcRemindTimeEdit *blockSelf = self;
    btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
    {
        NSDictionary *dicModel = blockSelf.arrData[indexPath.row];
        [blockSelf setWaterRemind:3 isWork:blockSelf.isWork obj:@[ @{ @1440:@1440 }, dicModel ]];
        [blockSelf.Bluetooth setWaterRemind:3 isWork:blockSelf.isWork uuid:blockSelf.userInfo.pUUIDString];
        [blockSelf refreshData];
        [blockSelf.tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        return NO;
    };
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    dicEdit = self.arrData[indexPath.row];
    dateLeft = [DFD getTimeFromInterval:[dicEdit.allKeys[0] intValue]];
    dateRight = [DFD getTimeFromInterval:[dicEdit.allValues[0] intValue]];
    self.datePickerLeft.date = dateLeft;
    self.datePickerRight.date = dateRight;
    [self pickerViewPopAnimationsRelod];
}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        NSDictionary *dicModel = self.arrData[indexPath.row];
//        [self setWaterRemind:3 isWork:self.isWork obj:@[ @{ @1440:@1440 }, dicModel ]];
//        [self.Bluetooth setWaterRemind:3 isWork:self.isWork uuid:self.userInfo.pUUIDString];
//        [self refreshData];
//        [self.tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        [tableView endUpdates];
//    }
//}
//
////修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kString(@"删除");
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
