//
//  tvcCircleMember.m
//  Coasters
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcAddCircleMember.h"

@interface tvcAddCircleMember()
{

}

@end

@implementation tvcAddCircleMember

-(void)layoutSubviews
{
    [super layoutSubviews];
}

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
    static NSString *ID = @"tvcAddCircleMember"; // 这里需要同时设置xib的identifier
    tvcAddCircleMember *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcAddCircleMember" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
