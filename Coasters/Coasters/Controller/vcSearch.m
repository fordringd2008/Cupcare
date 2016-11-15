//
//  vcSearch.m
//  Coasters
//
//  Created by 丁付德 on 15/8/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcSearch.h"
#import "tvcSearch.h"
#import "SkyWaitingView.h"
#import "TAlertView.h"

@interface vcSearch () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
{
    NSDate *beginDate;
    BOOL swtRefresh;                            // 刷新开关
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIView *                   viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewMainHeight;
@property (weak, nonatomic) IBOutlet UILabel *                  lbltitle;
@property (weak, nonatomic) IBOutlet UIView *                   viewCercle;

@property (weak, nonatomic) IBOutlet UIView *                   viewTable;
@property (weak, nonatomic) IBOutlet UIButton *                 btnSearchAgain;


@property (weak, nonatomic) IBOutlet UIButton *                 btnBack;
@property (weak, nonatomic) IBOutlet UILabel *                  lblCup;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblTilteTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewCercleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       viewTableHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       btnBackHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *       lblTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnSearchAgainHeight;




@property (strong, nonatomic) SkyLabelWaitingView *             lv;                  // 大菊花
@property (strong, nonatomic) UITableView *                     tabView;
@property (strong, atomic) NSMutableDictionary *                dicData;             // 数据源

@end

@implementation vcSearch

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self beginSearchAgain];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkLink) userInfo:nil repeats:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [timer DF_stop];
    timer = nil;
    if (self.lv) {
        [self.lv stopWithHidRing:YES];   //  这里改动了
    }
    self.Bluetooth.delegate = nil;
    [super viewWillDisappear:animated];
}

-(void)dealloc{
    NSLog(@"vcSearch 被销毁了");
}


-(void)initData
{

}

-(void)initView
{
    _viewMainHeight.constant = ScreenHeight;
    _lblTilteTop.constant = RealHeight(210);

    
    _viewCercleTop.constant = RealHeight(110);
    _lblTitleHeight.constant = RealHeight(75);
    
    _btnBackHeight.constant = 30;
    _btnSearchAgainHeight.constant = 40;
    _viewTableHeight.constant =  ScreenHeight - RealHeight(395) - _btnBackHeight.constant - _btnSearchAgainHeight.constant - 40;
    _lblCup.text = [DFD getIOSName];
    
    self.lv = [[SkyLabelWaitingView alloc] initWithFrame:CGRectMake(0, 0, RealWidth(300), RealWidth(300))];
    self.lv.ringColor = [UIColor whiteColor];
    self.lv.ringWidth = 5.f;
    self.lv.r = (self.lv.bounds.size.height - self.lv.ringWidth ) / 2 ;
    [self.viewCercle insertSubview:self.lv belowSubview:_lblCup];
    [self.lv start];
    
    self.viewCercle.hidden = YES;
    
    _lbltitle.text = kString(@"搜索杯垫");
    
    [_btnSearchAgain setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor1] forState:UIControlStateNormal];
    [_btnSearchAgain setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor2 ] forState:UIControlStateHighlighted];
    
    [_btnSearchAgain setTitle:kString(@"重新搜索") forState:UIControlStateNormal];
    [_btnSearchAgain setTitleColor:DWhite forState:UIControlStateNormal];
    [_btnSearchAgain setTitleColor:DWhite forState:UIControlStateHighlighted];
    
    _btnSearchAgain.layer.borderWidth = 1;
    _btnSearchAgain.layer.borderColor = DWhite3.CGColor;
    _btnSearchAgain.layer.cornerRadius = 10;
    _btnSearchAgain.layer.masksToBounds = YES;
    
    
    [self initTable];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:kString(@"先不绑定了")];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_btnBack setAttributedTitle:str forState:UIControlStateNormal];
}

-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(20, 0, ScreenWidth-40, _viewTableHeight.constant) style:UITableViewStyleGrouped];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(80), 50);
    self.tabView.showsVerticalScrollIndicator = YES;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = DClear;
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcSearch" bundle:nil]
       forCellReuseIdentifier:@"tvcSearch"];
    [_viewTable addSubview:self.tabView];
}

- (IBAction)btnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
            [self beginSearchAgain];
            break;
        case 2:
            [self.Bluetooth stopScan];
            [self dismissViewControllerAnimated:YES completion:NULL];
            break;
    }
}

