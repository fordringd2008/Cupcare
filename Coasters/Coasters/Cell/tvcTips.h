//
//  tvcTips.h
//  Coasters
//
//  Created by 丁付德 on 15/9/5.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VerticalAlignmentLabel.h"

@class Tips;

@interface tvcTips : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet VerticalAlignmentLabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *btnImv;

@property (assign, nonatomic) CGFloat width;


@property (strong, nonatomic) Tips *model;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
