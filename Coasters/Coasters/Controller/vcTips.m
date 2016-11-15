//
//  vcTips.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcTips.h"
#import "tvcTips.h"
#import "tvcTips1.h"
#import "Tips.h"
#import "vcTipsDetails.h"
#import "MJRefresh.h"

@interface vcTips ()<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger currentPage;          // 当前第几页
    NSInteger loadType;             // 加载的方式  1 加载最新  2  加载更多
    BOOL isHavMoreData;             // YES:  有更多的数据  NO: 没有了
    NSString *langCode;             // 当前的语言 01， 02
    BOOL isFirstLoad;
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (strong, nonatomic) UITableView *     tabView;
@property (strong, nonatomic) NSArray *         arrData;

@end

@implementation vcTips

- (void)viewDidLoad
{
    [super viewDidLoad];
    isFirstLoad = YES;
    NSLog(@"vcTips  viewDidLoad");
    [self initLeftButton:nil text:@"小贴士"];
    
    [self initView];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (isFirstLoad) {
        isFirstLoad = NO;
        [self.tabView.mj_header beginRefreshing];
    }
}

-(void)dealloc
{
    NSLog(@"vcTips  销毁了");
}


-(void)initData
{
    currentPage = 1;
    isHavMoreData = YES;
    langCode = [NSString stringWithFormat:@"%02d", [DFD getLanguage]];
    NSArray *arrTag = [Tips findByAttribute:@"tip_languageCode" withValue:langCode andOrderBy:@"datetime" ascending:NO inContext:DBefaultContext];
    
    if (arrTag.count > TipsListPangeCount)
        self.arrData = [arrTag subarrayWithRange:NSMakeRange(0, TipsListPangeCount)];
    else
        self.arrData = arrTag;
    [self refreshData];
}

-(void)refreshData
{
    NSRange range = { 0 , currentPage * TipsListPangeCount };
    NSArray *arrDataAll = [Tips findByAttribute:@"tip_languageCode" withValue:langCode andOrderBy:@"datetime" ascending:NO inContext:DBefaultContext];
    
    if (arrDataAll.count < range.length && isHavMoreData)
    {
        __block vcTips *blockSelf = self;
        NextWaitInMain(
                 RequestCheckNoWaring(
                   [net getTipsList:self.userInfo.access language_code:langCode page_num:currentPage];,
                   [blockSelf dataSuccessBack_getTipsList:dic];
           ););
        
    }
    else
    {
        if (range.length <= arrDataAll.count)
            self.arrData = [arrDataAll subarrayWithRange:range];
        else
        {
            self.arrData = arrDataAll;
            self.tabView.mj_footer = nil;
        }
    }
    
    [self refreshTable];
}

-(void)initView
{
    self.viewMainHeight.constant = ScreenHeight;
    self.view.backgroundColor = self.viewMain.backgroundColor = DLightGrayBlackGroundColor;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initTable];
    });
}

-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight)];
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.rowHeight = 180;
    self.tabView.showsVerticalScrollIndicator = YES;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcTips" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:self.tabView];

    __weak __typeof(self) weakSelf = self;
    self.tabView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
    
    self.tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
}

#pragma mark 刷新数据
-(void)loadNewData
{
    loadType = 1;
    currentPage = 1;
    [self refreshData];
}

#pragma mark 上拉加载更多数据   // 这里会不停的请求
- (void)loadMoreData
{
    loadType = 2;
    currentPage++;
    [self refreshData];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tips *model = self.arrData[indexPath.row];
    if (!model.pic_url || !model.pic_url.length)
    {
        tvcTips1 *cell = [tvcTips1 cellWithTableView:tableView];
        cell.model = model;
        return cell;
    }else
    {
        tvcTips *cell = [tvcTips cellWithTableView:tableView];
        cell.model = model;
        return cell;
    } 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Tips *model = self.arrData[indexPath.row];
    [self performSegueWithIdentifier:@"tips_to_details" sender:model];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"tips_to_details"])
    {
        vcTipsDetails *vc = (vcTipsDetails *)segue.destinationViewController;
        vc.model = sender;
    }
}

-(void)dataSuccessBack_getTipsList:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSArray *arr_sub = dic[@"tips_arr"];
        if(arr_sub.count > 0)
        {
            NSString *blockLangCode = langCode;
            [Tips objectsByArray:arr_sub
                         context:DBefaultContext
                    perfectBlock:^(id model) {
                            Tips *tip = model;
                            tip.tip_languageCode = blockLangCode;
                        }];
            
            isHavMoreData = arr_sub.count == TipsListPangeCount;
            [self refreshData];
        }
    }
}

-(void)refreshTable
{
    [self.tabView reloadData];
    if (loadType == 1) {
        [self.tabView.mj_header endRefreshing];
    }
    else if (loadType == 2) {
        [self.tabView.mj_footer endRefreshing];
    }
}





@end
