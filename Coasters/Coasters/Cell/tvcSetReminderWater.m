//
//  tvcSetReminderWater.m
//  Coasters
//
//  Created by 丁付德 on 15/10/22.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "tvcSetReminderWater.h"

@interface tvcSetReminderWater ()
@property (weak, nonatomic) IBOutlet UILabel *lblStartTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblEndTitle;

@end

@implementation tvcSetReminderWater

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _lblStartTitle.text = kString(@"开始时间");
    _lblEndTitle.text = kString(@"结束时间");
    
    self.imvNumber.layer.cornerRadius = 15;
    [self.imvNumber.layer setMasksToBounds:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcSetReminderWater"; // 标识符
    tvcSetReminderWater *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcSetReminderWater" owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
