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

#import "vcCircleDetails.h"
#import "cltCircle.h"
#import "vcORCode.h"
#import "vcAddEditCircle.h"
#import "vcCircleNotice.h"
#import "vcCircleRank.h"
#import "vcCircleMember.h"
#import "TAlertView.h"

typedef enum {
    CircleControl_Dissolution = 0,         // 解散
    CircleControl_Join,                    // 加入
    CircleControl_Exit                     // 退出
} CircleControlType;                       // 圈子的操作

#pragma mark - 宏命令

@interface vcCircleDetails ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    __weak IBOutlet UIView *viewMain;
    __weak IBOutlet NSLayoutConstraint *viewMainHeight;
    __weak IBOutlet UIView *viewSecond;
    __weak IBOutlet NSLayoutConstraint *viewSecondHeight;
    __weak IBOutlet UIButton *btnBottom;
    __weak IBOutlet UILabel *lblBottom;
    __weak IBOutlet UIImageView *imvLogo;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UILabel *lblCount;
    
    __weak IBOutlet UILabel *lblNoticeTitle;
    
    __weak IBOutlet UILabel *lblNotice;
    
    UICollectionView *colleView;
    
    BOOL is4;
    NSArray *arrGroupMember;
    
    CircleControlType circleControlType;
}

@end

@implementation vcCircleDetails

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"vcCircleDetails  viewDidLoad ");
    
    is4 = [_group.is_admin boolValue];
    [self initLeftButton:nil text:@"圈子主页"];
    
    [self initData];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
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
    NSLog(@"vcCirecleDetails销毁了");
}


// 初始化数据
- (void)initData
{
    if ([_group.is_admin boolValue]) {
        circleControlType = CircleControl_Dissolution;
    }else if([_group.is_around boolValue]){
        circleControlType = CircleControl_Join;
    }else{
        circleControlType = CircleControl_Exit;
    }
}
-(void)refreshData
{
    NSString * today_k_date = [@([DFD HmF2KNSDateToInt:DNow]) description];
    NSString * month_k_date = [@([DFD HmF2KNSDateToInt:[DFD getDateFromArr:@[@([DFD getFromDate:DNow type:1]), @([DFD getFromDate:DNow type:2]), @1]]]) description];
    
    __block vcCircleDetails *blockSelf = self;
    RequestCheckNoWaring(
             [net getGroupMember:blockSelf.userInfo.access
                        group_id:blockSelf.group.group_id
                    today_k_date:today_k_date
                    month_k_date:month_k_date];,
             [blockSelf dataSuccessBack_getGroupMember:dic];)
}

// 初始化布局控件
- (void)initView
{
    self.view.backgroundColor = viewMain.backgroundColor = DLightGrayBlackGroundColor;
    viewSecondHeight.constant = (is4 ? RealHeight(280) : RealHeight(140)) + 30;
    viewMainHeight.constant = 160 + RealHeight(400) + viewSecondHeight.constant + 100;

    colleView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, viewSecondHeight.constant) collectionViewLayout:({
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake(RealWidth(200) , RealHeight(140));
        layout;
    })];
    colleView.backgroundColor = DWhite;
    colleView.scrollEnabled   = NO;
    colleView.delegate        = self;
    colleView.dataSource      = self;
    [colleView registerNib:[UINib nibWithNibName:@"cltCircle" bundle:nil] forCellWithReuseIdentifier:@"cltCircle"];
    
    [viewSecond addSubview:colleView];
    
    imvLogo.layer.cornerRadius = 10;
    imvLogo.layer.masksToBounds = YES;
    
