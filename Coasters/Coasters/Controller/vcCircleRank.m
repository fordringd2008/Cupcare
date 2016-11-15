//
//      ┏┛ ┻━━━━━┛ ┻┓
//      ┃　　　　　　 ┃
//      ┃　　　━　　　┃
//      ┃　┳┛　  ┗┳　┃
//      ┃　　　　　　 ┃
//      ┃　　　┻　　　┃
//      ┃　　　　　　 ┃
//      ┗━┓　　　┏━━━┛
//        ┃　　　┃   神兽保佑
//        ┃　　　┃   代码无BUG！
//        ┃　　　┗━━━━━━━━━┓
//        ┃　　　　　　　    ┣┓
//        ┃　　　　         ┏┛
//        ┗━┓ ┓ ┏━━━┳ ┓ ┏━┛
//          ┃ ┫ ┫   ┃ ┫ ┫
//          ┗━┻━┛   ┗━┻━┛
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcCircleRank.h"
#import "tvcCircleRank.h"

#pragma mark - 宏命令

@interface vcCircleRank ()<UITableViewDataSource, UITableViewDelegate>
{
    
//    __weak IBOutlet UILabel *lblLeft;
//    __weak IBOutlet UILabel *lblRight;
//    __weak IBOutlet UIView *lineLeft;
//    __weak IBOutlet UIView *lineRight;
//    
//    __weak IBOutlet UIButton *btnLeft;
//    __weak IBOutlet UIButton *btnRight;
    
    
    
    UILabel *lblLeft;
    UILabel *lblRight;
    
    
    UIView *lineLeft;
    UIView *lineRight;
    UIView *lineMiddle;
    
    UIButton *btnLeft;
    UIButton *btnRight;
    
    UITableView *tabView;
    
    
    NSMutableArray *arrDataDay;
    NSMutableArray *arrDataMonth;
    NSArray *arrData;
    
}

@end

@implementation vcCircleRank

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"喝水排行榜"];
    
    [self initData];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    // 这里移除观察者
    NSLog(@"vcCircleRank销毁了");
}


// 初始化数据
- (void)initData
{
    //arrData = @[@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1",@"1"];
}

// 初始化布局控件
- (void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight - 0) style:UITableViewStyleGrouped];
    tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    tabView.dataSource = self;
    tabView.delegate = self;
    tabView.rowHeight = Bigger(RealHeight(100), 60);
    tabView.showsVerticalScrollIndicator = NO;
    tabView.backgroundColor = DLightGrayBlackGroundColor;
//    tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tabView registerNib:[UINib nibWithNibName:@"tvcCircleRank" bundle:nil] forCellReuseIdentifier:@"tvcCircleRank"];
    [self.view addSubview:tabView];
    tabView.tableHeaderView = ({
        UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
        viewHead.backgroundColor = tabView.backgroundColor;
        
        CGRect rectLeft  = CGRectMake(0, 20, ScreenWidth / 2, 40);
        CGRect rectRight = CGRectMake(ScreenWidth / 2, 20, ScreenWidth / 2, 40);
        
        
        
        lblLeft = [[UILabel alloc] initWithFrame:rectLeft];
        lblLeft.text = kString(@"今日排行");
        lblLeft.textColor = DBlack;
        lblLeft.textAlignment = NSTextAlignmentCenter;
        lblLeft.font = [UIFont systemFontOfSize:17];
        lblLeft.backgroundColor = DWhite;
        [viewHead addSubview:lblLeft];
        
        lblRight = [[UILabel alloc] initWithFrame:rectRight];
        lblRight.text = kString(@"本月排行");
        lblRight.textColor = DBlack;
        lblRight.textAlignment = NSTextAlignmentCenter;
        lblRight.font = [UIFont systemFontOfSize:17];
        lblRight.backgroundColor = DWhite;
        [viewHead addSubview:lblRight];
        
        
        btnLeft = [[UIButton alloc] initWithFrame:rectLeft];
        btnLeft.backgroundColor = DClear;
        btnLeft.enabled = NO;
        [btnLeft addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewHead addSubview:btnLeft];
        btnRight = [[UIButton alloc] initWithFrame:rectRight];
        btnRight.backgroundColor = DClear;
        [btnRight addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewHead addSubview:btnRight];
        
        lineMiddle = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 20, 1, 40)];
        lineMiddle.backgroundColor = DLightGray;
        [viewHead addSubview:lineMiddle];
        
        lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 59, ScreenWidth / 2, 1)];
        lineLeft.backgroundColor = DidConnectColor;
        [viewHead addSubview:lineLeft];
        
        lineRight = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 59, ScreenWidth / 2, 1)];
        lineRight.backgroundColor = DLightGray;
        [viewHead addSubview:lineRight];
        
        viewHead;
    });
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
- (void)btnClick:(UIButton *)sender {
    if ([sender isEqual:btnRight]) {
        lineLeft.backgroundColor  = DLightGray;
        lineRight.backgroundColor = DidConnectColor;
        btnLeft.enabled = YES;
        btnRight.enabled = NO;
        arrData = arrDataMonth;
    }else{
        lineLeft.backgroundColor  = DidConnectColor;
        lineRight.backgroundColor = DLightGray;
        btnLeft.enabled = NO;
        btnRight.enabled = YES;
        arrData = arrDataDay;
    }
    [tabView reloadData];
}


