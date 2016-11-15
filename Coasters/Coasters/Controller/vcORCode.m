//
//  vcORCode.m
//  Coasters
//
//  Created by 丁付德 on 15/8/12.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcORCode.h"
#import "QRCodeGenerator.h"
#import "vcShare.h"
#import "vcBase+Share.h"

@interface vcORCode ()
{
    BOOL isShowed;
    UIView *viewContent;
    CGRect viewShareHiddenFrame;
    CGRect viewShareShowFrame;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblSecond;
@property (weak, nonatomic) IBOutlet UIView *viewShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvLogoLeft;

@end

@implementation vcORCode

- (void)viewDidLoad
{
    [super viewDidLoad];
    switch (_orcodeType) {
        case UserORCode:
            [self initLeftButton:nil text:@"我的二维码"];
            break;
        case CircleORCode:
            [self initLeftButton:nil text:@"圈子二维码"];
            break;
    }
    
    [self initRightButton:@"share" text:nil];
    
    self.viewMainHeight.constant =  ScreenHeight - NavBarHeight;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initView];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
}

-(void)initView
{
    _imvLogo.layer.borderColor = DLightGray.CGColor;
    _imvLogo.layer.borderWidth = 1;
    _imvLogo.layer.cornerRadius = 40;
    [_imvLogo.layer setMasksToBounds:YES];
    
    
    _imvLogoLeft.constant = 20;
    int widthTag = RealWidth(440);
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - widthTag) / 2, 120, widthTag, widthTag)];
    
    UILabel *lblOther = [[UILabel alloc] initWithFrame:CGRectMake(0, IPhone4 ? 360 : 430, ScreenWidth, 42)];
    lblOther.font = [UIFont systemFontOfSize:14];
    lblOther.numberOfLines = 0;
    lblOther.textAlignment = NSTextAlignmentCenter;
    lblOther.textColor = DLightGray;
    
    
    switch (_orcodeType) {
        case UserORCode:
        {
            [_imvLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.logo] placeholderImage: DefaultLogo_Gender([self.userInfo.user_gender boolValue])];
            _lblFirst.text  = self.userInfo.user_nick_name;
            _lblSecond.text = [self.userInfo.loginType intValue] > 1 ? @"" : self.userInfo.account;
            
            if (self.userInfo.orData)
                imv.image = [UIImage imageWithData:self.userInfo.orData];
            else
            {
                // www.sz-hema.com/download###{"email":"123@qq.com"}
                // http://www.sz-hema.com/download###{"email":"123@qq.com","phone":"13512349999","third_party_id":"123456789"}
                NSString *accountType = @"third_party_id";
                switch ([self.userInfo.loginType intValue]) {
                    case 0:
                        accountType = @"email";
                        break;
                    case 1:
                        accountType = @"phone";
                        break;
                }
                
                NSString *urlString = [NSString stringWithFormat:@"%@###{\"%@\":\"%@\"}", orReaderPrefix, accountType, self.userInfo.account];
                NSLog(@"二维码地址：%@", urlString);
                imv.image = [QRCodeGenerator qrImageForString:urlString imageSize:imv.bounds.size.width];
                self.userInfo = myUserInfo;
                self.userInfo.orData = UIImagePNGRepresentation(imv.image);
                DBSave;
            }
            
            lblOther.text = kString(@"扫一扫上面的二维码,加我好友");

        }
            break;
        case CircleORCode:
        {
            [_imvLogo sd_setImageWithURL:[NSURL URLWithString:_group.group_pic_url] placeholderImage:DefaultCircleLogoImage];
            
            _lblFirst.text  = _group.group_name;
            _lblSecond.text = [NSString stringWithFormat:@"%@:%@", kString(@"圈号"), _group.group_id];
            // 圈子二维码扫描内容定义：
            // http://www.sz-hema.com/download###{"group_id":"123"}
            
            NSString *urlString = [NSString stringWithFormat:@"%@###{\"group_id\":\"%@\"}", orReaderPrefix, _group.group_id];
            NSLog(@"二维码地址：%@", urlString);
            imv.image = [QRCodeGenerator qrImageForString:urlString imageSize:imv.bounds.size.width];
            
            
            lblOther.text = kString(@"扫描二维码查看圈子主页");
        }
            break;
    }
    
    
    [_viewMain addSubview:imv];
    [_viewMain insertSubview:lblOther atIndex:0];
    
    [self initShareButton];
}

-(void)rightButtonClick
{
    [self showShareView:YES];
}