//    lblBottom.layer.cornerRadius = 10;
//    lblBottom.layer.masksToBounds = YES;
    
    switch (circleControlType) {
        case CircleControl_Dissolution:
            lblBottom.text = kString(@"解散圈子");
            break;
        case CircleControl_Join:
            lblBottom.text = kString(@"加入圈子");
            break;
        case CircleControl_Exit:
            lblBottom.text = kString(@"退出圈子");
            break;
    }
    btnBottom.backgroundColor = DRed;
    lblBottom.font = [UIFont fontWithName : @"Helvetica-Bold Oblique" size : 20 ];
    [btnBottom setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateNormal];
    [btnBottom setBackgroundImage:[UIImage imageFromColor:RGB(192, 25, 42)] forState:UIControlStateHighlighted];
    //RGB(192,39,44)
    btnBottom.layer.cornerRadius = 10;
    btnBottom.layer.masksToBounds = YES;
    
    lblNoticeTitle.text = kString(@"圈子公告");
    
    [self refreshView];
}

-(void)refreshView
{
    lblNotice.text = !_group.group_notice.length ? kString(@"这个圈主有点懒,什么都没留下."):_group.group_notice;
    
    [imvLogo sd_setImageWithURL:[NSURL URLWithString:_group.group_pic_url] placeholderImage:DefaultCircleLogoImage];
    lblName.text = _group.group_name;
    lblNumber.text = [NSString stringWithFormat:@"%@:%@", kString(@"圈号"), _group.group_id];
    lblCount.text  = [NSString stringWithFormat:@"%@%@", _group.group_member_num, kString(@"人")];
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
#pragma mark 1 target-action                    普通
- (IBAction)btnClick:(UIButton *)sender {
    if (sender.tag == 99 )                     // 99 是操作按钮
    {
        __block vcCircleDetails *blockSelf = self;
        switch (circleControlType) {
            case CircleControl_Dissolution:
            {
                TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定解散圈子?"];
                [alert showWithActionSure:^
                 {
                     NSLog(@"解散圈子");
                     MBShowAll
                     HDDAF
                     RequestCheckAfter(
                           [net deleteGroup:blockSelf.userInfo.access
                                   group_id:blockSelf.group.group_id];,
                           [blockSelf dataSuccessBack_deleteGroup:dic];)
                 } cancel:^{}];
            }
                break;
            case CircleControl_Join:
            {
                MBShowAll
                HDDAF
                NSLog(@"加入圈子");
                RequestCheckAfter(
                      [net applyJoinGroup:self.userInfo.access
                                 group_id:blockSelf.group.group_id];,
                      [blockSelf dataSuccessBack_applyJoinGroup:dic];)
            }
                break;
            case CircleControl_Exit:
            {
                MBShowAll
                HDDAF
                NSLog(@"退出圈子");
                RequestCheckAfter(
                      [net exitGroup:blockSelf.userInfo.access
                            group_id:blockSelf.group.group_id];,
                      [blockSelf dataSuccessBack_exitGroup:dic];)
                
            }
                break;
        }
    }else
    {
        if ([_group.group_notice length] || [_group.is_admin boolValue]) {
            [self performSegueWithIdentifier:@"circleDetails_notice" sender:nil];
        }
        else{
            LMBShow(@"只有圈主才能编辑圈公告");
        }
    }
}

#pragma mark 2 delegate dataSource protocol     代理协议
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"circelDetails_orcode" sender:nil];
            break;
        case 1:
            if (is4) {
                [self performSegueWithIdentifier:@"circledetails_addEdit" sender:nil];
            }else{
                [self performSegueWithIdentifier:@"circelDetails_member" sender:nil];
            }
            break;
        case 2:
            if (is4) {
                [self performSegueWithIdentifier:@"circelDetails_member" sender:nil];
            }else{
                [self performSegueWithIdentifier:@"circelDetails_circleRank" sender:nil];
            }
            break;
        case 3:
            [self performSegueWithIdentifier:@"circelDetails_circleRank" sender:nil];
            break;
    }
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return is4 ? 4 : 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"cltCircle";
    cltCircle *cell = (cltCircle *)[collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    
    cell.backgroundColor = DWhite;

    
    switch (indexPath.row) {
        case 0:
            cell.imv.image = [UIImage imageNamed:@"circle_orcode_01"];
            cell.lbl.text = kString(@"圈子二维码");
            break;
        case 1:
            if (is4) {
                cell.imv.image = [UIImage imageNamed:@"xinxiguanli_01"];
                cell.lbl.text = kString(@"信息管理");
            }else{
                cell.imv.image = [UIImage imageNamed:@"circle_personnel_icon_01"];
                cell.lbl.text = kString(@"圈子成员");
            }
            break;
        case 2:
            if (is4) {
                cell.imv.image = [UIImage imageNamed:@"circle_personnel_icon_01"];
                cell.lbl.text = kString(@"圈子成员");
            }else{
                cell.imv.image = [UIImage imageNamed:@"circle_ranking_01"];
                cell.lbl.text = kString(@"查看排行");
            }
            break;
        case 3:
            cell.imv.image = [UIImage imageNamed:@"circle_ranking_01"];
            cell.lbl.text = kString(@"查看排行");
            break;
    }
    
    cell.selectedBackgroundView = ({
        UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
        selectedBGView.backgroundColor = DLightGrayBlackGroundColor;
        selectedBGView;
    });
    
    return cell;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
//



#pragma mark - ------------------------------------- 私有方法
 
                               
-(void)dataSuccessBack_getGroupMember:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        //  排序，把自己放在最前面
        NSMutableArray *arrTag = [dic[@"group_member"] mutableCopy];
        int index = -1;
        for (int i = 0 ; i < arrTag.count; i++)
        {
            NSDictionary *dicTag = arrTag[i];
            if ([[dicTag[@"userid"] description] isEqualToString:_group.admin_userid]) {
                index = i;
                break;
            }
        }
        if (index > 0)
            [arrTag exchangeObjectAtIndex:0 withObjectAtIndex:index];
        
        arrGroupMember = arrTag;
        
        _group.group_member_num = [@(arrGroupMember.count) description];
        DBSave;
        [self refreshView];
    }
}

