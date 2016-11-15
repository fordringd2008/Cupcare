//
//  vcFriend.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriend.h"
#import "QRCodeReaderViewController.h"
#import "tvcFriend.h"
#import "vcFriendDetails.h"
#import "WBPopMenuModel.h"
#import "WBPopMenuSingleton.h"
#import "TAlertView.h"
#import "NSString+Verify.h"

@interface vcFriend ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,QRCodeReaderDelegate>
{
    NSString *addAccount;
    
    NSInteger countOfFirst;                 // 第一个分区的行数
    
    
    BOOL isLeft;                            // 是否离开
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (strong, nonatomic) UITableView *tabView;
@property (strong, nonatomic) NSMutableArray *arrData;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;          // 要删除的行

@end

@implementation vcFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLeftButton:nil text:@"我的好友"];
    [self initRightButton:@"addFriend" text:nil];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg
                                                  forBarMetrics:UIBarMetricsDefault];
    isLeft = NO;
    [self initData];
    [self refreshData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    isLeft = YES;
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    NSLog(@" vcFriend 销毁了");
}

-(void)initData
{
    __block vcFriend *blockSelf = self;
    RequestCheckNoWaring(
          int dateValue = [DFD HmF2KNSDateToInt:DNow];
          [net getFriendsInfo:blockSelf.userInfo.access today_k_date:@(dateValue)];,
          [blockSelf dataSuccessBack_getFriendsInfo:dic];);
}

-(void)refreshData
{
    NSInteger countForAddFriend = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @(1), @(NO)] inContext:DBefaultContext] integerValue];
    if (countForAddFriend)
        countOfFirst = 2;
    else
        countOfFirst = 1;
    
    NSMutableArray *arrDat = [[Friend findAllSortedBy:@"user_id" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext] mutableCopy];
    
    Friend *fr_self = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
    
    if (fr_self)
        [arrDat removeObject:fr_self];
    self.arrData = [arrDat mutableCopy];
    [_tabView reloadData];
}


-(void)initView
{
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    self.view.backgroundColor = self.viewMain.backgroundColor = DLightGrayBlackGroundColor;
    [self initTable];
}

-(void)rightButtonClick
{
    NSArray *arrTitle = @[ kString(@"通过账号"), kString(@"通过二维码")];
    NSArray *arrImage = @[ @"circle_input", @"right_menu_QR" ];
    
    NSMutableArray *obj = [NSMutableArray array];
    for (NSInteger i = 0; i < arrTitle.count; i++){
        WBPopMenuModel * info = [WBPopMenuModel new];
        info.image = arrImage[i];
        info.title = arrTitle[i];
        [obj addObject:info];
    }
    __block vcFriend *blockSelf = self;
    [[WBPopMenuSingleton shareManager] showPopMenuSelecteWithFrame:200
                                                             right:4
                                                              item:obj
                                                            action:^(NSInteger index) {
                                                                [blockSelf rightSelect:index];
                                                            }];
}

-(void)rightSelect:(NSInteger)index
{
    __block vcFriend *blockSelf = self;
    if (index == 0)
    {
        TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入好友账号:" message:@""];
        [alterAccount showWithTXFActionSure:^(id str) {
            [blockSelf addFriendByAccount:str accountType: [(NSString*)str isEmailType] ? 1:2]; } cancel:^{} keyboardType:UIKeyboardTypeDefault];
    }else{
        [self addFriendByCamera];
    }
}

// accountType : 1 邮箱  2,电话  3 第三方
-(void)addFriendByAccount:(NSString *)str accountType:(int)accountType
{
    NSLog(@"%@", str);
    if (!str)
    {
        LMBShow(@"无效的二维码");return;
    }
    NSString *typeString = [NSString stringWithFormat:@"0%d", accountType];
    NSString *content = [NSString stringWithFormat:@"%@ %@", self.userInfo.user_nick_name, kString(@"申请加您为好友")];
    if ([str isEqualToString:self.userInfo.account])
    {
        [self dataSuccessBack_applyFriend:@{@"status":@"8"}];
    }
    else
    {
        __block vcFriend *blockSelf = self;
        RequestCheckAfter(
              [net applyFriend:blockSelf.userInfo.access
                friend_account:str
           friend_account_type:typeString
                  push_content:content];,
              [blockSelf dataSuccessBack_applyFriend:dic];);
    }
}

