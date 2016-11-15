//
//  tvcClock.m
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcClock.h"

@implementation tvcClock

- (void)awakeFromNib {
    [super awakeFromNib];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    self.lblRepeatTop.constant = self.lblTypeBottom.constant = (Bigger(RealHeight(100), 60) - 42 ) / 3;
    if (![DFD isSysTime24]) {
        self.lblClockWidth.constant = 80;
    }
}

-(void)setModel:(Clock *)model
{
    _model = model;
    //NSLog(@"%@", self.model.strTime);
    self.lblClock.text = self.model.strTime;
    if (![DFD isSysTime24]) {
        self.lblClock.text = [DFD toStringByHourAndMinute:self.model.hour minute:self.model.minute];
    }
    self.lblRepeat.text = self.model.strRepeat;
    self.swt.on = [self.model.isOn boolValue];
    self.lblType.text = self.model.strType;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnChangeClick:(UIButton *)sender
{
    self.swt.on = !self.swt.on;
    sender.userInteractionEnabled = NO;
     __weak UIButton *blockButton = sender;
    NextWaitInMainAfter(blockButton.userInteractionEnabled = YES;, 1);  // 阻止过于频繁发送指令
    [self.delegate_S switchClock:self];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcClock"; // 标识符
    tvcClock *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcClock" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