#pragma mark 1 target-action                    普通

#pragma mark 2 delegate dataSource protocol     代理协议

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcCircleRank *cell = [tvcCircleRank cellWithTableView:tableView];
    NSDictionary *dicModel = arrData[indexPath.row];
    [cell.imv sd_setImageWithURL:[NSURL URLWithString:dicModel[@"user_pic_url"]] placeholderImage:DefaultLogo_Gender([dicModel[@"user_gender"] boolValue])];
    cell.imv.layer.cornerRadius =  (Bigger(RealHeight(100), 60) - 16) / 2;
    cell.imv.layer.masksToBounds = YES;
    cell.lblNumber.text = [@(indexPath.row + 1) description];
    cell.lblName.text   = [dicModel[@"user_nick_name"] description];
    cell.lblValue.text  = [NSString stringWithFormat:@"%@ml", !btnLeft.enabled ? dicModel[@"today_drink_num"] : dicModel[@"month_drink_num"]] ;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 30, 0, 0);
    }
    
    if (!btnLeft.enabled) {
        cell.lblValue.textColor = [cell.lblValue.text intValue] > 1000 ? DRed:DBlack;
    }else if (btnLeft.enabled) {
        cell.lblValue.textColor = [cell.lblValue.text intValue] > 10000 ? DRed:DBlack;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tabView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - ------------------------------------- 私有方法

#pragma mark - ------------------------------------- 属性实现

-(void)setArrGroupMember:(NSArray *)arrGroupMember
{
//    arrGroupMember = @[@{@"month_drink_num":@"10",
//                           @"month_k_date":@"5996",
//                           @"today_drink_num":@"10",
//                           @"today_k_date":@"0",
//                           @"user_nick_name":@"0",
//                           @"user_pic_url":@"0",
//                           @"userid":@"0"},
//                       @{@"month_drink_num":@"20",
//                         @"month_k_date":@"5996",
//                         @"today_drink_num":@"0",
//                         @"today_k_date":@"0",
//                         @"user_nick_name":@"0",
//                         @"user_pic_url":@"0",
//                         @"userid":@"0"},
//                       @{@"month_drink_num":@"30000",
//                         @"month_k_date":@"5996",
//                         @"today_drink_num":@"2000",
//                         @"today_k_date":@"0",
//                         @"user_nick_name":@"0",
//                         @"user_pic_url":@"0",
//                         @"userid":@"0"}];
    
    _arrGroupMember             = arrGroupMember;
    arrDataDay                  = [@[] mutableCopy];
    arrDataMonth                = [@[] mutableCopy];
    arrDataDay                  = [DFD sort:[arrGroupMember mutableCopy] byString:@"today_drink_num"];
    arrDataMonth                = [DFD sort:[arrGroupMember mutableCopy] byString:@"month_drink_num"];

    arrData                     = arrDataDay;
}

#pragma mark -





































@end
