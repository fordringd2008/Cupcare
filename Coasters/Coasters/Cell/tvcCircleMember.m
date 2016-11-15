//
//  tvcCircleMember.m
//  Coasters
//
//  Created by 丁付德 on 16/6/13.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcCircleMember.h"

@implementation tvcCircleMember

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcCircleMember"; // 这里需要同时设置xib的identifier
    tvcCircleMember *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcCircleMember" owner:nil options:nil] lastObject];
    }
    return cell;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
