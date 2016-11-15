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

#import "vcAddCircleMember.h"
#import "tvcAddCircleMember.h"

#pragma mark - 宏命令

@interface vcAddCircleMember ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tabView;
    NSArray *arrData;
    
    NSArray *arrGroupUserID;        // 圈子中已经包含的好友ID
    NSMutableArray *arrSelect;      // 选中的集合
}

@end

@implementation vcAddCircleMember

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"选择好友"];
    
    
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
    NSLog(@"vcAddCircleMember销毁了");
}

-(void)rightButtonClick
{
    if(arrSelect.count)
    {
        NSMutableArray *arrTag = [@[] mutableCopy];
        for (NSString *userid in arrSelect) {
            [arrTag addObject:@{ @"userid":userid }];
        }
        
        NSString *json = [DFD toJsonStringForUpload:arrTag];
        
        NSLog(@"json:%@",json);
        MBShowAll;
        __block vcAddCircleMember *blockSelf = self;
        HDDAF;
        RequestCheckAfter(
              [net pullUserInGroup:blockSelf.userInfo.access
                        pull_users:json
                          group_id:blockSelf.group.group_id];,
              [blockSelf dataSuccessBack_pullUserInGroup:(NSDictionary *)dic];)
    }else
    {
        LMBShow(@"请选择");
    }
}

-(void)initData
{
    [self refreshData];
    __block vcAddCircleMember *blockSelf = self;
    RequestCheckNoWaring(
             int dateValue = [DFD HmF2KNSDateToInt:DNow];
             [net getFriendsInfo:blockSelf.userInfo.access
                    today_k_date:@(dateValue)];,
             [blockSelf dataSuccessBack_getFriendsInfo:dic];);
}


// 初始化数据
- (void)refreshData
{
    NSArray *arrFriends = [Friend findAllSortedBy:@"user_id" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
    NSMutableArray *arrTag = [@[] mutableCopy];
    for (Friend *f in arrFriends)
    {
        NSDictionary *dicTag = @{
                                 @"user_id"         :f.user_id,
                                 @"user_pic_url"    :f.user_pic_url,
                                 @"user_nick_name"  :f.user_nick_name,
                                 @"isContains"      :@([arrGroupUserID containsObject:f.user_id])
                                 };
        [arrTag addObject:dicTag];
    }
    
    arrData = arrTag;
    arrSelect = [@[] mutableCopy];
    
    if (arrData.count) {
        [self initRightButton:@"save" text:nil];
    }else{
        [self initRightButton:nil text:nil];
    }
    
    [tabView reloadData];
}

// 初始化布局控件
- (void)initView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - StateBarHeight) style:UITableViewStyleGrouped];
    tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    tabView.dataSource = self;
    tabView.delegate = self;
    tabView.rowHeight = Bigger(RealHeight(100), 60);
    tabView.showsVerticalScrollIndicator = NO;
    tabView.backgroundColor = DLightGrayBlackGroundColor;
    [tabView registerNib:[UINib nibWithNibName:@"tvcAddCircleMember" bundle:nil] forCellReuseIdentifier:@"tvcAddCircleMember"];
    tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
    [self.view addSubview:tabView];
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
#pragma mark 1 target-action                    普通

#pragma mark 2 delegate dataSource protocol     代理协议


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
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
    tvcAddCircleMember *cell = [tvcAddCircleMember cellWithTableView:tableView];
    
    NSDictionary *dicModel = arrData[indexPath.row];
    
    cell.imvCheck.image = [UIImage imageNamed:([dicModel[@"isContains"] boolValue] ? @"enable_bar_press":@"select_bar_normal")];
    [cell.imvUrl sd_setImageWithURL:[NSURL URLWithString:[dicModel[@"user_pic_url"] description]] placeholderImage:DefaultLogo_Gender([dicModel[@"user_gender"] intValue])];
    
    NSString *userid = [dicModel[@"user_id"] description];
    if (![dicModel[@"isContains"] boolValue])
    {
        cell.imvCheck.image = [UIImage imageNamed:([arrSelect containsObject:userid] ? @"select_bar_press":@"select_bar_normal")];
    }
    
    cell.imvUrl.layer.cornerRadius = (Bigger(RealHeight(100), 60) - 10 ) / 2;
    cell.imvUrl.layer.masksToBounds = YES;
    cell.lblName.text = [dicModel[@"user_nick_name"] description];
    cell.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0);

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    tvcAddCircleMember *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary *dicModel = arrData[indexPath.row];
    if ([dicModel[@"isContains"] boolValue]) return;
    
    NSString *userid = [dicModel[@"user_id"] description];
    
    if ([arrSelect containsObject:userid]) {
        [arrSelect removeObject:userid];
        cell.imvCheck.image = [UIImage imageNamed:@"select_bar_normal"];
    }else{
        [arrSelect addObject:userid];
        cell.imvCheck.image = [UIImage imageNamed:@"select_bar_press"];
    }
}


