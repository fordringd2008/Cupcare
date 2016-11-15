//
//  vcClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcClock.h"
#import "vcEditClock.h"
#import "tvcClock.h"

#define bigTimeInterval                        5 * 60  //   大循环间隔时间

@interface vcClock () <tvcClockDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLeft;                                         // 是否已经离开了页面
    NSTimer * timeF;                                     // 循环 读取 硬件
    NSTimer * timeBig;                                   // 大循环
    BOOL isRefresh;                                      // 是否已经刷新
    BOOL isAdd;                                          // 是否是去添加
    UILabel *lblNone;                                    // 没有闹钟
//    NSTimer * timer;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *   viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *               viewMain;
@property (nonatomic, strong) NSMutableArray *              arrData;
@property (nonatomic, strong) IBOutlet UITableView *                 tabView;
@property (weak, nonatomic) IBOutlet UIView *               viewBottom;
@property (weak, nonatomic) IBOutlet UILabel *              lblWarn;

@end

@implementation vcClock

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"vcClock viewDidLoad");
    [self initLeftButton:nil text:@"闹钟"];
    
    
    self.lblWarn.text = kString(@"请先连接杯垫，再进行闹钟设置");
    self.view.backgroundColor = self.viewMain.backgroundColor = self.tabView.backgroundColor = DLightGrayBlackGroundColor;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    isLeft = NO;
    
    [self refreshData];

    [self.Bluetooth addObserver:self forKeyPath:@"isLink" options:NSKeyValueObservingOptionNew context:nil];
    
    [self changeViewByIsLink:self.Bluetooth.isLink];
    
    [self obserToClock];
    timeBig = [NSTimer scheduledTimerWithTimeInterval:bigTimeInterval target:self selector:@selector(obserToClock) userInfo:nil repeats:YES];
    
    if (self.Bluetooth.isLink)  [self.Bluetooth readClock:self.userInfo.pUUIDString];
     __block vcClock *blockSelf = self;
    NextWaitInMainAfter([blockSelf refreshData];, 0.5);
}

-(void)viewWillDisappear:(BOOL)animated
{
    isLeft = YES;
    [timeF DF_stop];
    [timeBig DF_stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self.Bluetooth name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.Bluetooth removeObserver:self forKeyPath:@"isLink"];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    NSLog(@"vcClock 被销毁");
//    [self.Bluetooth removeObserver:self forKeyPath:@"isLink"];
}


-(void)refreshData
{
    if(isRefresh) return;
    [self.arrData removeAllObjects];
    self.arrData = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"type != %@", @0] inContext:DBefaultContext] mutableCopy];
    NSMutableArray *arrIndex = [NSMutableArray new];
    for(int i = 0; i < self.arrData.count; i++)
    {
        Clock *cl = self.arrData[i];
        if (![cl.type boolValue]) {
            [arrIndex addObject:@(i)];
        }
    }
    for (int i = (int)arrIndex.count - 1; i >=0; i--) {
        [self.arrData removeObjectAtIndex:[arrIndex[i] intValue]];
    }
    if (lblNone) [lblNone setHidden:YES];
    
    if (!self.arrData.count)
    {
        NSLog(@"没有闹钟");
        if(!lblNone)
        {
            lblNone = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
            lblNone.textColor = DBlack;
            lblNone.tag = 78;
            lblNone.text = kString(@"未设置");
            lblNone.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            lblNone.textAlignment = NSTextAlignmentCenter;
            
            //        Border(lblNone, DRed);
            lblNone.font = [UIFont systemFontOfSize:16];
//            [self.viewMain addSubview:lblNone];
            [self.view addSubview:lblNone];
        }
        
        [lblNone setHidden:NO];
    }
    
    if (self.arrData.count != 8 && self.Bluetooth.isLink) {
        [self initRightButton:@"Increase" text:nil];
    }else
    {
        [self initRightButton:nil text:nil];
    }
    [self refreshView];
    [self.tabView reloadData];
}

-(void)refreshView
{
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(100), 60);// 60;
    self.tabView.showsVerticalScrollIndicator = NO;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcClock" bundle:nil] forCellReuseIdentifier:@"tvcClock"];
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view.backgroundColor = self.tabView.backgroundColor;
        view;
    });
    
}

