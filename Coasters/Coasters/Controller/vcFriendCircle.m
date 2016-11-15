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
//  Created by 丁付德 on 16/6/1.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcFriendCircle.h"
#import "tvcFriend.h"
#import "tvcCircle.h"
#import "vcAddEditCircle.h"
#import "WBPopMenuModel.h"
#import "WBPopMenuSingleton.h"
#import "QRCodeReaderViewController.h"
#import "vcCircleDetails.h"
#import "TAlertView.h"

#pragma mark - 宏命令

@interface vcFriendCircle ()<UITableViewDelegate, UITableViewDataSource, QRCodeReaderDelegate>
{
    
    BOOL isHaveRequest;             // 是否有别人申请

    BOOL isNotRequest;              // 不重新拉去
}

@property (nonatomic, strong) UITableView *tabView;

@property (nonatomic, strong) NSArray *arrMyGroup;
@property (nonatomic, strong) NSArray *arrAroundGroup;

@end

@implementation vcFriendCircle

@synthesize arrMyGroup;
@synthesize arrAroundGroup;


#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"我的圈子"];
    [self initRight];
    
    [self initData];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!isNotRequest)                       // 防止扫描后跳转的时候，再次拉去服务器导致的 group 异常
        [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    isNotRequest = NO;
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    // 这里移除观察者
    NSLog(@"vcFriendCircle销毁了");
}

-(void)initRight
{
    UIView *viewRight =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 65, 20)];
    
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 22, 22)];
    [btnSearch setImage:[UIImage imageNamed:@"circle_search_01"] forState:UIControlStateNormal];
    [btnSearch setImage:[UIImage imageNamed:@"circle_search_02"] forState:UIControlStateHighlighted];
    
    [btnSearch addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewRight addSubview:btnSearch];
    
    UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(40, 0, 22, 22)];
    [btnAdd setImage:[UIImage imageNamed:@"Increase"] forState:UIControlStateNormal];
    [btnAdd setImage:[UIImage imageNamed:@"Increase02"] forState:UIControlStateHighlighted];
    [btnAdd addTarget:self action:@selector(rightClick:) forControlEvents:UIControlEventTouchUpInside];
    btnAdd.tag = 1;
    [viewRight addSubview:btnAdd];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:viewRight];
    self.navigationItem.rightBarButtonItem = item;
}

-(void)rightClick:(UIButton*)btn
{
    if (!btn.tag)
    {
        NSArray *arrTitle = @[ kString(@"查找圈号"), kString(@"扫描圈子二维码")];
        NSArray *arrImage = @[ @"circle_input", @"right_menu_QR" ];
        
        NSMutableArray *obj = [NSMutableArray array];
        for (NSInteger i = 0; i < arrTitle.count; i++){
            WBPopMenuModel * info = [WBPopMenuModel new];
            info.image = arrImage[i];
            info.title = arrTitle[i];
            [obj addObject:info];
        }
        __block vcFriendCircle *blockSelf = self;
        [[WBPopMenuSingleton shareManager] showPopMenuSelecteWithFrame:200
                                                                 right:44
                                                                  item:obj
                                                                action:^(NSInteger index) {
                                                                    [blockSelf rightSelect:index];
                                                                }];
    }else{
        NSLog(@"btnAdd");
        [self performSegueWithIdentifier:@"circle_addEdit" sender:nil];
    }
}

