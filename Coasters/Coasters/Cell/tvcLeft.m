//
//  tvcLeft.m
//  aerocom
//
//  Created by 丁付德 on 15/6/29.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcLeft.h"

@implementation tvcLeft

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.viewRedDot.layer.cornerRadius = 5;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView index:(NSInteger)index
{
    static NSString *ID = @"tvcLeft"; // 标识符
    tvcLeft *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcLeft" owner:nil options:nil] lastObject];
    }
    return cell;
}


@end