-(void)initShareButton
{
    NSInteger isAddCount = 0;                       // 已添加的个数
    BOOL isHaveWeiXin = [self isHave:1];
    BOOL isHaveXinLang = [self isHave:2];
    BOOL isHaveQQ = [self isHave:3];
    BOOL isHaveFacebook = [self isHave:4];
    
    if (isDevelemont) {
        if (!isHaveWeiXin && !isHaveXinLang && !isHaveQQ && !isHaveFacebook) {
            isHaveWeiXin = isHaveXinLang = isHaveQQ = isHaveFacebook = YES;
        }
    }
    
    int numberInViewContent = 0;
    numberInViewContent += (isHaveWeiXin ? 2:0);
    numberInViewContent += (isHaveXinLang ? 1:0);
    numberInViewContent += (isHaveQQ ? 2:0);
    numberInViewContent += (isHaveFacebook ? 2:0);
    
    
    CGFloat oneWidth = (ScreenWidth - 20) / 7.0;
    _viewShareHeight.constant = oneWidth * 1.1;
    
    viewShareHiddenFrame =  CGRectMake(0, ScreenHeight+20, ScreenWidth, _viewShareHeight.constant);
    viewShareShowFrame =  CGRectMake(0, ScreenHeight - _viewShareHeight.constant-NavBarHeight, ScreenWidth, _viewShareHeight.constant);
    _viewShareBottom.constant = 0-_viewShareHeight.constant*1.5;
    
    viewContent = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - numberInViewContent * oneWidth) / 2, (_viewShareHeight.constant - oneWidth) / 2, numberInViewContent * oneWidth, oneWidth)];
    [_viewShare addSubview:viewContent];
    
    if (isHaveWeiXin)
    {
        [self addButtonAddImage:isAddCount++ type:1];
        [self addButtonAddImage:isAddCount++ type:2];
    }
    if (isHaveXinLang)
        [self addButtonAddImage:isAddCount++ type:3];
    if (isHaveQQ)
    {
        [self addButtonAddImage:isAddCount++ type:5];
        [self addButtonAddImage:isAddCount++ type:4];
    }
    if (isHaveFacebook)
    {
        [self addButtonAddImage:isAddCount++ type:6];
        [self addButtonAddImage:isAddCount++ type:7];
    }
}


// 添加  index： 前面有几个   type：1： 微信好友  2： 微信朋友圈 3：新浪微博 4：QQ空间 5：qq好友  6：facebook 7: twitter
-(void)addButtonAddImage:(NSInteger)index type:(NSInteger)type
{
    CGFloat oneWidth = (ScreenWidth - 20) / 7.0;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index * oneWidth, 0, oneWidth, oneWidth)];
    btn.tag = type;
    btn.backgroundColor = DClear;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *imgNormal = [UIImage new];
    UIImage *imgHighlight = [UIImage new];
    
    switch (type) {
        case 1:
            imgNormal = [UIImage imageNamed:@"share_weixin"];
            imgHighlight = [UIImage imageNamed:@"share_weixin_highlight"];
            break;
        case 2:
            imgNormal = [UIImage imageNamed:@"share_pengyouquan"];
            imgHighlight = [UIImage imageNamed:@"share_pengyouquan_highlight"];
            break;
        case 3:
            imgNormal = [UIImage imageNamed:@"share_weibot"];
            imgHighlight = [UIImage imageNamed:@"share_weibot_highlight"];
            break;
        case 4:
            imgNormal = [UIImage imageNamed:@"share_qq_zone"];
            imgHighlight = [UIImage imageNamed:@"share_qq_zone_highlight"];
            break;
        case 5:
            imgNormal = [UIImage imageNamed:@"share_qq"];
            imgHighlight = [UIImage imageNamed:@"share_qq_highlight"];
            break;
        case 6:
            imgNormal= [UIImage imageNamed:@"share_facebook"];
            imgHighlight = [UIImage imageNamed:@"share_facebook_highlight"];
            break;
        case 7:
            imgNormal = [UIImage imageNamed:@"share_twitter"];
            imgHighlight = [UIImage imageNamed:@"share_twitter_highlight"];
            break;
            
        default:
            break;
    }
    
    // top, left, bottom, right
    [btn setImageEdgeInsets: UIEdgeInsetsMake(oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2)];
    
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgHighlight forState:UIControlStateHighlighted];
    
    [viewContent addSubview:btn];
}

- (void)btnClick:(UIButton *)sender
{
    [self showShareView:YES];
    [self share:sender.tag url:nil title:nil];
}

