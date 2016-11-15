//
//  vcShare.m
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcShare.h"
#import "vcBase+Share.h"

@interface vcShare ()
{
//    UIScrollView *scvShare;         // 底部的滚动分享
    UIView *viewChange;             // 替换的视图
    UITapGestureRecognizer *tap;
    UIVisualEffectView *effectView;
    UIVisualEffectView *effectViewHead;
    
    BOOL isShowed;
    UIView *viewContent;
    CGRect viewShareHiddenFrame;
    CGRect viewShareShowFrame;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (weak, nonatomic) IBOutlet UIView *viewShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareBottom;


@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UIView *viewStar;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTitleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblScoreTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Top;

//- (IBAction)btnClick:(UIButton *)sender;

@end

@implementation vcShare

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self initNavButton];
    
    [self initLeftButton:nil text:@"分享"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    _viewMain.backgroundColor = DidConnectColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initData];
        [self initView];
    });
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imvTap)];
    [self.imvLogo addGestureRecognizer:tap];
    self.imvLogo.userInteractionEnabled = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.imvLogo removeGestureRecognizer:tap];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [effectViewHead removeFromSuperview];
    NSLog(@"vcShare 销毁了");
}

-(void)imvTap
{
    [self.imvLogo removeGestureRecognizer:tap];
    CGFloat width = 200 / 720.0 * ScreenWidth;
    
    [UIView transitionWithView:self.imvLogo duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         if (self.imvLogo.tag) {
             self.imvLogo.frame = CGRectMake((ScreenWidth - width ) / 2, 25, width, width);
             self.imvLogo.layer.cornerRadius = self.imvLogo.frame.size.height / 2;
             [_imvLogo.layer setMasksToBounds:YES];
             if (effectView) {
                 effectView.alpha = 0;
                 effectViewHead.alpha = 0;
             }
         }else{
             self.imvLogo.frame = CGRectMake(10, 10, ScreenWidth - 20, ScreenWidth - 20);
             self.imvLogo.layer.cornerRadius = 20;
             [_imvLogo.layer setMasksToBounds:YES];
             if (effectView) {
                 effectView.alpha = 0.8;
                 effectViewHead.alpha = 0.8;
             }
         }
         
     } completion:^(BOOL finished) {
         [self.imvLogo addGestureRecognizer:tap];
         self.imvLogo.tag = self.imvLogo.tag ? 0:1;
     }];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initData
{
    
}

-(void)initView
{
    _lblTitleTop.constant = IPhone4 ?  RealHeight(35): RealHeight(65);
    _lblScoreTop.constant = IPhone4 ?  20 :RealHeight(100);
    _lbl2Top.constant = IPhone4 ?  RealHeight(40):RealHeight(70);
    [_imvLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.logo] placeholderImage: DefaultLogo_Gender([self.userInfo.user_gender boolValue])];
    _imvLogo.layer.cornerRadius = ScreenWidth * (20 / 72.0) / 2;
    [_imvLogo.layer setMasksToBounds:YES];
    
    _lblName.text = self.userInfo.user_nick_name;
    _lblTitle.text = _arrShareData[0]; //self.arrPush[0];
    _lblScore.text = _arrShareData[1];
    _lbl1.text = _arrShareData[3];
    _lbl2.text = _arrShareData[4];
    _lbl3.text = _arrShareData[5];
    _lbl4.text = _arrShareData[6];
    _lbl5.text = _arrShareData[7];
    _lbl6.text = _arrShareData[8];
    [self updateStar];
    
    [self initShareButton];
    
    if(SystemVersion >= 8)
    {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectView.alpha = 0;
        [self.viewMain insertSubview:effectView belowSubview:self.imvLogo];
        
        effectViewHead = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
        effectViewHead.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectViewHead.alpha = 0;
        [self.view.window addSubview:effectViewHead];
    }
}

-(void)updateStar
{
    NSInteger percent = [_arrShareData[2] integerValue];
    
    NSInteger count = 0;
    if (percent == 0)
        count = 0;
    else if (percent < 60)
        count = 1;
    if (percent >= 60 && percent < 70)
        count = 2;
    else if (percent >= 70 && percent < 80)
        count = 3;
    else if (percent >= 80 && percent < 90)
        count = 4;
    else if (percent >= 90)
        count = 5;
    
    for (int i = 0 ; i < 5; i++)
    {
        UIImageView *imgLight = _viewStar.subviews[i];
        if (count > i)
            imgLight.image = [UIImage imageNamed:@"stars"];
    }
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
    //_viewShareBottom.constant = 0-_viewShareHeight.constant*1.5;
    
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
    
    viewChange = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    //viewChange.backgroundColor = DRed;
    UIImageView *imvChangeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, 10, 25, 25)];
    imvChangeLogo.image = [UIImage imageNamed:@"logo"];
    [viewChange addSubview:imvChangeLogo];

    [_viewShare addSubview:viewChange];
    UILabel *lblChange = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 20, 12, 100, 21)];
    lblChange.text = [DFD getIOSName];
    lblChange.textColor = DWhite;
    [viewChange addSubview:lblChange];
    [viewChange setHidden:YES];
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

    [btn setImageEdgeInsets: UIEdgeInsetsMake(oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2)];
    
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgHighlight forState:UIControlStateHighlighted];
    
    [viewContent addSubview:btn];
}

- (void)btnClick:(UIButton *)sender
{
    [self change:YES];
    [self share:sender.tag url:nil title:nil];
    [self change:NO];
}

-(void)change:(BOOL)isChage
{
    [viewContent setHidden:isChage];
    [viewChange setHidden:!isChage];
}

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


//-(void)initShareButton
//{
//    NSInteger isAddCount = 0;                       // 已添加的个数
//    BOOL isHaveWeiXin = [self isHave:1];
//    BOOL isHaveXinLang = [self isHave:2];
//    BOOL isHaveQQ = [self isHave:3];
//    BOOL isHaveFacebook = [self isHave:4];
////    BOOL isHaveTwitter = [self isHave:5];
////    NSLog(@"是否安装了 微信：%hhd,  新浪：%hhd,  QQ：%hhd,  facebook : %hhd, twitter: %hhd", isHaveWeiXin, isHaveXinLang, isHaveQQ, isHaveFacebook, isHaveTwitter);
//    if (!isHaveWeiXin && !isHaveXinLang && !isHaveQQ && !isHaveFacebook) {
//        isHaveWeiXin = isHaveXinLang = isHaveQQ = isHaveFacebook = YES;
//    }
//    
//    scvShare = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
//    scvShare.bounces = NO;
//    scvShare.showsHorizontalScrollIndicator = NO;
//    [_viewBottom addSubview:scvShare];
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
//    
//    viewChange = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
//    //viewChange.backgroundColor = DRed;
//    UIImageView *imvChangeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, 10, 25, 25)];
//    imvChangeLogo.image = [UIImage imageNamed:@"logo"];
//    [viewChange addSubview:imvChangeLogo];
//    
//    [_viewBottom addSubview:viewChange];
//    
//    UILabel *lblChange = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 20, 12, 100, 21)];
//    lblChange.text = [DFD getIOSName];
//    lblChange.textColor = DWhite;
//    [viewChange addSubview:lblChange];
//    
//    [viewChange setHidden:YES];
//}
//
//-(void)change:(BOOL)isChage
//{
//    [viewContent setHidden:isChage];
//    [viewChange setHidden:!isChage];
//}
//
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

//- (void)btnClick:(UIButton *)sender
//{
//    [self change:YES];
//    [self share:sender.tag url:nil title:nil];
//    [self change:NO];
//}





@end