-(void)beginSearchAgain
{
    if (!self.Bluetooth.isOn) {
        LMBShow(@"请打开蓝牙");
        return;
    }
    
    self.viewCercle.hidden = NO;
    beginDate = DNow;
    
    _btnSearchAgain.hidden = _viewTable.hidden = YES;
    [self.Bluetooth startScan];
    
    [self.dicData removeAllObjects];
    [self.tabView reloadData];
    __block vcSearch *blockSelf = self;
    NextWaitInMainAfter(
             if(blockSelf.dicData.count)
             {
                 blockSelf.viewTable.hidden = blockSelf.btnSearchAgain.hidden = NO;
                 blockSelf.viewCercle.hidden = YES;
                 blockSelf.tabView.userInteractionEnabled = YES;
             }
             , 1.5);
    
    NextWaitInMainAfter(
             if(!blockSelf.dicData.count)
             {
                 if (blockSelf.view.window) {
                     LMBShowInBlock(@"没有发现设备");
                 }
                 blockSelf.viewCercle.hidden = YES;
                 blockSelf.viewTable.hidden = blockSelf.btnSearchAgain.hidden = NO;
             }
             , 5);
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _dicData.count;
}

#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcSearch *cell = [tvcSearch cellWithTableView:tableView];
    CBPeripheral *cbp = _dicData.allValues[indexPath.row];
    cell.lblTitle.text = cbp.name;
    cell.backgroundColor = DClear;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = DWhite3;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.Bluetooth stopScan];
    
    CBPeripheral *cbp = _dicData.allValues[indexPath.row];
    
    __block vcSearch *blockSelf = self;
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"绑定这个设备?" message:cbp.name];
    [alert showWithActionSure:^
     {
         SetUserDefault(isNotRealNewBLE, @1);
         blockSelf->swtRefresh = YES;
         blockSelf.isFirstLink = YES;
         [blockSelf.Bluetooth retrievePeripheral:[cbp.identifier UUIDString]];
         MBShowAllInBlockWithText(@"正在连接");
         [blockSelf performSelector:@selector(checkisLinkAfterConnecting) withObject:nil afterDelay:10];
         
         // 这里防止用户点击后， 连接不上， 是因为设备已经长时间没有连接停止广播造成的
         blockSelf->beginDate = DNow;
         [self.tabView reloadData];
     } cancel:^{
         blockSelf.tabView.userInteractionEnabled = YES;
     }];
}

-(void)checkisLinkAfterConnecting
{
    if (!self.Bluetooth.isLink) {
        MBHide
        LMBShow(@"请尝试重新连接");
        swtRefresh = NO;
        [self beginSearchAgain];
    }
}

-(void)Found_Next:(NSMutableDictionary *)recivedTxt
{
    if(!swtRefresh)
    {
        __block vcSearch *blockSelf = self;
        __block NSMutableDictionary *blockrecivedTxt = recivedTxt;
        NextWaitInMain(
           blockSelf.dicData = [blockrecivedTxt mutableCopy];
           if (blockSelf.dicData.count > 0 && [DNow timeIntervalSinceDate:beginDate] > 1.5) //  && _dicData.count > lastCount
           {
               if (blockSelf.viewTable.hidden) {
                   [blockSelf.viewTable setHidden:NO];
                   [blockSelf.viewCercle setHidden:YES];
                   [blockSelf.btnSearchAgain setHidden:NO];
                   blockSelf.tabView.userInteractionEnabled = YES;
               }
               NSLog(@"刷新界面");
               beginDate = DNow;
               [_tabView reloadData];
           }
       );
    }
}



-(void)checkLink
{
    if (self.Bluetooth.isLink && self.Bluetooth.dicConnected.count)
    {
        [timer DF_stop];
        timer = nil;
        self.userInfo.pUUIDString = self.Bluetooth.dicConnected.allKeys[0];
        self.userInfo.pName = ((CBPeripheral *)(self.Bluetooth.dicConnected.allValues[0])).name;
        SetUserDefault(IndexTabelReload, @YES);
        DBSave;
        NSLog(@"uuid %@", self.userInfo.pUUIDString);
        
        __block vcSearch *blockSelf = self;
        NextWaitInMainAfter(
                 if(blockSelf.blockBeforeDismissLink) blockSelf.blockBeforeDismissLink();
                 [blockSelf dismissViewControllerAnimated:YES completion:^{
            
                  }];, 1);
    }
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if ([object isEqual:self.Bluetooth] && [keyPath isEqual:@"isLink"] && self.isLink && self.Bluetooth.dicConnected.count)
//    {
//        __weak vcSearch *blockSelf = self;
//        NextWaitInMainAfter(
//                            MBHide
//                            [blockSelf observerNext];, 1);
//    }
//}
//
//-(void)observerNext
//{
//    if (self.Bluetooth.dicConnected.count) {
//        self.userInfo.pUUIDString = self.Bluetooth.dicConnected.allKeys[0];
//        self.userInfo.pName = ((CBPeripheral *)(self.Bluetooth.dicConnected.allValues[0])).name;
//        DBSave;
//        NSLog(@"uuid %@", self.userInfo.pUUIDString);
//        [self dismissViewControllerAnimated:YES completion:NULL];
//    }
//    else
//    {
//        NSLog(@"出错了");
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //if (self.isViewLoaded && !self.view.window) self.view = nil;
}





@end
