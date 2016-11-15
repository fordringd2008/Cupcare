//
//  vcBalance.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBalance.h"
#import "WMGaugeView.h"

//#define innerRingColor              RGBA()
@interface vcBalance ()
{
    BOOL isLeft;                                         // 是否已经离开了页面
    NSTimer *timeRead;                                   // 循环读取数据
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet WMGaugeView *gaugeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UILabel *lblWarn;

@property (assign, nonatomic) CGFloat weightValue;

@end

@implementation vcBalance

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"电子称"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self initView];
    
//#warning    杯垫进入称重模式 5 分钟内,若没有再次“进入称重模式”的命令,则杯垫会自动退出称重模式。APP 若要维持称重模式 超过 5 分钟,则 5 分钟内 APP 必须重新发送“进入称重模式”的命令。
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isLeft = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addObserver:self forKeyPath:@"weightValue" options:NSKeyValueObservingOptionNew context:nil];
    if (self.Bluetooth.isLink) {
        [self.Bluetooth setBalance:self.userInfo.pUUIDString turnON:YES];
        //timeRead = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(read) userInfo:nil repeats:YES];
        __block vcBalance *blockSelf = self;
        timeRead = [NSTimer DF_sheduledTimerWithTimeInterval:0.5 block:^{
            if (!blockSelf->isLeft) {
                [blockSelf.Bluetooth readChara:blockSelf.userInfo.pUUIDString charUUID:R_Balance_RealData_UUID];
            }
            else
            {
                [blockSelf->timeRead DF_stop];
                blockSelf->timeRead = nil;
            }
        } repeats:YES];
        
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    isLeft = YES;
    [[NSNotificationCenter defaultCenter]removeObserver:self.Bluetooth name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    
    [timeRead DF_stop];
    timeRead = nil;
    if (self.Bluetooth.isLink)
        [self.Bluetooth setBalance:self.userInfo.pUUIDString turnON:NO];
}

- (void)dealloc
{
    NSLog(@"vcBalance 被销毁");
    [self.Bluetooth removeObserver:self forKeyPath:@"isLink"];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    printf("按理说是触发home按下\n");
    if (self.Bluetooth.isLink)
    {
        [self.Bluetooth setBalance:self.userInfo.pUUIDString turnON:NO];
        [timeRead DF_pause];
    }
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (self.Bluetooth.isLink)
    {
        [self.Bluetooth setBalance:self.userInfo.pUUIDString turnON:YES];
         __block NSTimer *blockTimer = timeRead;
        NextWaitInMainAfter([blockTimer DF_continue];, 1);
    }
    
}

-(void)read
{
    if (!isLeft) {
        [self.Bluetooth readChara:self.userInfo.pUUIDString charUUID:R_Balance_RealData_UUID];
    }
    else
    {
        [timeRead DF_stop];
        timeRead = nil;
    }
}


-(void)gaugeUpdateTimer:(NSTimer *)timer
{
    self.weightValue = rand()%(int)_gaugeView.maxValue;
}



-(void)initView
{
    //self.view.backgroundColor = DClear;
    self.viewMainHeight.constant = ScreenHeight;
    if (self.Bluetooth.isLink)
    {
        [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
//        self.viewMain.backgroundColor = DidConnectColor_1;
        self.viewMain.backgroundColor = DidConnectColor;
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundImage:DisConnectImg forBarMetrics:UIBarMetricsDefault];
        self.viewMain.backgroundColor = DidDisconnectColor;
    }
    
    [self.Bluetooth addObserver:self forKeyPath:@"isLink" options:NSKeyValueObservingOptionNew context:nil];
    
    _gaugeView.maxValue = 2000.0;
    _gaugeView.scaleDivisions = 4;
    _gaugeView.scaleSubdivisions = 5;
    _gaugeView.scaleStartAngle = 80;    // 偏移量
    _gaugeView.scaleEndAngle = 280;
    _gaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
    _gaugeView.showScaleShadow = NO;
    _gaugeView.scaleFont = [UIFont fontWithName:@"AvenirNext-UltraLight" size:0.055];
    _gaugeView.scalesubdivisionsaligment = WMGaugeViewSubdivisionsAlignmentCenter;
    _gaugeView.scaleSubdivisionsWidth = 0.002;
    _gaugeView.scaleSubdivisionsLength = 0.04;
    _gaugeView.scaleDivisionsWidth = 0.007;
    _gaugeView.scaleDivisionsLength = 0.07;
    _gaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
    _gaugeView.needleWidth = 0.012;
    _gaugeView.needleHeight = 0.4;
    _gaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStyleGradient;
    _gaugeView.needleScrewRadius = 0.05;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (isLeft)return;
    if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isLink"])
    {
        [self changeViewByIsLink:self.Bluetooth.isLink];
    }
    else if ([object isEqual:self] && [keyPath isEqual:@"weightValue"])
    {
        NSString *str = [NSString stringWithFormat:@"%.0fg", self.weightValue];
         __block vcBalance *blockSelf = self;
        NextWaitInMain(
            blockSelf.gaugeView.value = blockSelf.weightValue;
            blockSelf.lblValue.text = str;
                      if(blockSelf.weightValue > 2000)
                           blockSelf.lblWarn.text = kString(@"称重已经达到上线!");
                       else
                            blockSelf.lblWarn.text = @"";
        );
        
    }
}

-(void)changeViewByIsLink:(BOOL)isLink
{
     __block vcBalance *blockSelf = self;
    NextWaitInMain(
       if (isLink)
       {
           blockSelf.viewMain.backgroundColor = DidConnectColor;
           [blockSelf.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
       }
       else
       {
          blockSelf.viewMain.backgroundColor = DidConnectColor;
          [blockSelf.navigationController.navigationBar setBackgroundImage:DisConnectImg forBarMetrics:UIBarMetricsDefault];
       }
    );
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

-(void)CallBack_Data:(int)type uuidString:(NSString *)uuidString obj:(NSObject *)obj
{
    [super CallBack_Data:type uuidString:uuidString obj:obj];
    if (type == 213)
    {
        //NSLog(@"重量是：%@",obj);
        NSNumber *weight = (NSNumber *)obj;
        self.weightValue = [weight doubleValue];;
    }
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