#pragma mark - ------------------------------------- 私有方法

-(void)dataSuccessBack_pullUserInGroup:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        LMBShow(@"添加成功");
        __block vcAddCircleMember *blockSelf = self;
        
        
        NextWaitInMainAfter(
                [DFD backToVcByNav:blockSelf.navigationController vcName:@"vcCircleDetails" animated:YES];, 1);
        
//        for (UIViewController *vc in self.navigationController.viewControllers) {
//            if ([[[vc class] description] isEqualToString:@"vcCircleDetails"]) {
//                NextWaitInMainAfter([self.navigationController popToViewController:vc animated:YES];, 1);
//                break;
//            }
//        }
    }
}

-(void)dataSuccessBack_getFriendsInfo:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSArray *arrData_ = dic[@"friends_info"];
        if (!arrData_) return;
        NSArray *arrFriendOld = [Friend findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        for (Friend *f in arrFriendOld) {
            f.tag = @NO;
        }
        DBSave;
        
        __block vcAddCircleMember *blockSelf = self;
        [Friend objectsByArray:dic[@"friends_info"]
                       context:DBefaultContext
                  perfectBlock:^(id model) {
                      Friend *fr = model;
                      fr.access = blockSelf.userInfo.access;
                      fr.tag    = @YES;
                  }];
        
//        for (int i = 0; i < arrData_.count; i++)
//        {
//            NSDictionary *dicFr         = arrData_[i];
//            NSString *user_id           = dicFr[@"userid"];
//            NSString *user_pic_url      = dicFr[@"user_pic_url"];
//            NSString *user_nick_name    = dicFr[@"user_nick_name"];
//            BOOL user_gender            = [dicFr[@"user_gender"] boolValue];
//            NSInteger user_drink_target = [dicFr[@"user_drink_target"] integerValue];
//            NSInteger k_date            = [dicFr[@"k_date"] integerValue];
//            NSString *time_array        = dicFr[@"time_array"];
//            NSString *water_array       = dicFr[@"water_array"];
//            int like_num                = [dicFr[@"user_like_num"] intValue];
//            BOOL like_statue            = [dicFr[@"user_like_status"] intValue];
//            
//            Friend *fr = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@ ", self.userInfo.access, user_id] inContext:DBefaultContext];
//            if (!fr)
//                fr = [Friend MR_createEntityInContext:DBefaultContext];
//            
//            fr.access                           = self.userInfo.access;
//            fr.user_id                          = user_id;
//            fr.user_pic_url                     = user_pic_url;
//            fr.user_nick_name                   = user_nick_name;
//            fr.user_gender                      = @(user_gender);
//            fr.user_drink_target                = @(user_drink_target);
//            fr.k_date                           = @(k_date);
//            fr.time_array                       = time_array;
//            fr.water_array                      = water_array;
//            fr.tag                              = @YES;
//            fr.like_num                         = @(like_num);
//            if (like_statue) fr.last_like_kDate = @([DFD HmF2KNSDateToInt:DNow]);
//            
//            [fr perfect];
//        }
        
        self.userInfo.like_number = @([dic[@"my_like_num"] intValue]);
        [Friend MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and tag == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
        
        DBSave;
        [self refreshData];
    }
}


#pragma mark - ------------------------------------- 属性实现
-(void)setArrGroupMember:(NSArray *)arrGroupMember
{
    _arrGroupMember = arrGroupMember;
    
    NSMutableArray *arrTag = [@[] mutableCopy];
    for (NSDictionary *dicTag in arrGroupMember) {
        [arrTag addObject:[dicTag[@"userid"] description]];
    }
    arrGroupUserID = arrTag;
}


#pragma mark -






































@end