-(void)dataSuccessBack_applyJoinGroup:(NSDictionary *)dic
{
    MBHide
    if (CheckIsOK)
    {
        LMBShow(@"请求已发送");
    }
}

-(void)dataSuccessBack_exitGroup:(NSDictionary *)dic
{
    MBHide
    if (CheckIsOK)
    {
        LMBShow(@"已退出");
        __block vcCircleDetails *blockSelf = self;
        NextWaitInMainAfter([blockSelf back];, 1);
    }
}


-(void)dataSuccessBack_deleteGroup:(NSDictionary *)dic
{
    MBHide
    if (CheckIsOK)
    {
        LMBShow(@"已解散");
        __block vcCircleDetails *blockSelf = self;
        NextWaitInMainAfter([blockSelf back];, 1);
    }
}



#pragma mark - ------------------------------------- 属性实现
-(void)setGroup:(Group *)group
{
    NSLog(@"设置属性");
    _group = group;
}




#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"circelDetails_orcode"]) {
        vcORCode *con = (vcORCode *)[segue destinationViewController];
        con.orcodeType = CircleORCode;
        con.group = _group;
    }else if ([segue.identifier isEqualToString:@"circledetails_addEdit"]) {
        vcAddEditCircle *con = (vcAddEditCircle *)[segue destinationViewController];
        con.group = _group;
        __weak vcCircleDetails *blockSelf = self;
        con.editOKBlock = ^(Group *g){
            blockSelf.group = g;
            [blockSelf refreshView];
        }; 
    }else if ([segue.identifier isEqualToString:@"circleDetails_notice"]) {
        vcCircleNotice *con = (vcCircleNotice *)[segue destinationViewController];
        con.group = _group;
        __weak vcCircleDetails *blockSelf = self;
        con.editOKBlock = ^(Group *g){
            blockSelf.group = g;
            [blockSelf refreshView];
        };
    }else if ([segue.identifier isEqualToString:@"circelDetails_circleRank"]) {
        vcCircleRank *con = (vcCircleRank *)[segue destinationViewController];
        con.arrGroupMember = arrGroupMember;
    }else if ([segue.identifier isEqualToString:@"circelDetails_member"]) {
        vcCircleMember *con = (vcCircleMember *)[segue destinationViewController];
        con.group          = _group;
        con.arrGroupMember = arrGroupMember;
    }
}



































@end