-(void)rightSelect:(NSInteger)index
{
    if (index == 0){
        NSLog(@"");
        TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入圈号:" message:@""];
        
        
        [alterAccount showWithTXFActionSure:^(id str) {
            NSLog(@"输入的圈子号码");
            [self getTargetGroup:(NSString *)str];
        }cancel:^{} keyboardType:UIKeyboardTypeNumberPad];
    }else{
        QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
        reader.modalPresentationStyle = UIModalPresentationFormSheet;
        reader.delegate = self;
        
        __block vcFriendCircle *blockSelf = self;
        [reader setCompletionWithBlock:^(NSString *resultAsString)
         {
             NSLog(@"---- 扫描到：%@", resultAsString);
             blockSelf->isNotRequest = YES;
             [blockSelf.navigationController popViewControllerAnimated:YES];
             
             NSRange range = [resultAsString rangeOfString:orReaderPrefix];
             if (range.length > 0)
             {
                 NSString *dicString = [resultAsString substringFromIndex:range.length + 3];
                 NSDictionary *dicDataFromOR = [DFD dictionaryWithJsonString:dicString];
                 if (dicDataFromOR.count) {
                     NSString *groupid = dicDataFromOR.allValues[0];
                     [blockSelf getTargetGroup:groupid];
                 }
             }
             else LMBShowInBlock(@"无效的二维码");
         }];
        
        [self.navigationController pushViewController:reader animated:YES];
    }
}


- (void)refreshData
{
    isHaveRequest = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @6, @NO] inContext:DBefaultContext] integerValue] > 0;
    // 兼容上个版本
    __block vcFriendCircle *blockSelf = self;
    if (!blockSelf.userInfo.countryID) {
        blockSelf.userInfo.countryID = @"1";
        blockSelf.userInfo.stateID = @"11";
        blockSelf.userInfo.cityID = @"0";
        DBSave;
    }
    
    RequestCheckNoWaring(
             [net getMyGroupInfo:blockSelf.userInfo.access
               user_country_code:blockSelf.userInfo.countryID
                 user_state_code:blockSelf.userInfo.stateID
                  user_city_code:blockSelf.userInfo.cityID];,
             [blockSelf dataSuccessBack_getMyGroupInfo:dic];);
}

// 初始化数据
- (void)initData
{
    [Group MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@", @"cache"] inContext:DBefaultContext];
    arrMyGroup = [Group findAllSortedBy:@"is_admin" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and is_around == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
    
    arrAroundGroup = [Group findAllSortedBy:@"group_id" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and is_around == %@", self.userInfo.access, @YES] inContext:DBefaultContext];
}

// 初始化布局控件
- (void)initView
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    self.tabView.contentSize                  = CGSizeMake(ScreenWidth, ScreenHeight);
    self.tabView.dataSource                   = self;
    self.tabView.delegate                     = self;
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.backgroundColor              = DLightGrayBlackGroundColor;
    [self.view addSubview:self.tabView];

    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] init];
        view.frame = CGRectMake(0, 0, ScreenWidth, 1);
        view.backgroundColor = self.tabView.backgroundColor;
        view;
    });
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(section == 0){
        return  isHaveRequest ?  1 : 0;
    }else if(section == 1){
        return arrMyGroup.count;
    }else{
        return arrAroundGroup.count;
    }
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section) {
        tvcFriend *cell = [tvcFriend cellWithTableView:tableView];
        cell.imv.image = [UIImage imageNamed:@"circle_notice_01"];
        cell.lbl.text = kString(@"加入申请");
        return cell;
    }else{
        tvcCircle *cell = [tvcCircle cellWithTableView:tableView];
        if (indexPath.section == 1)
        {
            cell.group = arrMyGroup[indexPath.row];
            if (cell.group.is_admin)
            {
                __weak vcFriendCircle *blockSelf = self;
                __weak Group * blockgroup = cell.group;
                cell.editClick = ^{
                    [blockSelf performSegueWithIdentifier:@"circle_addEdit" sender:blockgroup];
                };
            }else{
                cell.editClick = nil;
            }
        }else if (indexPath.section == 2){
            cell.group = arrAroundGroup[indexPath.row];
            cell.editClick = nil;
        }
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsMake(0, Bigger(RealHeight(115), 70), 0, 0);
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section){
        if (isHaveRequest) {
            return Bigger(RealHeight(90), 50);
        }else{
            return 0;
        }
    }else if(indexPath.section == 1 && !arrMyGroup.count){
        return 0;
    }else{
        return Bigger(RealHeight(115), 70);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((section == 1 && !arrMyGroup.count) || (section == 2 && !arrAroundGroup.count) ) {
        return 1;
    }
    
    if (!isHaveRequest)
    {
        if (section == 2 && !arrMyGroup.count ) {
            return 1;
        }
        if (section == 1) {
            return 5;
        }
    }
    return 15;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1 && arrMyGroup.count) {
        return kString(@"我的圈子");
    }
    if (section == 2 && arrAroundGroup.count) {
        return kString(@"同城圈子");
    }
    return @"";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!indexPath.section) {
        [self performSegueWithIdentifier:@"circelDetails_request" sender:nil];
    }else{
        Group *group;
        if (indexPath.section == 1) {
            group = arrMyGroup[indexPath.row];
        }else if (indexPath.section == 2){
            group = arrAroundGroup[indexPath.row];
            
            // 这里的目的是, 如果选中的同城的圈子也是我加入的圈子
            Group *g = [Group findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and is_around == %@ and group_id == %@", self.userInfo.access, @NO, group.group_id] inContext:DBefaultContext];
            if (g)
                group = g;
        }
        [self performSegueWithIdentifier:@"circle_circleDetails" sender:group];
    }
}

