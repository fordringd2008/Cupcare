//
//  tvcUser.m
//  Coasters
//
//  Created by 丁付德 on 15/8/26.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcUser.h"

@implementation tvcUser

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcUser"; // 标识符
    tvcUser *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcUser" owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
