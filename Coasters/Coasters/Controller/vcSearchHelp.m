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
//  Created by 丁付德 on 16/7/16.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcSearchHelp.h"

#pragma mark - 宏命令

@interface vcSearchHelp ()
{
    
}

@end

@implementation vcSearchHelp

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initData];
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
    NSLog(@"vcSearchHelp销毁了");
}


// 初始化数据
- (void)initData
{
    
}

// 初始化布局控件
- (void)initView
{
    NSLog(@"vcSearchHelp initView");
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
#pragma mark 1 target-action                    普通

#pragma mark 2 delegate dataSource protocol     代理协议

#pragma mark - ------------------------------------- 私有方法

#pragma mark - ------------------------------------- 属性实现

#pragma mark -





































@end
