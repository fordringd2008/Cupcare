//
//  tvcSetReminderWater.h
//  Coasters
//
//  Created by 丁付德 on 15/10/22.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface tvcSetReminderWater : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UILabel *lblNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imvNumber;

@property (weak, nonatomic) IBOutlet UILabel *lblStart;
@property (weak, nonatomic) IBOutlet UILabel *lblEnd;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
