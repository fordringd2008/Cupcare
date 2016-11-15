//
//  WBPopMenuView.m
//  QQ_PopMenu_Demo
//
//  Created by Transuner on 16/3/17.
//  Copyright © 2016年 吴冰. All rights reserved.
//

#import "WBPopMenuView.h"
#import "WBTableViewDataSource.h"
#import "WBTableViewDelegate.h"
#import "WBTableViewCell.h"
#import "WBPopMenuModel.h"
#import "WBPopMenuSingleton.h"

#define WBNUMBER 2

@interface WBPopMenuView ()
{
    CGFloat gRight;
}
@property (nonatomic, strong) WBTableViewDataSource * tableViewDataSource;
@property (nonatomic, strong) WBTableViewDelegate   * tableViewDelegate;
@end

@implementation WBPopMenuView

- (instancetype) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame
                     menuWidth:(CGFloat)menuWidth
                         right:(CGFloat)right
                         items:(NSArray *)items
                        action:(void(^)(NSInteger index))action {
    if (self = [super initWithFrame:frame]) {
        gRight = right;
        self.menuWidth = menuWidth;
        self.menuItem = items;
        self.action = [action copy];

        self.tableViewDataSource = [[WBTableViewDataSource alloc]initWithItems:items cellClass:[WBTableViewCell class] configureCellBlock:^(WBTableViewCell *cell, WBPopMenuModel *model) {
            WBTableViewCell * tableViewCell = (WBTableViewCell *)cell;
            tableViewCell.textLabel.text = model.title;
            tableViewCell.imageView.image = [UIImage imageNamed:model.image];
            [tableViewCell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }];
        self.tableViewDelegate = [[WBTableViewDelegate alloc] initWithDidSelectRowAtIndexPath:^(NSInteger indexRow) {
            if (self.action) {
                self.action(indexRow);
            }
        }];


        self.tableView = [[UITableView alloc]initWithFrame:[self menuFrame] style:UITableViewStylePlain];
        self.tableView.dataSource = self.tableViewDataSource;
        self.tableView.delegate   = self.tableViewDelegate;
        self.tableView.layer.cornerRadius = 10.0f;
        self.tableView.layer.anchorPoint = CGPointMake(1.0, 0);
        self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        self.tableView.scrollEnabled = NO;  //111
        self.tableView.rowHeight = 40;
        [self addSubview:self.tableView];
        
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        
    }
    return self;
}

- (CGRect)menuFrame {
    CGFloat menuX = [UIScreen mainScreen].bounds.size.width - 100;
    CGFloat menuY = 180 - 20 * WBNUMBER;
    CGFloat width = self.menuWidth;
    CGFloat heigh = 40 * WBNUMBER;
    menuY = 35;
    return (CGRect){menuX,menuY,width,heigh};
}

#pragma mark 绘制三角形
- (void)drawRect:(CGRect)rect

{
    // 设置背景色
    [[UIColor whiteColor] set];
    //拿到当前视图准备好的画板
    
    CGContextRef  context = UIGraphicsGetCurrentContext();
    
    //利用path进行绘制三角形
    
    //gRight
    
    CGContextBeginPath(context);//标记
    CGFloat location = [UIScreen mainScreen].bounds.size.width - gRight; // 55 44
    CGContextMoveToPoint(context,
                         location -  10 - 10, 76);//设置起点       180
    
    CGContextAddLineToPoint(context,
                            location - 2*10 - 10 ,  66);           //170
    
    CGContextAddLineToPoint(context,
                            location - 10 * 3 - 10, 76);           // 180
    
    CGContextClosePath(context);//路径结束标志，不写默认封闭
    
    [[UIColor whiteColor] setFill];  //设置填充色
    
    [[UIColor whiteColor] setStroke]; //设置边框颜色
    
    CGContextDrawPath(context,
                      kCGPathFillStroke);//绘制路径path
    
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[WBPopMenuSingleton shareManager]hideMenu];
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com