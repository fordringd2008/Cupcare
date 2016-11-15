//
//  tvcCircleRank.m
//  Coasters
//
//  Created by 丁付德 on 16/6/6.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcCircleRank.h"

@interface tvcCircleRank()
{
    
}

@end

@implementation tvcCircleRank

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcCircleRank"; // 这里需要同时设置xib的identifier
    tvcCircleRank *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcCircleRank" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
