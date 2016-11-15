//
//  tvcEditClock.h
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcEditClock : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTitleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblValueBottom;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
