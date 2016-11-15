//
//  vcFriendsRanking.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriendsRanking.h"
#import "tvcFriendRank.h"
#import "vcFriendDetails.h"
#import "MJRefresh.h"

@interface vcFriendsRanking ()<UITableViewDelegate, UITableViewDataSource, tvcFriendRankDelegate>
{
    UILabel *lblNoDataNotice;
}

@property (strong, nonatomic) UITableView *tabView;
@property (strong, nonatomic) NSArray *arrData;


@end

@implementation vcFriendsRanking

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"今日好友排名"];
    [self initRightButton:nil text:@"全球排行榜"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    [self initView];
    [self refreshData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)rightButtonClick{
    [self performSegueWithIdentifier:@"rank_to_global" sender:nil];
}

-(void)refreshData
{
    SynData *synLast = [SynData findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] sortedBy:@"date" ascending:NO inContext:DBefaultContext];
    
    // 这里如果今天的没有喝水
    if ([synLast.date isToday])
    {
        // 如果没有自己的 加入自己的   加入后 以后就不在加入了 只需更新就行
        Friend *fr_mySelf = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
        if (!fr_mySelf)
        {
            fr_mySelf = [Friend MR_createEntityInContext:DBefaultContext];
            fr_mySelf.access = self.userInfo.access;
            fr_mySelf.dateTime = DNow;
            fr_mySelf.k_date = @([DFD HmF2KNSDateToInt:fr_mySelf.dateTime]);
            
            DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", self.userInfo.access, fr_mySelf.k_date] sortedBy:@"dateValue" ascending:NO inContext:DBefaultContext];
            
            int newWaterCount    = Bigger([synLast.waterCount intValue], [dr.waterCount intValue]);
            fr_mySelf.time_array        = dr.time_array;
            fr_mySelf.water_array       = dr.water_array;
            fr_mySelf.user_drink_target = self.userInfo.user_drink_target;
            fr_mySelf.user_id           = [self.userInfo.user_id description];
            fr_mySelf.user_gender       = self.userInfo.user_gender;
            fr_mySelf.user_nick_name    = self.userInfo.user_nick_name;
            fr_mySelf.waterCount        = @(newWaterCount);
            fr_mySelf.user_pic_url      = self.userInfo.logo;
            fr_mySelf.like_num          = self.userInfo.like_number;
            DBSave;
        }
        else
        {
            fr_mySelf.waterCount = synLast.waterCount;
            fr_mySelf.like_num   = self.userInfo.like_number;
            DBSave;
        }
    }
    
    _arrData = [Friend findAllSortedBy:@"waterCount" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date = %@ and waterCount != %@", self.userInfo.access, @([DFD HmF2KNSDateToInt:DNow]), @0] inContext:DBefaultContext];
    
    [_tabView reloadData];
    lblNoDataNotice.hidden = (BOOL)_arrData.count;
    _tabView.hidden = !lblNoDataNotice.hidden;
}

-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    self.tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = Bigger(RealHeight(100), 60);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcFriendRank" bundle:nil] forCellReuseIdentifier:@"tvcFriendRank"];
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
    [self.view addSubview:self.tabView];
    
    __block vcFriendsRanking *blockSelf = self;
    self.tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [blockSelf getData];
    }];
}

-(void)initView
{
    self.view.backgroundColor =  DLightGrayBlackGroundColor;
    [self initTable];
    
    lblNoDataNotice = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, ScreenWidth - 40, 42)];
    lblNoDataNotice.text = kString(@"今天没有好友的喝水记录,快去提醒Ta们吧~");
    lblNoDataNotice.textAlignment = NSTextAlignmentCenter;
    lblNoDataNotice.font = [UIFont systemFontOfSize:17];
    lblNoDataNotice.textColor = DLightGray;
    lblNoDataNotice.numberOfLines = 2;
    [self.view addSubview:lblNoDataNotice];
}

-(void)loadNewData
{
    [self getData];
}

