//
//  tvcTips1.m
//  Coasters
//
//  Created by 丁付德 on 16/5/30.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcTips1.h"
#import "Tips.h"

@implementation tvcTips1

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [_lblContent setVerticalAlignment:VerticalAlignmentTop];
    
    self.contentView.backgroundColor = DLightGrayBlackGroundColor;
    _viewMain.layer.borderColor = DLightGray.CGColor;
    _viewMain.layer.borderWidth = 1;
    _viewMain.layer.cornerRadius = 5;
    _viewMain.layer.masksToBounds = YES;
}


-(void)setModel:(Tips *)model
{
    _model = model;
    _lblTitle.text = model.tip_title;
    _lblTime.text = [model.datetime toString:@"YYYY-MM-dd"];
    _lblContent.text = model.tip_content;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcTips1"; // 标识符
    tvcTips1 *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcTips1" owner:nil options:nil] lastObject];
    }
    return cell;
}


@end
