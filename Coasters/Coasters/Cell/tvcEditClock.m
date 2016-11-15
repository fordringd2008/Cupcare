//
//  tvcEditClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcEditClock.h"

@implementation tvcEditClock

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    _lblTitleTop.constant = _lblValueBottom.constant = Bigger(RealHeight(120), 70) * (10 / 60.0);
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcEditClock"; // 标识符
    tvcEditClock *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcEditClock" owner:nil options:nil] lastObject];
    }
    
    return cell;
}
@end