#pragma mark - ------------------------------------- 私有方法


-(void)getTargetGroup:(NSString *)groupID
{
    // 这里要判断，搜索的圈子是否是本地已经有的圈子
    Group *g_my = [Group findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and group_id == %@ and is_around == %@", self.userInfo.access, groupID, @NO] inContext:DBefaultContext];
    Group *g_around = [Group findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and group_id == %@ and is_around == %@", self.userInfo.access, groupID, @YES] inContext:DBefaultContext];
    if (g_my) {
        [self performSegueWithIdentifier:@"circle_circleDetails" sender:g_my];
    }else if (g_around){
        [self performSegueWithIdentifier:@"circle_circleDetails" sender:g_around];
    }else{
        __block vcFriendCircle *blockSelf = self;
        MBShowAll;
        HDDAF;
        RequestCheckAfter(
              [net getTargetGroupInfo:blockSelf.userInfo.access
                             group_id:groupID];
              , [blockSelf dataSuccessBack_getTargetGroupInfo:dic];)
    }
}


-(void)dataSuccessBack_getMyGroupInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        // 删除所有
        [Group MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        
        NSArray *arrMyGroup_              = dic[@"my_group"];
        NSArray *arrAroundGroup_          = dic[@"city_group"];
//        NSArray *arrAll                   = [arrMyGroup_ arrayByAddingObjectsFromArray:arrAroundGroup_];
        
        __block vcFriendCircle *blockSelf = self;
        blockSelf.arrAroundGroup = [Group objectsByArray:arrAroundGroup_
                                                   context:DBefaultContext
                                              perfectBlock:^(id model) {
                                                  Group *group = model;
                                                  group.access = blockSelf.userInfo.access;
                                                  group.is_admin  = @NO;
                                                  group.is_around = @YES;
                                              }];
        // 先排序
        arrMyGroup_ = [DFD sort:[arrMyGroup_ mutableCopy] byString:@"is_admin"];
        blockSelf.arrMyGroup = [Group objectsByArray:arrMyGroup_
                                               context:DBefaultContext
                                          perfectBlock:^(id model) {
                                              Group *group = model;
                                              group.access = blockSelf.userInfo.access;
                                              group.is_around = @NO;
                                          }];
//
//        
////        NSMutableArray *arrMyGroupTag     = [@[] mutableCopy];
////        NSMutableArray *arrAroundGroupTag = [@[] mutableCopy];
////        for (NSDictionary *dicSub in arrAll)
////        {
////            Group *group               = [Group MR_createEntityInContext:DBefaultContext];
////            group.access               = self.userInfo.access;
////            group.group_id             = dicSub[@"group_id"];
////            group.admin_userid         = dicSub[@"admin_userid"];
////            group.admin_user_pic_url   = dicSub[@"admin_user_pic_url"];
////            group.admin_user_nick_name = dicSub[@"admin_user_nick_name"];
////            group.group_pic_url        = dicSub[@"group_pic_url"];
////            group.group_name           = dicSub[@"group_name"];
////            group.group_country_code   = dicSub[@"group_country_code"];
////            group.group_state_code     = dicSub[@"group_state_code"];
////            group.group_city_code      = dicSub[@"group_city_code"];
////            group.group_notice         = dicSub[@"group_notice"];
////            group.group_member_num     = dicSub[@"group_member_num"];
////            group.group_notice_time    = dicSub[@"group_notice_time"] ? dicSub[@"group_notice_time"]:@"0";
////            group.admin_user_gender    = @([dicSub[@"admin_user_gender"] boolValue]);
////            group.update_time          = @0;
////            if ([dicSub.allKeys containsObject:@"is_admin"]) {
////                group.is_admin         = @([dicSub[@"is_admin"] boolValue]);
////                group.is_around        = @NO;
////                DBSave;
////                
////                [arrMyGroupTag addObject:group];
////            }else{
////                group.is_admin         = @NO;
////                group.is_around        = @YES;
////                DBSave;
////                [arrAroundGroupTag addObject:group];
////            }
////        }
//        
//        
//        arrMyGroup     = arrMyGroupTag;
//        arrAroundGroup = arrAroundGroupTag;
        
        [self.tabView reloadData];
    }
}

-(void)dataSuccessBack_getTargetGroupInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        
        //NSLog(@"getTargetGroupInfo dic : %@", dic);
//        Group *groupCache = [Group MR_createEntityInContext:DBefaultContext];
        
        Group *groupCache = [Group objectByDictionary:dic
                                              context:DBefaultContext
                                         perfectBlock:^(id model) {
                                             Group *group = model;
                                             group.access    = @"cache";
                                             group.is_admin  = @NO;
                                             group.is_around = @YES;
                                             group.update_time =@([group.group_notice_time longLongValue]);
                                         }];
        
//        groupCache.access               = @"cache";
//        groupCache.group_id             = dic[@"group_id"];
//        groupCache.admin_userid         = dic[@"admin_userid"];
//        groupCache.admin_user_pic_url   = dic[@"admin_user_pic_url"];
//        groupCache.admin_user_nick_name = dic[@"admin_user_nick_name"];
//        groupCache.group_pic_url        = dic[@"group_pic_url"];
//        groupCache.group_name           = dic[@"group_name"];
//        groupCache.group_country_code   = dic[@"group_country_code"];
//        groupCache.group_state_code     = dic[@"group_state_code"];
//        groupCache.group_city_code      = dic[@"group_city_code"];
//        groupCache.group_notice         = dic[@"group_notice"];
//        groupCache.group_notice_time    = dic[@"group_notice_time"];
//        groupCache.group_member_num     = dic[@"group_member_num"];
//        groupCache.is_admin             = @NO;
//        groupCache.is_around            = @YES;
//        groupCache.update_time          = @([groupCache.group_notice_time longLongValue]);
//        groupCache.admin_user_gender    = @([dic[@"admin_user_gender"] boolValue]);
//        DBSave;
        
        [self performSegueWithIdentifier:@"circle_circleDetails" sender:groupCache];
    }else if ([dic[@"status"] intValue] == 13){
        LMBShow(@"圈子不存在");
    }
}

#pragma mark - ------------------------------------- 属性实现

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"circle_circleDetails"]) {
        vcCircleDetails *con =(vcCircleDetails *)[segue destinationViewController];
        con.group = sender;
    }else if ([segue.identifier isEqualToString:@"circle_addEdit"]){
        vcAddEditCircle *con = (vcAddEditCircle *)[segue destinationViewController];
        con.group = sender;
    }
}


































@end
