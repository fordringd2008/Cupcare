//
//  vcRemindTime.m
//  Coasters
//
//  Created by 丁付德 on 15/10/20.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcRemindTime.h"
#import "vcRemindTimeEdit.h"
#import "vcWorkDayEdit.h"

@interface vcRemindTime ()
{
    BOOL isWorkOn;
    BOOL isRestOn;
    NSString *strRepeat;                      // 这个是方便传输修改工作日的
    UIView *viewMask;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;

@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UIView *viewSecond;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrlbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewSecondHeight;

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *lblTopArray;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *arrButton;
@property (weak, nonatomic) IBOutlet UISwitch *swtWork;
@property (weak, nonatomic) IBOutlet UISwitch *swtRest;
@property (weak, nonatomic) IBOutlet UILabel *lblPrompt;



@property (strong, nonatomic) NSArray *arrData;                 // 数据源
@property (strong, nonatomic) NSMutableArray *arrDataTitle;            // 数据源  label集合的数据源

@end

@implementation vcRemindTime

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButton:nil text:@"设置"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
    [self inintView];
    for (UIButton *btn in self.arrButton)
        [btn setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    
    [self.Bluetooth readChara:self.userInfo.pUUIDString charUUID:RW_DrinkWaterToRemindTimeSection_UUID];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkLink];
//    if (!viewMask)  viewMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];      // 添加遮罩
//    [self.view addSubview:viewMask];
//    NextWait([viewMask removeFromSuperview];, 1);
}


-(void)initData
{
    self.arrDataTitle = [@[ kString(@"我的工作日")
                            , kString(@"未设置")
                            , kString(@"工作日")
                            , kString(@"未设置")
                            , [NSString stringWithFormat:@"%@ %@", kString(@"时间段:"), kString(@"未设置")]
                            , kString(@"休息日")
                            , kString(@"未设置")
                            , [NSString stringWithFormat:@"%@ --", kString(@"时间段:")] ] mutableCopy];
    
    NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
    if (dicremindWater && [dicremindWater.allKeys containsObject:self.userInfo.pUUIDString])
        self.arrData = dicremindWater[self.userInfo.pUUIDString];
    
    [self refreshView];
}