-(void)showShareView:(BOOL)isShow
{
    if(isShowed) isShow = NO;
    if(isShow)
    {
        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewShare setFrame:viewShareShowFrame];
         } completion:^(BOOL finished) {
             isShowed = YES;
         }];
    }
    else
    {
        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewShare setFrame:viewShareHiddenFrame];
         } completion:^(BOOL finished) {
             isShowed = NO;
         }];
    }
}


//-(void)initShareButton
//{
//    NSInteger isAddCount = 0;                       // 已添加的个数
//    BOOL isHaveWeiXin = [self isHave:1];
//    BOOL isHaveXinLang = [self isHave:2];
//    BOOL isHaveQQ = [self isHave:3];
//    BOOL isHaveFacebook = [self isHave:4];
//    //BOOL isHaveTwitter = [self isHave:5];
//    //NSLog(@"是否安装了 微信：%hhd,  新浪：%hhd,  QQ：%hhd,  facebook : %hhd, twitter: %hhd", isHaveWeiXin, isHaveXinLang, isHaveQQ, isHaveFacebook, isHaveTwitter);
//    if (isDevelemont) {
//        if (!isHaveWeiXin && !isHaveXinLang && !isHaveQQ && !isHaveFacebook) {
//            isHaveWeiXin = isHaveXinLang = isHaveQQ = isHaveFacebook = YES;
//        }
//    }
//    
//    scvShare = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
//    scvShare.bounces = NO;
//    scvShare.showsHorizontalScrollIndicator = NO;
//    [self.viewShare addSubview:scvShare];
//    
//    if (isHaveFacebook)
//    {
//        [self addButtonAddImage:isAddCount++ type:6];
//        [self addButtonAddImage:isAddCount++ type:7];
//    }
//    if (isHaveWeiXin)
//    {
//        [self addButtonAddImage:isAddCount++ type:1];
//        [self addButtonAddImage:isAddCount++ type:2];
//    }
//    if (isHaveXinLang)
//        [self addButtonAddImage:isAddCount++ type:3];
//    if (isHaveQQ)
//    {
//        [self addButtonAddImage:isAddCount++ type:5];
//        [self addButtonAddImage:isAddCount++ type:4];
//    }
//    scvShare.contentSize = CGSizeMake(isAddCount * ScreenWidth / 5.0, 45);
//}
//
//// 添加  index： 前面有几个   type：1： 微信好友  2： 微信朋友圈 3：新浪微博 4：QQ空间 5：qq好友  6：facebook 7: twitter
//-(void)addButtonAddImage:(NSInteger)index type:(NSInteger)type
//{
//    CGFloat width = ScreenWidth / 5.0;
//    CGFloat btnheight = 45;
//    CGFloat imvheight = 35;
//    
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index * width, 0, width, btnheight)];
//    btn.tag = type;
//    btn.backgroundColor = DClear;
//    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imvheight, imvheight)];
//    switch (type) {
//        case 1:
//            imv.image = [UIImage imageNamed:@"share_weixin"];
//            break;
//        case 2:
//            imv.image = [UIImage imageNamed:@"share_pengyouquan"];
//            break;
//        case 3:
//            imv.image = [UIImage imageNamed:@"share_weibot"];
//            break;
//        case 4:
//            imv.image = [UIImage imageNamed:@"share_qq_zone"];
//            break;
//        case 5:
//            imv.image = [UIImage imageNamed:@"share_qq"];
//            break;
//        case 6:
//            imv.image = [UIImage imageNamed:@"share_facebook"];
//            break;
//        case 7:
//            imv.image = [UIImage imageNamed:@"share_twitter"];
//            break;
//            
//        default:
//            break;
//    }
//    
//    imv.center = btn.center;
//    [scvShare addSubview:imv];
//    [scvShare addSubview:btn];
//}
//
//- (void)btnClick:(UIButton *)sender
//{
//    [self showShareView:YES];
//    [self share:sender.tag url:nil title:nil];
//}
//
//-(void)showShareView:(BOOL)isShow
//{
//    if(isShowed) isShow = NO;
//    if(isShow)
//    {
//        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
//         {
//             [self.viewShare setFrame:viewShareShowFrame];
//         } completion:^(BOOL finished) {
//             isShowed = YES;
//         }];
//    }
//    else
//    {
//        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
//         {
//             [self.viewShare setFrame:viewShareHiddenFrame];
//         } completion:^(BOOL finished) {
//             isShowed = NO;
//         }];
//    }
//}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
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
