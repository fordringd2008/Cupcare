//
//  vcSet.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcSet.h"
#import "TAlertView.h"

@interface vcSet ()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    BOOL            isLight;
    BOOL            isSound;
    BOOL            isNoDisturb;
    NSDate *        beginTime;
    NSDate *        endTime;
    BOOL            isUnit;
    
    NSInteger       selectedPickIndex;    // pick选中的索引
    NSInteger       currentIndex;         // 当前选中的索引  1 : 开始时间  2： 结束时间  3 ： 单位
}


@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;

@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIView *viewSecond;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabel;
@property (weak, nonatomic) IBOutlet UILabel *lblPName;
@property (weak, nonatomic) IBOutlet UIButton *btnBinding;
@property (weak, nonatomic) IBOutlet UILabel *lblBinding;


@property (weak, nonatomic) IBOutlet UISwitch *swtLight;

@property (weak, nonatomic) IBOutlet UIButton *btnRemindTime;
@property (weak, nonatomic) IBOutlet UIButton *btnCorrect;

@property (weak, nonatomic) IBOutlet UISwitch *swtSound;
@property (weak, nonatomic) IBOutlet UIButton *btnUnit;
@property (weak, nonatomic) IBOutlet UIButton *btnAbout;
@property (weak, nonatomic) IBOutlet UILabel *lblPromt;
@property (weak, nonatomic) IBOutlet UILabel *lblUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblCorrect;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBindingWidth;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPNameTitleTop;// 5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPNameTop; //5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line1Top; //5
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnBindTop; //15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblLightTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swt1Top; // 10
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line2Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblSoundTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *swt2Top; // 10
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line3Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNoTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight; // 285
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblUnitTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *line5Top; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblBarRemindTop; // 15
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSecondHeight; // 100
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewThirdHeight; // 50

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCorrectBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCorrectTop;



@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (nonatomic, strong) NSArray                       *arrUnits;


@end

@implementation vcSet

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"vcSet viewDidLoad");
    [self initLeftButton:nil text:@"设置"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [self initView];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self btnBackToWhite];
    _btnBinding.layer.borderWidth = 1;
    _btnBinding.layer.borderColor = DLightGray.CGColor;
    if(self.userInfo.pUUIDString)
    {
        _lblBinding.text = kString(@"解绑");
        _lblBinding.textColor = DLightGray;
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(235, 235, 235)] forState:UIControlStateNormal];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
        _btnBinding.tag = 10;
        _lblPName.text = self.userInfo.pName;
    }
    else
    {
        _lblBinding.text = kString(@"绑定");
        _lblBinding.textColor = DWhite;
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(50, 222, 248)] forState:UIControlStateNormal];
        [_btnBinding setBackgroundImage:[UIImage imageFromColor:RGB(30, 202, 248)] forState:UIControlStateHighlighted];
        _btnBinding.tag = 11;
        _lblPName.text = kString(@"未绑定");
    }
    
    [self.btnRemindTime setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
}

-(void)dealloc
{
    [self.ViewEffectBody removeFromSuperview];
    [self.ViewEffectHead removeFromSuperview];
    NSLog(@"vcSet 被释放");
}


-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initData
{
    __block vcSet *blockSelf = self;
    RequestCheckNoWaring(
           [net getUserSys:blockSelf.userInfo.access];,
           [blockSelf dataSuccessBack_getUserSys:dic];);
    [self refreshData];
}

-(void)refreshData
{
    _arrUnits = @[ kString(@"公制"), kString(@"英制") ];
    
    // 读取设备信息 灯光和 声音后， 刷新界面
    isLight = [self.userInfo.swithLight boolValue] && self.userInfo.pUUIDString;
    isSound = [self.userInfo.swithSound boolValue] && self.userInfo.pUUIDString;
    isNoDisturb = [self.userInfo.swithNoDisturb boolValue];
    NSInteger beginHour = [self.userInfo.noDisturbStart integerValue];
    NSInteger endHour = [self.userInfo.noDisturbEnd integerValue];
    beginTime = [DFD getDateFromArr:@[ @(beginHour), @0, @0, @0]];
    endTime = [DFD getDateFromArr:@[ @(endHour), @0, @0, @0]];
    isUnit = [self.userInfo.unit boolValue];
}