-(void)changeViewByIsLink:(BOOL)isLink
{
   if (isLink)
   {
       self.tabView.userInteractionEnabled = YES;
        __block vcClock *blockSelf = self;
       NextWaitInMain(
              [blockSelf obserToClock];
              [blockSelf.viewBottom setHidden:YES];
              [blockSelf.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
       );
   }
   else
   {
       self.tabView.userInteractionEnabled = NO;
       __block vcClock *blockSelf = self;
       NextWaitInMain(
              [blockSelf.viewBottom setHidden:NO];
              [blockSelf.navigationController.navigationBar setBackgroundImage:DisConnectImg forBarMetrics:UIBarMetricsDefault];
       );
   }
}


// 监视 所有本地 不重复的闹钟， 当 时间已过， 就关闭掉  reload
-(void)obserToClock
{
    if( !self.Bluetooth.isLink || timeF) return;        // 外面 至少5分钟内  进入此方法一次
    for (int i = 0; i < self.arrData.count; i++)        // 判断时间， 在时间相差5分钟内 开启 循环读取
    {
        Clock *clock = self.arrData[i];
        
        NSDate *dateFrom = [[DFD getDateFromArr:@[ clock.hour, clock.minute, @0, @0]] clearTimeZone]; // 今天的时间
        NSTimeInterval interval = [dateFrom timeIntervalSinceDate:DNow];  // >0 证明 这个闹钟还没响 < 5 * 60  将在5分钟之内响
        //NSLog(@"interval = %f", interval);
        if ([clock.repeat isEqualToString:@"0-0-0-0-0-0-0"] && [clock.isOn boolValue] && interval > 0 && interval <= 5 * 60)
        {
            timeF = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(read) userInfo:nil repeats:YES];
            break;
        }
    }
}

-(void)read
{
    BOOL isAllOff = YES;  // if (!isAllOff) [timeF stop];
    for (int i = 0; i < self.arrData.count; i++)
    {
        Clock *clock = self.arrData[i];
        if ([clock.isOn boolValue]) {
            isAllOff = NO;
            break;
        }
    }
    
    if (isAllOff)
    {
        [timeF DF_stop];
        timeF = nil;
    }
    
    [self.Bluetooth setValue:@(YES) forKey:@"isOnlySetClock"];
    [self.Bluetooth readClock:self.userInfo.pUUIDString];
     __block vcClock *blockSelf = self;
    NextWaitInMainAfter([blockSelf refreshData];, 1);
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcClock *cell = [tvcClock cellWithTableView:tableView];
    Clock *model = self.arrData[indexPath.row];
    cell.imv1.highlightedImage =  [UIImage imageNamed:@"lightGray.png"];
    cell.model = model;
    cell.delegate_S = self;
    MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
    cell.rightButtons = @[btnDelete];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    __weak vcClock *blockSelf = self;
    btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
    {
        Clock *cl = blockSelf.arrData[indexPath.row];
        cl.type = @0;
        cl.repeat = @"0-0-0-0-0-0-0";
        cl.hour = @0;
        cl.minute = @0;
        cl.isOn = @NO;
        [cl perfect];
        DBSave;
        [blockSelf.Bluetooth setClock:blockSelf.userInfo.pUUIDString isFirst:([cl.iD intValue] < 4)];
        [blockSelf refreshData];
        return NO;
    };

    return cell;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Clock *model = self.arrData[indexPath.row];
    if (self.Bluetooth.isLink)
    {
        isAdd = NO;
        [self performSegueWithIdentifier:@"clock_to_editClock" sender:model];
    }
}

//
//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        Clock *cl = self.arrData[indexPath.row];
//        cl.type = @0;
//        cl.repeat = @"0-0-0-0-0-0-0";
//        cl.hour = @0;
//        cl.minute = @0;
//        cl.isOn = @NO;
//        [cl perfect];
//        DBSave;
//        [self.Bluetooth setClock:self.userInfo.pUUIDString isFirst:([cl.iD intValue] < 4)];
//        [self refreshData];
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


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"clock_to_editClock"])
    {
        vcEditClock *vc = (vcEditClock *)segue.destinationViewController;
        vc.isAdd = isAdd;
        vc.clock = sender;
    }
}


#pragma mark tvcClockDelegate
-(void)switchClock:(tvcClock *)sender
{
    Clock *cl = sender.model;
    NSLog(@"cl.isOn = %@, %@, 时间：%@, type : %@", cl.isOn, cl.strRepeat, cl.strTime, cl.type);
    cl.isOn = @(![cl.isOn boolValue]);
    DBSave;
    
    //[self.Bluetooth setClockAndRead:self.userInfo.pUUIDString isFirst:([cl.iD intValue] < 4)];
    [self.Bluetooth setClock:self.userInfo.pUUIDString isFirst:([cl.iD intValue] < 4)];
    __block vcClock *blockSelf = self;
    NextWaitInMainAfter(
             [blockSelf refreshData];
             [blockSelf obserToClock];
             , 1);
    
}

/* KVO function， 只要object的keyPath属性发生变化，就会调用此函数*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (isLeft)return;
    if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isLink"])
        [self changeViewByIsLink:self.Bluetooth.isLink];
}


-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 210)
    {
        __block vcClock *blockSelf = self;
        NextWaitInMain(
               NSLog(@"回调回来了");
               [blockSelf refreshData];
               blockSelf.tabView.userInteractionEnabled = YES;);
    }
}

-(void)rightButtonClick
{
//    Clock *newClock = [[Clock findAllSortedBy:@"iD" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"(strTime == %@) and (isOn == %@)", @" 00:00", @(NO)] inContext:DBefaultContext] firstObject];
    isAdd = YES;
    NSLog(@"跳转时间");
    [self performSegueWithIdentifier:@"clock_to_editClock" sender:nil];
}



@end
