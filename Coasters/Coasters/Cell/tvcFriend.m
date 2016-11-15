//
//  tvcFriend.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcFriend.h"

@implementation tvcFriend

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.viewHot.layer.cornerRadius = 5;
    self.imv.layer.cornerRadius = ( self.bounds.size.height - 16 ) / 2;
    self.imv.layer.borderWidth = 1;
    self.imv.layer.borderColor = DLightGrayBlackGroundColor.CGColor;
    [self.imv.layer setMasksToBounds:YES];
}

-(void)setModel:(Friend *)model
{
    [self.imv sd_setImageWithURL:[NSURL URLWithString:model.user_pic_url] placeholderImage: DefaultLogo_Gender([model.user_gender boolValue])];
    self.lbl.text = model.user_nick_name;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFriend"; // 标识符
    tvcFriend *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFriend" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
