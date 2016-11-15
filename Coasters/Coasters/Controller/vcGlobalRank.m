//
//  vcGlobalRank.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/25.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcGlobalRank.h"
#import "tvcFriendRank.h"



@interface vcGlobalRank ()<UITableViewDelegate, UITableViewDataSource>
{
    int                         rank;
    FriendInGlobal *            fg_mySelf;
}




@property (weak, nonatomic) IBOutlet UITableView        *tabView;


@property (strong, nonatomic) NSArray                     *arrData;



@end

@implementation vcGlobalRank

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButton:nil text:@"全球排行榜"];
    
    [self initData];
    [self initView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    __block vcGlobalRank *blockSelf = self;
    RequestCheckNoWaring(
         [net getTodayGlobalRank:blockSelf.userInfo.access
                    today_k_date:[DFD HmF2KNSDateToInt:DNow]];,
         [blockSelf dataSuccessBack_getTodayGlobalRank:dic];)
}

-(void)initData
{
    [FriendInGlobal MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access]  inContext:DBefaultContext];
    DBSave
    Friend *fr_mySelf = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
    
    fg_mySelf             = [FriendInGlobal MR_createEntityInContext:DBefaultContext];
    fg_mySelf.access      = self.userInfo.access;
    fg_mySelf.user_id     = [self.userInfo.user_id description];
    fg_mySelf.rank        = @(rank ? rank : 1);
    fg_mySelf.user_gender = self.userInfo.user_gender;
    fg_mySelf.nick_name   = self.userInfo.user_nick_name;
    fg_mySelf.url         = self.userInfo.logo;
    fg_mySelf.user_gender = self.userInfo.user_gender;
    if ([fg_mySelf.waterCount intValue] < [fr_mySelf.waterCount intValue]) {
        fg_mySelf.waterCount  = fr_mySelf.waterCount;
    }
    [self refreshData];
}

-(void)refreshData
{
    NSArray *arrFg = [FriendInGlobal findAllSortedBy:@"rank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and waterCount != %@", self.userInfo.access, @0] inContext:DBefaultContext];
    
    [arrFg enumerateObjectsUsingBlock:^(FriendInGlobal *fg, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([fg.access isEqualToString:self.userInfo.access] &&
            [fg.user_id isEqualToString:[self.userInfo.user_id description]]) {
            fg_mySelf = fg;
            *stop = YES;
        }
    }];
    if (arrFg.count > 20) {
        arrFg = [arrFg subarrayWithRange:NSMakeRange(0, 20)];
    }
    
    _arrData = @[ @[fg_mySelf], arrFg ];
}

-(void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    _tabView.rowHeight = Bigger(RealHeight(100), 60);
    _tabView.showsVerticalScrollIndicator = NO;
    _tabView.scrollEnabled = YES;
    _tabView.backgroundColor = DLightGrayBlackGroundColor;
    [_tabView registerNib:[UINib nibWithNibName:@"tvcFriendRank" bundle:nil] forCellReuseIdentifier:@"tvcFriendRank"];
    _tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        view.backgroundColor = _tabView.backgroundColor;
        view;
    });
}


-(void)dataSuccessBack_getTodayGlobalRank:(NSDictionary *)dic{
    if (CheckIsOK)
    {
//        [FriendInGlobal MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
//        DBSave;
        
//        NSLog(@"%@", dic);
        
        __block vcGlobalRank *blockSelf = self;
        [FriendInGlobal objectsByArray:dic[@"today_global_rank"]
                               context:DBefaultContext
                               perfectBlock:^(id model) {
                                   FriendInGlobal *fg = model;
                                   fg.access = blockSelf.userInfo.access;
                               }];
        
        rank = [dic[@"my_rank"] intValue];
        [self refreshData];
        [_tabView reloadData];
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section) {
        int a = (int)((NSArray *)(self.arrData[1])).count;
        return a;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section?10:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendRank *cell = [tvcFriendRank cellWithTableView:tableView];
    FriendInGlobal *model = self.arrData[indexPath.section][indexPath.row];
    if (!indexPath.section) {
        cell.isMySelf = YES;
    }
    cell.lblNumberWidth.constant = 20;
    cell.fgModel = model;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
