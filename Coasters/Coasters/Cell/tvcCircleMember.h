//
//  tvcCircleMember.h
//  Coasters
//
//  Created by 丁付德 on 16/6/13.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface tvcCircleMember : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lbl;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
