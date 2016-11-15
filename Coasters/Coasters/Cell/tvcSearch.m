//
//  tvcSearch.m
//  Coasters
//
//  Created by 丁付德 on 15/8/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//
#import "tvcSearch.h"

@implementation tvcSearch

- (void)awakeFromNib {
    [super awakeFromNib];
}


//+ (instancetype)cellWithTableView:(UITableView *)tableView
//{
//    static NSString *ID = @"tvcSearch"; // 标识符
//    tvcSearch *cell = [tableView dequeueReusableCellWithIdentifier:ID];
//    
//    if (cell == nil) {
//        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcSearch" owner:nil options:nil] lastObject];
//    }
//    return cell;
//}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcSearch"; // 这里需要同时设置xib的identifier
    tvcSearch *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