-(void)refreshView
{
    [_swtLight setOn:isLight];
    [_swtSound setOn: isSound];
    _lblUnit.text = _arrUnits[isUnit ? 0 : 1];
}

-(void)initView
{
//    self.scrMain.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    
    CGFloat contentHeight;
    if (IPhone4) contentHeight = 490;
    else if (IPhone5) contentHeight = 568-NavBarHeight+16;
    else if (IPhone6) contentHeight = 667-2*NavBarHeight+16;
    else if (IPhone6P) contentHeight = 736-2*NavBarHeight+16;
    
    self.viewMainHeight.constant = contentHeight;
    
    
    _viewFirstHeight.constant = Bigger(RealHeight(520), 260);//RealHeight(580);
    _viewSecondHeight.constant = Bigger(RealHeight(200), 100);
    _viewThirdHeight.constant = Bigger(RealHeight(100), 50);
    
    _lblPNameTitleTop.constant = _lblPNameTop.constant = _line1Top.constant = (Bigger(RealHeight(120), 57) - 42 ) / 3.0;
    _btnBindTop.constant = (Bigger(RealHeight(120), 57) - 30) / 2.0;
    _swt1Top.constant = _swt2Top.constant = (Bigger(RealHeight(100), 51) - 30) / 2.0;
    _btnCorrectBottom.constant = _btnCorrectTop.constant =  _lblLightTop.constant = _lblSoundTop.constant = _lblNoTop.constant = _line2Top.constant = _line3Top.constant =  (Bigger(RealHeight(100), 51) - 21) / 2.0;
    
    
    
    _lblUnitTop.constant = _line5Top.constant = _lblBarRemindTop.constant = (Bigger(RealHeight(200), 100) - 43) / 4.0;

    _btnBindingWidth.constant = [DFD getLanguage] == 1 ? 60 : 100;
    
    NSString *notiText = [DFD isAllowedNotification] ? @"已开启":@"已关闭";
    NSArray *arr = @[@"设备名称",@"设备灯光",@"设备声音",@"喝水提醒时间",@"单位",@"通知栏提醒",@"关于",notiText];
    for (int i = 0; i < _arrLabel.count; i++)
    {
        UILabel *lbl = _arrLabel[i];
        lbl.text = kString(arr[i]);
    }
    _btnBinding.layer.cornerRadius = 10;
    [_btnBinding.layer setMasksToBounds:YES];
    
    self.lblCorrect.text = kString(@"杯垫校准");
    
    _lblPromt.text = !isGift ? kString(@"如果要关闭或者开启接受消息通知,请在iPhone的'设置'—'通知'中,找到'Cupcare'进行更改") : kString(@"如果要关闭或者开启接受消息通知,请在iPhone的'设置'—'通知'中,找到'麦可杯垫'进行更改");
    
    [self.btnUnit setBackgroundImage:[UIImage imageFromColor:DButtonCurrentColor] forState:UIControlStateHighlighted];
    [self.btnAbout setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    [self.btnRemindTime setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    [self.btnCorrect setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
        
    [self refreshView];
    
    __block vcSet *blockSelf = self;
    NextWaitInMain(
           [blockSelf initViewCover:300];
           [blockSelf initPickerView];);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if([segue.identifier isEqualToString:@""])
//    {
//        
//    }
//}



- (IBAction)btnTouchDown:(UIButton *)sender
{
//    if ([sender isEqual:self.btnCorrect]) {
//        return;
//    }
//    [sender setBackgroundImage:[UIImage imageFromColor:DButtonCurrentColor] forState:UIControlStateNormal];
//    __weak UIButton *blockSender = sender;
//    NextWait(
//         [blockSender setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];, 1);
}



- (IBAction)btnClick:(UIButton *)sender
{
    [self btnBackToWhite];
    // 10 解绑  11 绑定  2 喝水提醒时间  4 单位 5 关于
    //NSLog(@"sender.tag = %d", sender.tag);
    
    switch (sender.tag)
    {
        case 10:        
        {
            TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定解除绑定吗?"];
            [alert showWithActionSure:^
             {
                 self.userInfo.pUUIDString = self.userInfo.pName = nil;
                 DBSave;
                 [self.Bluetooth setValue:[[NSMutableDictionary alloc] init] forKey:@"dicSysData"];
                 SetUserDefault(isNotRealNewBLE, @0);
                 SetUserDefault(IndexTabelReload, @YES);
                 
                 // 设置最后更新时间为昨天
                 [DFD setLastSysDateTime:[NSDate dateWithTimeIntervalSinceNow:-24*60*60] access:self.userInfo.access];
                 
                 RemoveUserDefault(isFirstReadTimeSection);
                 [self refreshData];    // 解除绑定后，  声音和灯光开关  关掉
                 [self refreshView];
                 
                 // 清除当天详细数据
                 [DataRecord MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@", self.userInfo.access, @(DDYear), @(DDMonth), @(DDDay)]];
                 [SynData MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and year == %@ and month == %@ and day == %@", self.userInfo.access, @(DDYear), @(DDMonth), @(DDDay)] inContext:DBefaultContext];
                 
                 [DFD clearCBP];
                 
                 NSLog(@"禁用");
                 self.btnBinding.enabled = NO;
                 __block vcSet *blockSelf = self;
                 NextWaitInMainAfter(
                          NSLog(@"开启禁用");
                          blockSelf.btnBinding.enabled = YES;, 3);
                 DBSave;
                 
                 if (self.Bluetooth.isLink)
                 {
                     [self.Bluetooth stopLink:nil];
                     self.Bluetooth.isFailToConnectAgain = NO;
                     self.Bluetooth.isBeginOK = NO;
                     self.Bluetooth.isReRead = YES;
                     [self.Bluetooth begin:@""];
                 }
                 [self viewWillAppear:NO];
             } cancel:^{}];
        }
            break;
        case 11:
        {
            NSLog(@"self : %@", self);
            if ([self isKindOfClass:[vcSet class]]) {
                [self performSegueWithIdentifier:@"set_to_search" sender:nil];
            }
        }
            break;
        case 2:
            if (self.Bluetooth.isLink) {
                [self performSegueWithIdentifier:@"set_to_remindTime" sender:nil];
            }else
            {
                LMBShow(@"请先连接杯垫");
            }
            break;
        case 3:
        {
            if (self.Bluetooth.isLink) {
                [self performSegueWithIdentifier:@"set_to_correct" sender:nil];
            }else
            {
                LMBShow(@"请先连接杯垫");
            }
        }
            break;
        case 4:
        {
            _pickView.delegate   = self;
            _pickView.dataSource = self;
            NSInteger ind = isUnit ? 0 : 1;
            [_pickView selectRow:ind inComponent:0 animated:NO];
            selectedPickIndex = ind;
            currentIndex = 3;
            [self showViewCover];
        }
            break;
        case 5:
            [self performSegueWithIdentifier:@"set_to_about" sender:nil];
            break;
    }
}

-(void)btnBackToWhite
{
    [self.btnAbout setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnUnit setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [self.btnRemindTime setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
}

//-(void)initBigView
//{
//    _bgView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight)];
//    _bgView.backgroundColor = DClear;
//    
//    UIView *toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, _bgView.bounds.size.height - 300, _bgView.bounds.size.width, 44)];
//    toolBarView.backgroundColor = DidConnectColor;
//    
//    UIButton *CancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [CancelButton setTitle:kString(@"取消") forState:UIControlStateNormal];
//    [CancelButton addTarget:self action:@selector(pickerViewCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
//    CancelButton.frame = CGRectMake(10, 0, 80, 44);
//    [toolBarView addSubview:CancelButton];
//    
//    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [confirmButton setTitle:kString(@"确定") forState:UIControlStateNormal];
//    confirmButton.frame = CGRectMake(ScreenWidth - 90, 0, 80, 44);
//    [confirmButton addTarget:self action:@selector(pickerViewConfirmButton) forControlEvents:UIControlEventTouchUpInside];
//    [toolBarView addSubview:confirmButton];
//    [_bgView addSubview:toolBarView];
//    [self.view addSubview:_bgView];
//}


-(void)initPickerView
{
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickView.backgroundColor = DWhite;
    [self.ViewCover addSubview:_pickView];
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self pickerViewDisappear];
//}
//
//#pragma mark PickerView取消按钮事件
//- (void)pickerViewCancelButtonClick
//{
//    [self pickerViewDisappear];
//}



//#pragma mark PickerView确定按钮事件
//- (void)pickerViewConfirmButton
//{
//    //  1 : 开始时间  2： 结束时间  3 ： 单位
//    switch (currentIndex) {
//        case 3:
//        {
//            isUnit = selectedPickIndex == 0;
//            __weak vcSet *blockSelf = self;
//            RequestCheckAfter(
//                  [net updateSysSetting:blockSelf.userInfo.access sys_unit:isUnit sys_notify_status:[DFD isAllowedNotification]];,
//                  [blockSelf dataSuccessBack_updateSysSetting:dic];);
//        }
//            break;
//    }
//    [self pickerViewDisappear];
//}

//pickView弹出动画
//-(void)pickerViewPopAnimationsRelod:(BOOL)isPicker
//{
//    [UIView transitionWithView:_bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
//     {
//         [_bgView setFrame:CGRectMake(0 , 0, ScreenWidth, ScreenHeight)];
//     } completion:^(BOOL finished) {}];
//}

//- (void)pickerViewDisappear
//{
//    [self btnBackToWhite];
//    [UIView transitionWithView:_bgView duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
//        [_bgView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, ScreenHeight)];
//    } completion:^(BOOL finished) {}];
//}



#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return  2;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return  _arrUnits[row];
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    selectedPickIndex = row;
}

- (IBAction)swtChange:(UISwitch *)sender
{
    if (!self.userInfo.pUUIDString || !self.Bluetooth.isLink)
    {
        LMBShow(@"请先连接杯垫");
        [sender setOn:!sender.isOn];
        return;
    }
    
    NSString *strPrompt;
    switch (sender.tag)
    {
        case 1:
            isLight = sender.isOn;
            self.userInfo.swithLight = @(isLight);
            strPrompt = isLight ? @"灯光开启" : @"灯光关闭";
            break;
        case 2:
            isSound = sender.isOn;
            self.userInfo.swithSound = @(isSound);
            strPrompt = isSound ? @"声音开启" : @"声音关闭";
            break;
        case 3:
            isNoDisturb = sender.isOn;
            self.userInfo.swithNoDisturb = @(isNoDisturb);
            break;
            
        default:
            break;
    }
    DBSave;
    
    __block vcSet *blockSelf = self;
    NextWaitInGlobal(
         [blockSelf.Bluetooth setUserinfoAndRead:blockSelf.userInfo.pUUIDString];
         [blockSelf resetSysData];
         NextWaitInMain(LMBShowInBlock(strPrompt);););
}

-(void)resetSysData
{
    NSArray *arrSysData = @[ @(isLight), @(isSound), @(isNoDisturb), @([[beginTime clearTimeZone] getFromDate:4]), @([[endTime clearTimeZone] getFromDate:4])];
    SetUserDefault(SysData, arrSysData);
}

-(void)dataSuccessBack_getUserSys:(NSDictionary *)dic
{
    NSInteger status = [dic[@"status"] integerValue];
    if (status)
    {
        NSLog(@"用户没有上传， 使用默认的");
    }
    else
    {
        self.userInfo.unit = @([dic[@"sys_unit"] integerValue] == 1);
        DBSave;
        [self refreshView];
    }
}


-(void)dataSuccessBack_updateSysSetting:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        self.userInfo.unit = @(isUnit);
        DBSave;
        [self refreshView];
    }
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 250) {
        __block vcSet *blockSelf = self;
        NextWaitInMain(
           [blockSelf refreshData];
           [blockSelf refreshView];);
    }
    
}


-(void)toolOKBtnClickAnimation
{
    if (currentIndex == 3) {
        isUnit = selectedPickIndex == 0;
        __block vcSet *blockSelf = self;
        RequestCheckAfter(
                          [net updateSysSetting:blockSelf.userInfo.access sys_unit:blockSelf->isUnit sys_notify_status:[DFD isAllowedNotification]];,
                          [blockSelf dataSuccessBack_updateSysSetting:dic];);
    }
}

-(void)toolCancelBtnClickCompleted
{
    _pickView.delegate = nil;
    _pickView.delegate = nil;
}




























@end
