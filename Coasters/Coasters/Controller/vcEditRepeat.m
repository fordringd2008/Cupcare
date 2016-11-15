//
//  vcEditRepeat.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcEditRepeat.h"

@interface vcEditRepeat () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *arrRepeat;
    NSString *      strRepeat;
}


@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (nonatomic, strong) NSArray *           arrData;

@end

@implementation vcEditRepeat

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLeftButton:nil text:@"重复"];
    
    [self initView];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
}

-(void)initView
{
    self.tabView.rowHeight = Bigger(RealHeight(88), 50);
    self.tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        view;
    });
}


-(void)initData
{
    self.arrData = @[ kString(@"每周日"), kString(@"每周一"),kString(@"每周二"),kString(@"每周三"),kString(@"每周四"),kString(@"每周五"),kString(@"每周六"),];
    arrRepeat = [[self.clock.repeat componentsSeparatedByString:@"-"] mutableCopy];
    [self.tabView reloadData];
}

-(void)refreshArrRepeat
{
    strRepeat = [arrRepeat componentsJoinedByString:@"-"];
}

-(void)back
{
    [self.delegate changeRepeat:arrRepeat];
    [super back];
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 7;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell"; // 标识符
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;  //选中cell时无色
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    if ([arrRepeat[indexPath.row] boolValue])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([arrRepeat[indexPath.row] boolValue])
    {
        arrRepeat[indexPath.row] = @"0";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        arrRepeat[indexPath.row] = @"1";
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [self refreshArrRepeat];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

@end