-(void)refreshView
{
    if (self.arrData.count == 2)
    {
        NSArray *workArray = self.arrData[0];
        NSArray *restArray = self.arrData[1];
        
        NSString *strRepeatWork = workArray[0];
        NSString *strRepeatRest = restArray[0];
        NSMutableString *strWorkRepeatShow = [NSMutableString string];
        NSMutableString *strRestRepeatShow = [NSMutableString string];
        NSArray *workRepeat = [strRepeatWork componentsSeparatedByString:@"-"];
        NSArray *restRepeat = [strRepeatRest componentsSeparatedByString:@"-"];
        
        strRepeat = strRepeatWork;
        
        isWorkOn = [workRepeat[0] boolValue];
        
        if ([workRepeat[1] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周日")]];
        if ([workRepeat[2] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周一")]];
        if ([workRepeat[3] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周二")]];
        if ([workRepeat[4] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周三")]];
        if ([workRepeat[5] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周四")]];
        if ([workRepeat[6] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周五")]];
        if ([workRepeat[7] intValue])
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周六")]];
        if (!strWorkRepeatShow.length)
            [strWorkRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"未设置")]];
        else if(![workRepeat containsObject:@"0"])
            strWorkRepeatShow = [NSMutableString stringWithFormat:kString(@"每天")];
        self.arrDataTitle[1] = self.arrDataTitle[3] = [NSString stringWithFormat:@"%@", strWorkRepeatShow];
        
        
        NSMutableString *strWork = [[NSMutableString alloc] init];
        for(int i = 1; i < workArray.count; i++)
        {
            NSDictionary *dicWorkTimes = workArray[i];
            NSString *strTimeBegin, *strTimeEnd;
            strTimeBegin = [DFD getTimeStringFromInterval:[(NSNumber *)dicWorkTimes.allKeys[0] intValue]];
            strTimeEnd   = [DFD getTimeStringFromInterval:[(NSNumber *)dicWorkTimes.allValues[0] intValue]];
            if (![strTimeBegin isEqualToString:strTimeEnd])
                [strWork appendFormat:@" %@-%@", strTimeBegin, strTimeEnd];
        }
        self.arrDataTitle[4] = [NSString stringWithFormat:@"%@%@", kString(@"时间段:"), strWork.length ? strWork : kString(@"未设置") ];
        
        
        isRestOn = [restRepeat[0] boolValue];
        
        if ([restRepeat[1] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周日")]];
        if ([restRepeat[2] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周一")]];
        if ([restRepeat[3] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周二")]];
        if ([restRepeat[4] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周三")]];
        if ([restRepeat[5] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周四")]];
        if ([restRepeat[6] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周五")]];
        if ([restRepeat[7] intValue])
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"周六")]];
        if (!strRestRepeatShow.length)
            [strRestRepeatShow appendString:[NSString stringWithFormat:@" %@", kString(@"未设置")]];
        else if(![workRepeat containsObject:@"0"])
            strRestRepeatShow = [NSMutableString stringWithFormat:kString(@"每天")];
        self.arrDataTitle[6] = [NSString stringWithFormat:@"%@", strRestRepeatShow];
        
        NSMutableString *strRest = [[NSMutableString alloc] init];
        for(int i = 1; i < restArray.count; i++)  // 这里  
        {
            NSDictionary *dicRestTimes = restArray[i];
            NSString *strTimeBegin, *strTimeEnd;
            strTimeBegin = [DFD getTimeStringFromInterval:[(NSNumber *)dicRestTimes.allKeys[0] intValue]];
            strTimeEnd   = [DFD getTimeStringFromInterval:[(NSNumber *)dicRestTimes.allValues[0] intValue]];
            if (![strTimeBegin isEqualToString:strTimeEnd])
                [strRest appendFormat:@" %@-%@", strTimeBegin, strTimeEnd];
        }
        self.arrDataTitle[7] = [NSString stringWithFormat:@"%@%@", kString(@"时间段:"), strRest.length ? strRest : kString(@"未设置") ];
    }
    
     __block vcRemindTime *blockSelf = self;
    NextWaitInMain(
       for (int i = 0; i < blockSelf.arrDataTitle.count; i++) {
           UILabel *lbl = blockSelf.arrlbl[i];
           lbl.text = blockSelf.arrDataTitle [i];
       }
       [blockSelf.swtWork setOn:isWorkOn];
       [blockSelf.swtRest setOn:isRestOn];
    );
}


-(void)inintView
{
    self.viewMainHeight.constant = ScreenHeight -  NavBarHeight;
    self.scrMain.scrollEnabled = NO;
    self.viewFirstHeight.constant = Bigger(RealHeight(145), 70);
    self.viewSecondHeight.constant = self.viewFirstHeight.constant * 2;

    for (NSLayoutConstraint *la in self.lblTopArray)
        la.constant = (Bigger(RealHeight(145), 70) - 42 ) / 3.0;
    
    self.lblPrompt.text = kString(@"友情提示:如果您长时间忘记喝水,杯垫会在设置的时间段内提醒您.");
    
}
- (IBAction)btnTouchDown:(UIButton *)sender
{
    for (UIButton *btn in self.arrButton)
        [btn setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageFromColor:DButtonCurrentColor] forState:UIControlStateNormal];
     __block UIButton *blocksender = sender;
    NextWaitInMainAfter(
             [blocksender setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];, 1);
}

- (IBAction)btnClick:(UIButton *)sender
{
    NSLog(@"btnClick");
    [sender setBackgroundImage:[UIImage imageFromColor:DClear] forState:UIControlStateNormal];
    switch (sender.tag) {
        case 1:
            [self performSegueWithIdentifier:@"remindTime_to_repeat" sender:nil];
            break;
        case 2:
            [self performSegueWithIdentifier:@"remindTime_to_edit" sender:@YES];
            break;
        case 3:
            [self performSegueWithIdentifier:@"remindTime_to_edit" sender:@NO];
            break;
            
        default:
            break;
    }
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 208)
    {
        __block vcRemindTime *blockSelf = self;
        NextWaitInMain(
            [blockSelf initData];
        );
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"remindTime_to_edit"])
    {
        vcRemindTimeEdit *vc = (vcRemindTimeEdit *)segue.destinationViewController;
        vc.isWork = [sender boolValue];
    }
    else if ([segue.identifier isEqualToString:@"remindTime_to_repeat"])
    {
        vcWorkDayEdit *vc = (vcWorkDayEdit *)segue.destinationViewController;
        vc.strRepeat = strRepeat;
    }
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


- (IBAction)scwtChange:(UISwitch *)sender
{
    if ([self isHaveDay:sender.tag == 1])
    {
        if (![self checkLink]) {
            [sender setOn:!sender.isOn];
        }
        
        //   发送指令
        [self setWaterRemind:1 isWork:(sender.tag == 1) obj:@(sender.isOn)];
        [self.Bluetooth setWaterRemind:1 isWork:(sender.tag == 1) uuid:self.userInfo.pUUIDString];
    }
    else
    {
        if (sender.tag == 1) {
            NSLog(@"您没有设置工作日");
            LMBShow(@"您没有设置工作日");
        }else{
            NSLog(@"您没有设置休息日");
            LMBShow(@"您没有设置休息日");
        }
        [sender setOn:!sender.isOn];
    }
}


// 是否设置的有  工作日 或者休息日
-(BOOL)isHaveDay:(BOOL)isWork
{
    NSDictionary *dicremindWater = [DFD dataTodic:(NSData *)GetUserDefault(dicRemindWater)];
    if (!dicremindWater) dicremindWater = [[NSDictionary alloc] init];
    NSArray *arrData;
    if (dicremindWater && [dicremindWater.allKeys containsObject:self.userInfo.pUUIDString])
        arrData = dicremindWater[self.userInfo.pUUIDString];
    
    NSString *strRepeat_ = [arrData[isWork ? 0 : 1][0] description];
    NSArray *arrRepeat_ = [strRepeat_ componentsSeparatedByString:@"-"];
    
    
    BOOL isHave = NO;
    for (int i = 1; i < 8; i++)
    {
        if ([arrRepeat_[i] intValue])
        {
            isHave = YES;
            break;
        }
    }
    
    return isHave;
    
}








@end