-(void)addFriendByCamera
{
    QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
    reader.modalPresentationStyle = UIModalPresentationFormSheet;
    reader.delegate = self;
    
    __block vcFriend *blockSelf = self;
    [reader setCompletionWithBlock:^(NSString *resultAsString)
    {
        [blockSelf.navigationController popViewControllerAnimated:YES];
        NSLog(@"----  %@", resultAsString);
        NSRange range = [resultAsString rangeOfString:orReaderPrefix];
        if (range.length > 0)
        {
            NSString *dicString = [resultAsString substringFromIndex:range.length + 3];
            NSDictionary *dicDataFromOR = [DFD dictionaryWithJsonString:dicString];
            NSString *email = dicDataFromOR.allValues[0];
            int accountType = 0;
            if ([dicDataFromOR.allKeys[0] isEqualToString:@"email"]) {
                accountType = 1;
            }else if ([dicDataFromOR.allKeys[0] isEqualToString:@"phone"]) {
                accountType = 2;
            }else if ([dicDataFromOR.allKeys[0] isEqualToString:@"third_party_id"]) {
                accountType = 3;
            }
            [blockSelf addFriendByAccount:email accountType:accountType];
        }
        else LMBShowInBlock(@"无效的二维码");
    }];
    
    [self.navigationController pushViewController:reader animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initTable
{
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    _tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    _tabView.dataSource = self;
    _tabView.delegate = self;
    _tabView.showsVerticalScrollIndicator = NO;
    _tabView.scrollEnabled = YES;
    _tabView.backgroundColor = DClear;
    _tabView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_tabView registerNib:[UINib nibWithNibName:@"tvcFriend" bundle:nil] forCellReuseIdentifier:@"tvcFriend"];
    _tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        view.backgroundColor = DClear;//_tabView.backgroundColor;
        view;
    });
    [_viewMain addSubview:_tabView];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!section) {
        return countOfFirst;
    }
    else
        return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriend *cell = [tvcFriend cellWithTableView:tableView];
    [cell.viewHot setHidden:YES];
    if (indexPath.section && self.arrData.count)              // 好友列表
    {
        [cell.imvRight setHidden:YES];
        Friend  *model = self.arrData[indexPath.row];
        cell.model = model;
        MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
        cell.rightButtons = @[btnDelete];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        __weak vcFriend *blockSelf = self;
        btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
        {
            blockSelf.currentIndexPath = indexPath;
            [blockSelf goToDeleteData];
            return NO;
        };
    }
    else
    {
        cell.lbl.font = [UIFont systemFontOfSize:14];
        if(countOfFirst > 1 && indexPath.row == 0)
        {
            cell.imv.image = [UIImage imageNamed:@"news_notice"];
            cell.lbl.text = kString(@"好友申请");
            [cell.viewHot setHidden:NO];
        }
        else
        {
            cell.imv.image = [UIImage imageNamed:@"rank_icon"];
            cell.lbl.text = kString(@"今日好友排名");
        }
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section)
        return Bigger(RealHeight(100), 60);//  60;
    else
        return Bigger(RealHeight(90), 50);//  50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0 && ((indexPath.row == 0 && countOfFirst == 1) || (indexPath.row == 1 && countOfFirst == 2)))
    {
        [self performSegueWithIdentifier:@"friend_to_rank" sender:nil];
    }
    else if(indexPath.section == 0 && indexPath.row == 0 && countOfFirst == 2)
    {
        [self performSegueWithIdentifier:@"friend_to_request" sender:nil];
    }
    else if(indexPath.section)
    {
        Friend *model = self.arrData[indexPath.row];
        [self performSegueWithIdentifier:@"friend_to_details" sender:model];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section && self.arrData.count) {
        return kString(@"我的好友");
    }
    else
        return @"";
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section)
        return YES;
    else
        return NO;
}


// 去执行操作
-(void)goToDeleteData
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定要解除好友关系吗?"];
    [alert showWithActionSure:^
     {
         //NSLog(@"----- %ld", (long)currentIndexPath.row);
         Friend *fr = self.arrData[self.currentIndexPath.row];
         __block vcFriend *blockSelf = self;
         RequestCheckAfter(
               [net updateFriendship:blockSelf.userInfo.access
                           friend_id:fr.user_id
                         ship_status:@"3"
                           nick_name:fr.user_nick_name];,
               [blockSelf dataSuccessBack_updateFriendship:dic];);
         [self deleteTableData];
     } cancel:^{}];
}

// 确认删除这一行
-(void)deleteTableData
{
    Friend *fr = self.arrData[self.currentIndexPath.row];                    // 这个本地的对象
    [self.arrData removeObject:fr];
    [Friend MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, fr.user_id] inContext:DBefaultContext];
    DBSave;
    
    [_tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_tabView endUpdates];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section ? 20:0;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"friend_to_details"])
    {
        vcFriendDetails *vc = (vcFriendDetails *)segue.destinationViewController;
        vc.model = sender;
    }
}

-(void)dataSuccessBack_applyFriend:(NSDictionary *)dic
{
    NSInteger statue = [dic[@"status"] integerValue];
    switch (statue) {
        case 0:
            LMBShow(@"申请已发送");
            break;
        case 5:
            LMBShow(@"好友不存在");
            break;
        case 8:
            LMBShow(@"不能对用户自身操作");
            break;
        case 9:
            LMBShow(@"你们已经是好友了");
            break;
    }
}


-(void)dataSuccessBack_updateFriendship:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSLog(@"删除成功");
    }
}

-(void)dataSuccessBack_getFriendsInfo:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSLog(@"----%@", dic);
        
        NSArray *arrData = dic[@"friends_info"];
        if (!arrData) return;
        NSArray *arrFriendOld = [Friend findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext];
        for (Friend *f in arrFriendOld)
            f.tag = @NO;
        DBSave;
        
        __block vcFriend *blockSelf = self;
        [Friend objectsByArray:dic[@"friends_info"]
                       context:DBefaultContext
                  perfectBlock:^(id model) {
                      Friend *fr = model;
                      fr.access = blockSelf.userInfo.access;
                      fr.tag    = @YES;
                  }];
        
        
//
//        for (int i = 0; i < arrData.count; i++)
//        {
//            NSDictionary *dicFr         = arrData[i];
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

@end
