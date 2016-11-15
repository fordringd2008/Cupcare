//
//  vcLeft.m
//  MasterDemo
//
//  Created by 丁付德 on 15/6/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcLeft.h"
#import "tvcLeft.h"
#import "vcIndex.h"

#define viewBackGroundColor             RGBA(42, 46, 51, 1)


@interface vcLeft () <UITableViewDelegate, UITableViewDataSource>
{
    CGRect BIGFRAME;
    CGRect SMALLFRAME;
    NSTimeInterval ANIMATIONTIME;
    BOOL isLeft;                        //  是否离开
}

@property (weak, nonatomic) IBOutlet UIScrollView       *scrBig;
@property (weak, nonatomic) IBOutlet UIView             *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView        *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel            *lblemail;
@property (weak, nonatomic) IBOutlet UITableView        *tabView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tbvHeight;
@property (weak, nonatomic) IBOutlet UIView             *viewBig;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBigBottom;


@property (strong, nonatomic) NSArray *arrTblImgData;           // 默认的图片
@property (strong, nonatomic) NSArray *arrTblImgData2;          // 选中时的图片
@property (strong, nonatomic) NSArray *arrTblNameData;

@end

@implementation vcLeft

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initLeft];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTable];
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    isLeft = NO;
    [self checkUser];
    [self.view setFrame:CGRectMake(-100, 0, ScreenWidth, ScreenHeight)];
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    [_tabView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    isLeft = YES;
    [_tabView setUserInteractionEnabled:YES];
    [super viewWillDisappear:animated];
}

-(void)initLeft
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.left = self;
}


-(void)initView
{
    _scrWidth.constant = 267.0;
    _viewMainHeight.constant = ScreenHeight;
    
    self.view.backgroundColor = RGB(64,64,64);
    _viewBigBottom.constant = 0;
    _viewBig.layer.masksToBounds = YES;
    
    _imgHeight.constant = RealHeight(68);
    _lblHeight.constant = RealHeight(58);
    _tbvHeight.constant = RealHeight(64);
    _tabView.rowHeight = 50;

    BIGFRAME = CGRectMake(0, _tabView.frame.origin.y, 260, 375);
    SMALLFRAME = CGRectMake(-160, _tabView.frame.origin.y, 0, 0);
    ANIMATIONTIME = 0.35;
    
    _imgLogo.layer.cornerRadius = 25;
    _imgLogo.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _imgLogo.layer.borderWidth = 1;
    _imgLogo.layer.masksToBounds = YES;
    
    _lblemail.text = myUserInfo.account;
}

-(void)checkUser
{
    if (self.userInfo)
    {
        [_imgLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.logo] placeholderImage: DefaultLogo_Gender([self.userInfo.user_gender boolValue])];
        _lblemail.text = self.userInfo.user_nick_name.length ? self.userInfo.user_nick_name : self.userInfo.account;
    }
}


#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return _arrTblImgData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcLeft *cell = [tvcLeft cellWithTableView:tableView index:indexPath.row];
    cell.imgLogo.image = [UIImage imageNamed:_arrTblImgData[indexPath.row]];
    cell.lblName.text = _arrTblNameData[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        case 3:
        case 4:
        case 5:
            [cell.viewRedDot setHidden:YES];
            break;
        case 1:
        {
            NSInteger count = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @1, @NO] inContext:DBefaultContext] integerValue];
            if (count)
                [cell.viewRedDot setHidden:NO];
            else
                [cell.viewRedDot setHidden:YES];
        }
            break;
        case 2:
        {
            NSInteger count = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @6, @NO] inContext:DBefaultContext] integerValue];
            if (count)
                [cell.viewRedDot setHidden:NO];
            else
                [cell.viewRedDot setHidden:YES];
        }
            break;
    }
    
    cell.lblName.highlightedTextColor =  RGBA(16, 128, 218, 1);
    cell.imgLogo.highlightedImage = [UIImage imageNamed:_arrTblImgData2[indexPath.row]];
    cell.imvBig.highlightedImage = [UIImage imageFromColor:RGBA(0, 0, 0, 0.9)];
    if (IS_IPad) cell.imvBig.image = [UIImage imageFromColor:DBlack];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;   // 防止导航条出错
    if(isLeft) return;
    isLeft = YES;
    
    [_tabView setUserInteractionEnabled:NO];                        // 防止点击触发特效
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.appDelegate.sideViewController hideSideViewController:YES];
    [self.delegate selected:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Bigger(RealHeight(110), 50);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




-(void)initTable
{
//    _tabView.contentSize = CGSizeMake(ScreenWidth, 100);
//    Border(_tabView, DRed);
}

-(void)initData
{
    if(isHaveBalance)
    {
        // 电子称模式没有加入  我的圈子  注意
        _arrTblImgData = [[NSArray alloc] initWithObjects:@"cupcare-Individual", @"cupcare-Friends", @"cupcare-alarm_clock", @"cupcare-Electronic_balance", @"cupcare-Tips", @"cupcare-Set_up", nil];
        _arrTblImgData2 = [[NSArray alloc] initWithObjects:@"cupcare-Individual02", @"cupcare-Friends02", @"cupcare-alarm_clock02", @"cupcare-Electronic_balance02", @"cupcare-Tips02", @"cupcare-Set_up02", nil];
        _arrTblNameData = @[kString(@"个人信息"), kString(@"我的好友"), kString(@"闹钟"), kString(@"电子称"), kString(@"小贴士"), kString(@"设置")];
    }
    else
    {
        _arrTblImgData = @[@"cupcare-Individual", @"cupcare-Friends", @"quanzi_01", @"cupcare-alarm_clock", @"cupcare-Tips", @"cupcare-Set_up"];
        _arrTblImgData2 = @[@"cupcare-Individual02", @"cupcare-Friends02", @"quanzi_02", @"cupcare-alarm_clock02", @"cupcare-Tips02", @"cupcare-Set_up02"];
        _arrTblNameData = @[kString(@"个人信息"), kString(@"我的好友"), kString(@"我的圈子"), kString(@"闹钟"), kString(@"小贴士"), kString(@"设置")];
    }
}


@end
