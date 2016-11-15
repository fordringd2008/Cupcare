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

#import "vcCircleRequest.h"
#import "tvcCircleRequest.h"

#pragma mark - 宏命令

@interface vcCircleRequest ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tabView;
    NSMutableArray *arrData;
}

@end

@implementation vcCircleRequest

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButton:nil text:@"加入申请"];
    
    [self refreshData];
    [self initView];
}

- (void)dealloc
{
    // 这里移除观察者
    NSLog(@"vcCircleRequest销毁了");
}


// 初始化数据
- (void)refreshData
{
    arrData = [[FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @6, @NO] inContext:DBefaultContext] mutableCopy];
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
    [tabView registerNib:[UINib nibWithNibName:@"tvcCircleRequest" bundle:nil] forCellReuseIdentifier:@"tvcCircleRequest"];
    tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view;
    });
    [self.view addSubview:tabView];
}

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
    tvcCircleRequest*cell = [tvcCircleRequest cellWithTableView:tableView];
    FriendRequest *fr = arrData[indexPath.row];
    cell.fr = fr;
    __weak vcCircleRequest *blockSelf = self;
    __weak NSString *groupID          = fr.group_id;
    __weak NSString *userid           = fr.friend_id;
    cell.acceptRequest                 = ^{
        [blockSelf updateShip:groupID userid:userid isAccept:YES];
    };
    
    MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
    cell.rightButtons = @[btnDelete];
    cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
    btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
    {
        [blockSelf updateShip:groupID userid:userid isAccept:NO];
        return NO;
    };
    
    return cell;
}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        FriendRequest *fr = arrData[indexPath.row];
//        [self updateShip:fr.group_id userid:fr.friend_id isAccept:NO];
//    }
//}
//
////修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kString(@"删除");
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ------------------------------------- 私有方法
-(void)updateShip:(NSString *)groupID userid:(NSString *)userid isAccept:(BOOL)isAccept
{
    __weak vcCircleRequest *blockSelf = self;
    MBShowAll
    HDDAF
    RequestCheckAfter(
          [net allowJoinGroup:blockSelf.userInfo.access
                 apply_userid:userid
                     group_id:groupID
                 allow_status:isAccept];,
          [blockSelf dataSuccessBack_allowJoinGroup:dic
                                            groupID:(NSString *)groupID
                                             userID:(NSString *)userid
                                           isAccept:isAccept];);
}

-(void)dataSuccessBack_allowJoinGroup:(NSDictionary *)dic
                              groupID:(NSString *)groupID
                               userID:(NSString *)userID
                             isAccept:(BOOL)isAccept
{
    MBHide
    if (CheckIsOK)
    {
        NSArray * arr = [FriendRequest findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and friend_id == %@ and group_id == %@", self.userInfo.access, @6, userID, groupID] inContext:DBefaultContext];
        for (FriendRequest *f in arr) {
            f.isOver = @YES;
        }
        DBSave;
        
        [self refreshData];
        [tabView reloadData];
        if (isAccept) {
            LMBShow(@"已接受")
        }else{
            LMBShow(@"已拒绝")
        }
    }
}

#pragma mark - ------------------------------------- 属性实现

#pragma mark -





































@end