-(void)getData
{
    __block vcFriendsRanking *blockSelf = self;
    RequestCheckBefore(
           int dateValue = [DFD HmF2KNSDateToInt:DNow];
           [net getFriendsInfo:blockSelf.userInfo.access today_k_date:@(dateValue)];,
           [blockSelf dataSuccessBack_getFriendsInfo:dic];,
           [blockSelf.tabView.mj_header endRefreshing];,NO)
}

#pragma mark tvcFriendRankDelegate
-(void)btnClickLike:(tvcFriendRank *)cell
{
    __strong tvcFriendRank *blockCell = cell;
    __strong vcFriendsRanking *blockSelf = self;
    NSString *userid = cell.model.user_id;
    int type = 5;
    void (^likeBlock)(tvcFriendRank *cell, BOOL isLike) = ^(tvcFriendRank *cell, BOOL isLike)
    {
        Friend *fr = cell.model;
        if (cell.isLiked)
        {
            fr.like_num = @([fr.like_num intValue]+(isLike ? 1:-1));
            fr.last_like_kDate = isLike ? @([DFD HmF2KNSDateToInt:DNow]) : nil;
            
            DBSave;
            if(isLike)
            {
                cell.lblLikeNumber.text = [NSString stringWithFormat:@"%d", [cell.lblLikeNumber.text intValue]+(isLike ? 1:-1)];
            }
        }
    };
    
    likeBlock(cell, YES);
    
    RequestCheckBefore(
           int k_date = [DFD HmF2KNSDateToInt:DNow];
           [net pushLikeInfo:blockSelf.userInfo.access type:type friend_id:userid today_k_date:k_date];,
           [blockSelf dataSuccessBack_pushLikeInfo:dic];,
           likeBlock(blockCell, NO);,NO)
}


#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendRank *cell = [tvcFriendRank cellWithTableView:tableView];
    if (self.arrData.count > 0)
    {
        cell.model = self.arrData[indexPath.row];
        if (indexPath.row < 3)
            [cell.lblNumber setFont:[UIFont fontWithName:@"Menlo-BoldItalic" size:16]];
        else
            [cell.lblNumber setFont:[UIFont systemFontOfSize:16]];
        cell.lblNumber.text = [NSString stringWithFormat:@"NO.%ld", (long)indexPath.row + 1];
        
        if ([cell.model.user_id isEqualToString: [self.userInfo.user_id description]] ||
            [cell.model.last_like_kDate intValue] == [DFD HmF2KNSDateToInt:DNow]) {
            cell.btnlike.enabled = NO;
        }else{
            cell.btnlike.enabled = YES;
        }
    }

    
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Friend *fr = self.arrData[indexPath.row];
    if (![fr.user_id isEqualToString:[self.userInfo.user_id description]])
        [self performSegueWithIdentifier:@"rank_to_details" sender:fr];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"rank_to_details"])
    {
        vcFriendDetails *vc = (vcFriendDetails *)segue.destinationViewController;
        vc.model = sender;
    }
}

-(void)dataSuccessBack_getFriendsInfo:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSArray *arrData = dic[@"friends_info"];
        if (!arrData) return;
        NSArray *arrFriendOld = [Friend findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        for (Friend *f in arrFriendOld) {
            f.tag = @NO;
        }
        DBSave;
        
        __block vcFriendsRanking *blockSelf = self;
        [Friend objectsByArray:dic[@"friends_info"]
                       context:DBefaultContext
                  perfectBlock:^(id model) {
                      Friend *fr = model;
                      fr.access = blockSelf.userInfo.access;
                      fr.tag    = @YES;
                  }];
        
        self.userInfo.like_number = @([dic[@"my_like_num"] intValue]);
        [Friend MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and tag == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
        
        DBSave;
        
        [self refreshData];
        [self.tabView.mj_header endRefreshing];
    }
}

-(void)dataSuccessBack_pushLikeInfo:(NSDictionary *)dic{
    if (CheckIsOK) {
        NSLog(@"点赞成功");
    }
}


@end
