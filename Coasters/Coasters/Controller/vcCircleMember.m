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

#import "vcCircleMember.h"
#import "tvcCircleMember.h"
#import "vcAddCircleMember.h"


#pragma mark - 宏命令

@interface vcCircleMember ()<UITableViewDelegate, UITableViewDataSource>
{
    
    UITableView *tabView;
    NSArray *arrData;
    
    BOOL isEditable;        // 是否可以编辑
}

@end

@implementation vcCircleMember

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButton:nil text:@"圈子成员"];
    
    if (isEditable)
        [self initRightButton:@"Increase" text:nil];
    
    [self refreshData];
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
    NSLog(@"vcCircleMember销毁了");
}

-(void)rightButtonClick
{
    [self performSegueWithIdentifier:@"member_add" sender:nil];
}


// 初始化数据
- (void)refreshData
{
    arrData = _arrGroupMember;
}

// 初始化布局控件
- (void)initView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - StateBarHeight) style:UITableViewStyleGrouped];
    tabView.contentSize                  = CGSizeMake(ScreenWidth, ScreenHeight);
    tabView.dataSource                   = self;
    tabView.delegate                     = self;
    tabView.rowHeight                    = Bigger(RealHeight(100), 60);
    tabView.showsVerticalScrollIndicator = NO;
    tabView.backgroundColor              = DLightGrayBlackGroundColor;
    [tabView registerNib:[UINib nibWithNibName:@"tvcCircleMember" bundle:nil] forCellReuseIdentifier:@"tvcCircleMember"];
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
    tvcCircleMember *cell = [tvcCircleMember cellWithTableView:tableView];
    NSDictionary *dicModel = arrData[indexPath.row];
    [cell.imv sd_setImageWithURL:[NSURL URLWithString:dicModel[@"user_pic_url"]] placeholderImage:DefaultLogo_Gender([dicModel[@"user_pic_url"] boolValue])];
    if (isEditable) {
        NSDictionary *dicModel = arrData[indexPath.row];
        if (![[dicModel[@"userid"] description] isEqualToString:[self.userInfo.user_id description]]) {
            MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
            cell.rightButtons = @[btnDelete];
            cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
            __weak vcCircleMember *blockSelf = self;
            btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
            {
                [blockSelf goToDeleteData:indexPath.row];
                return NO;
            };
        }
    }
    cell.imv.layer.cornerRadius  = (Bigger(RealHeight(100), 60) - 10) / 2;
    cell.imv.layer.masksToBounds = YES;
    cell.lbl.text                = [dicModel[@"user_nick_name"] description];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)goToDeleteData:(NSInteger)row
{
    NSLog(@"删除第%@", @(row));
    NSDictionary *dicModel = arrData[row];
    __block NSString *userid = dicModel[@"userid"];
    __block vcCircleMember *blockSelf = self;
    MBShowAll;
    HDDAF;
    RequestCheckAfter(
                      [net deleteGroupMember:blockSelf.userInfo.access
                                    group_id:blockSelf.group.group_id
                                      userid:userid];,
                      [blockSelf dataSuccessBack_deleteGroupMember:dic userID:userid];)
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 不能删除自己
    if (isEditable) {
        NSDictionary *dicModel = arrData[indexPath.row];
        if ([[dicModel[@"userid"] description] isEqualToString:[self.userInfo.user_id description]]) {
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}
//
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kString(@"删除");
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete && arrData.count > indexPath.row)
//    {
//        NSLog(@"删除第%@", @(indexPath.row));
//        NSDictionary *dicModel = arrData[indexPath.row];
//        __block NSString *userid = dicModel[@"userid"];
//        __block vcCircleMember *blockSelf = self;
//        MBShowAll;
//        HDDAF;
//        RequestCheckAfter(
//              [net deleteGroupMember:blockSelf.userInfo.access
//                            group_id:blockSelf.group.group_id
//                              userid:userid];,
//              [blockSelf dataSuccessBack_deleteGroupMember:dic userID:userid];)
//        
//    }
//}

#pragma mark - ------------------------------------- 私有方法
-(void)dataSuccessBack_deleteGroupMember:(NSDictionary *)dic userID:(NSString *)userID
{
    MBHide;
    if (CheckIsOK) {
        LMBShow(@"已删除");
        NSMutableArray *arrNew = [@[] mutableCopy];
        for(NSDictionary *dicTag in _arrGroupMember)
        {
            if(![dicTag[@"userid"] isEqualToString:userID])
            {
                [arrNew addObject:dicTag];
            }
        }
        _arrGroupMember = [arrNew mutableCopy];
        [self refreshData];
        [tabView reloadData];
    }
}



#pragma mark - ------------------------------------- 属性实现


-(void)setGroup:(Group *)group
{
    _group = group;
    isEditable = [group.is_admin boolValue];
}

-(void)setArrGroupMember:(NSArray *)arrGroupMember
{
    _arrGroupMember = arrGroupMember;
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"member_add"]) {
        vcAddCircleMember *con = (vcAddCircleMember *)[segue destinationViewController];
        con.arrGroupMember = _arrGroupMember;
        con.group = _group;
    }
}





































@end
