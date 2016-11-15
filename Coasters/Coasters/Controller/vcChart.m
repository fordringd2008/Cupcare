//
//  vcChart.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcChart.h"
#import "vcFirst.h"
#import "vcSecond.h"
#import "vcShare.h"

@interface vcChart ()<UIScrollViewDelegate,vcFirstDelegate>
{
    UIScrollView  *scrollview;
    NSArray *scrollPages;
    UIPageControl *pageControl;
    vcFirst *vcfirst;
    vcSecond *vcsecond;
    BOOL isLeft;                            //  是否离开
}

@end

@implementation vcChart

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@" vcChart 创建了");
    [self initLeftButton:nil text:(kString(_model ? @"好友的喝水记录" : @"喝水记录"))];
    if (!_model) {
        [self initRightButton:@"share" text:nil];
    }
    
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];

    self.view.backgroundColor = DWhite;
    
    self.userInfo = myUserInfo;
        
    [self upDataViewArray];
    [self setUpShowView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isLeft = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)rightButtonClick
{
    if (!isLeft)
    {
        isLeft = YES;
        [self performSegueWithIdentifier:@"chart_to_share" sender:nil];
    }
}

-(void)dealloc
{
    NSLog(@" vcChart 销毁了");
}

- (void)viewWillDisappear:(BOOL)animated
{
    isLeft = YES;
    [super viewWillDisappear:animated];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)upDataViewArray
{
    if (self.model)
    {
        vcfirst = [[vcFirst alloc]initWithNibName:@"vcFirst" bundle:nil];
        vcfirst.model = self.model;
        vcfirst.acc = self.userInfo.access;
        vcfirst.delegate = self;
        vcfirst.view.frame = CGRectMake(ScreenWidth * 0, 0, ScreenWidth, ScreenHeight);
        scrollPages = @[vcfirst.view];
    }
    else
    {
        vcfirst = [[vcFirst alloc] initWithNibName:@"vcFirst" bundle:nil];
        vcfirst.model = self.model;
        vcfirst.acc = self.userInfo.access;
        vcfirst.delegate = self;
        vcfirst.view.frame = CGRectMake(ScreenWidth * 0, 0, ScreenWidth, ScreenHeight);
        vcsecond = [[vcSecond alloc]initWithNibName:@"vcSecond" bundle:nil];
        vcsecond.acc = self.userInfo.access;
        vcsecond.view.frame = CGRectMake(ScreenWidth * 1, 0, ScreenWidth, ScreenHeight);
        scrollPages = @[vcfirst.view,vcsecond.view];
    }
}

//加载滑动视图
-(void)setUpShowView
{
    //if(scrollview == nil)
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth, ScreenHeight)];
    scrollview.showsVerticalScrollIndicator = NO;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.pagingEnabled = YES;
    scrollview.contentSize = CGSizeMake(scrollview.frame.size.width * 2, 0); //可以滚动的大小
    scrollview.scrollsToTop = NO;
    scrollview.delegate = self;
    scrollview.bounces= NO;
    scrollview.directionalLockEnabled = YES;
    scrollview.backgroundColor = DLightGrayBlackGroundColor;
    
    for (int i = 0; i < scrollPages.count; i++) {
        [scrollview addSubview:[scrollPages objectAtIndex:i]];
    }
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(ScreenWidth / 4  , ScreenHeight -  NavBarHeight - 30 , ScreenWidth / 2, 24)];
    pageControl.currentPage = scrollPages.count;
    pageControl.hidesForSinglePage = NO;
    pageControl.userInteractionEnabled = NO;
    pageControl.numberOfPages = scrollPages.count;
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = DidConnectColor;
    
    [self.view insertSubview:scrollview atIndex:0];
    [self.view addSubview:pageControl];
    
    CGPoint offset = CGPointMake(scrollview.frame.size.width * self.myCurrentPage, 0);
    [scrollview setContentOffset:offset animated:YES];
    pageControl.currentPage = self.myCurrentPage;
    
    if (_model)
    {
        scrollview.scrollEnabled = NO;
        [pageControl setHidden:YES];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    _myCurrentPage = pageControl.currentPage = index;
    [self initLeftButton:nil text:(_model ? @"好友的喝水记录" : (!_myCurrentPage ? @"喝水记录" : @"喝水习惯"))];
    if (_myCurrentPage) [vcfirst pickerViewDisappear];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chart_to_share"])
    {
        vcShare *sh = (vcShare *)segue.destinationViewController;
        NSMutableArray *arrShare =  [NSMutableArray new];
        NSString *str1;
        NSString *str2 = kString(@"喝水记录");
        switch (_myCurrentPage) {
            case 0:
            {
                switch (vcfirst.indexSub) {
                    case 1:
                        str1 = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)vcfirst.yearSub1, (long)vcfirst.monthSub1, (long)vcfirst.daySub1, str2];
                        break;
                    case 2:
                        str1 = [NSString stringWithFormat:@"%ld-%ld %@",(long)vcfirst.yearSub2, (long)vcfirst.monthSub2, str2];
                        break;
                    case 3:
                        str1 = [NSString stringWithFormat:@"%ld %@",(long)vcfirst.yearSub3, str2];
                        break;
                        
                    default:
                        break;
                }
                [arrShare addObject:str1];
                [arrShare addObject:vcfirst.lblScore.text];
                [arrShare addObject:@(vcfirst.percent)];
                [arrShare addObject:vcfirst.lbl1.text];
                [arrShare addObject:vcfirst.lbl2.text];
                [arrShare addObject:vcfirst.lbl3.text];
                [arrShare addObject:vcfirst.lbl4.text];
                [arrShare addObject:vcfirst.lbl5.text];
                [arrShare addObject:vcfirst.lbl6.text];
                sh.arrShareData = arrShare;
            }
                break;
            case 1:
            {
                str1 = [NSString stringWithFormat:@"%ld-%ld %@",(long)vcsecond.year, (long)vcsecond.month, str2];
                [arrShare addObject:str1];
                [arrShare addObject:vcsecond.lblScore.text];
                [arrShare addObject:@(vcsecond.percent)];
                [arrShare addObject:vcsecond.lbl1.text];
                [arrShare addObject:vcsecond.lbl2.text];
                [arrShare addObject:vcsecond.lbl3.text];
                [arrShare addObject:vcsecond.lbl4.text];
                [arrShare addObject:vcsecond.lbl5.text];
                [arrShare addObject:vcsecond.lbl6.text];
                sh.arrShareData = arrShare;
            }
                break;
                
            default:
                break;
        }
        
    }
}

#pragma mark vcFirstDelegate
-(void)pageControlHidden:(BOOL)isHidden
{
    pageControl.hidden = isHidden;
}

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
