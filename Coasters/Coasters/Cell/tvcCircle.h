//
//  tvcCircle.h
//  Coasters
//
//  Created by 丁付德 on 16/6/1.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcCircle : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) Group *group;

@property (nonatomic, copy) void (^editClick)();            // 点击修改按钮的事件

@end
