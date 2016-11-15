//
//  tvcFriend.h
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface tvcFriend : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (weak, nonatomic) IBOutlet UIImageView *imvRight;
@property (weak, nonatomic) IBOutlet UIView *viewHot;

@property (strong, nonatomic)  Friend *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
