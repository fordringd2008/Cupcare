//
//  vcWorkDayEdit.m
//  Coasters
//
//  Created by 丁付德 on 15/10/20.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcWorkDayEdit.h"
#import "TAlertView.h"

@interface vcWorkDayEdit () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *    arrRepeat;
    BOOL                isChange;               // 是否有变化
    NSString *          strRepeatOld;           // 最初 传进来的
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;



@property (nonatomic, strong) UITableView *                 tabView;
@property (nonatomic, strong) NSArray *                     arrData;

@end

@implementation vcWorkDayEdit

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButton:nil text:@"重复"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    [self initView];
    [self initData];
}
-(void)initView
{
    self.viewMainHeight.constant = ScreenHeight - NavBarHeight;
    self.scrMain.scrollEnabled = NO;
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(88), 50) * 7 + 2)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(88), 50);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled =  NO;
    [self.viewMain addSubview:self.tabView];
    
    UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    viewLine.backgroundColor = RGBA(211, 210, 214, 0.8);
    self.tabView.tableHeaderView = viewLine;
    UIView *viewLine2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
    viewLine2.backgroundColor = RGBA(211, 210, 214, 0.8);
    self.tabView.tableFooterView = viewLine2;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![self checkLink]) {
        self.tabView.userInteractionEnabled = NO;
    }
}

-(void)back
{
    // 如果修改了，提醒用户 修改会关闭所有  确定后 在这里发送数据（关闭所有提醒）
    //
    if (isChange)  // 进到这里说明 已经是连接的了
    {
        TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"你已经修改工作日, 是否保存?"];
        [alert showWithActionSure:^
         {
             [self setWaterRemind:2 isWork:YES obj:self.strRepeat];
             [self.Bluetooth setWaterRemind:2 isWork:YES uuid:self.userInfo.pUUIDString];
             [super back];
         } cancel:^{
             [super back];
         }];
    }
    else
       [super back];
}

-(void)initData
{
    self.arrData = @[ kString(@"每周日"), kString(@"每周一"),kString(@"每周二"),kString(@"每周三"),kString(@"每周四"),kString(@"每周五"),kString(@"每周六"),];
    arrRepeat = [[self.strRepeat componentsSeparatedByString:@"-"] mutableCopy];
    strRepeatOld = self.strRepeat;
}

-(BOOL)checkLink
{
    if (!self.userInfo.pUUIDString) {
        LMBShow(@"您没有绑定杯垫");
        return NO;
    }
    else if (![self.Bluetooth.dicConnected.allKeys containsObject:self.userInfo.pUUIDString]) {
        LMBShow(@"请先连接杯垫"); // 请先连接杯垫
        return NO;
    }
    return  YES;
}


-(void)refreshArrRepeat
{
    self.strRepeat = [arrRepeat componentsJoinedByString:@"-"];
    isChange = ![self.strRepeat isEqualToString:strRepeatOld];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 7;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell"; // 标识符
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;                        //选中cell时无色
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    if ([arrRepeat[indexPath.row + 1] boolValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([arrRepeat[indexPath.row + 1] boolValue])
    {
        arrRepeat[indexPath.row + 1] = @"0";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        arrRepeat[indexPath.row + 1] = @"1";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self refreshArrRepeat];
}



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
