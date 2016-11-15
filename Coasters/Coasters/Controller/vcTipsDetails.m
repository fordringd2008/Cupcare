//
//  vcTipsDetails.m
//  Coasters
//
//  Created by 丁付德 on 15/9/10.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcTipsDetails.h"
#import "vcBase+Share.h"

#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface vcTipsDetails ()<UIScrollViewDelegate, UIWebViewDelegate, NJKWebViewProgressDelegate>
{
    UITapGestureRecognizer *recognizer;
    
    BOOL isShowed;
    UIView *viewContent;
    CGRect viewShareHiddenFrame;
    CGRect viewShareShowFrame;
    
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}

@property (strong, nonatomic) UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *viewShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareBottom;


@property (weak, nonatomic) IBOutlet UILabel *lblbLoading;

@end

@implementation vcTipsDetails

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"小贴士"];
    [self initRightButton:@"share" text:nil];
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    if (self.appDelegate.tips) {
        self.model = self.appDelegate.tips;
    }
    
    self.lblbLoading.text = kString(@"正在加载 ...");
    
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSLog(@"url : %@", self.model.tip_url);
        self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight)];
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.scalesPageToFit = NO;
        self.webView.delegate = self;
        
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _webView.delegate = _progressProxy;
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
        
        CGFloat progressBarHeight = 2.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.backgroundColor = DWhite;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        if ([GetUserDefault(TipsIn) boolValue])
        {
            self.appDelegate.tips = nil;
            SetUserDefault(TipsIn, @(NO));
        }
        
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:self.model.tip_url]];
        [self.webView loadRequest:request];
        [self loadNext];

    });
}

-(void)rightButtonClick
{
    [self showShareView:YES];
}

-(void)loadNext
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    scrollView.backgroundColor = DLightGrayBlackGroundColor;
    [scrollView addSubview:self.webView];
    
    scrollView.scrollEnabled = NO;
    [self.view insertSubview:scrollView belowSubview:self.viewShare];
    
    
    [self initShareButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_progressView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_progressView removeFromSuperview];
    [self.view removeGestureRecognizer:recognizer];
    [super viewWillDisappear:animated];
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
//    [self share:sender.tag url:nil title:nil];
    [self share:sender.tag url:self.model.tip_url title:self.model.tip_title];
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

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    //NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>  progress : %f", progress);
    [_progressView setProgress:progress animated:YES];
    if (progress == 1)
        [_progressView setHidden:YES];
    else
        [_progressView setHidden:NO];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


@end
