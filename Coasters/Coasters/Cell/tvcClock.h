//
//  tvcClock.h
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

@class tvcClock;
@protocol tvcClockDelegate <NSObject>

-(void)switchClock:(tvcClock *)sender;

@end

@interface tvcClock : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UILabel *lblClock;
@property (weak, nonatomic) IBOutlet UILabel *lblRepeat;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UISwitch *swt;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblRepeatTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTypeBottom;

@property (weak, nonatomic) IBOutlet UIImageView *imv1;
//@property (weak, nonatomic) IBOutlet UIImageView *imv2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblClockWidth;

@property (nonatomic, strong) Clock *model;

@property (nonatomic, assign) id<tvcClockDelegate> delegate_S;
- (IBAction)btnChangeClick:(UIButton *)sender;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
