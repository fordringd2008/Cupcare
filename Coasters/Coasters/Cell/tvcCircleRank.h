//
//  tvcCircleRank.h
//  Coasters
//
//  Created by 丁付德 on 16/6/6.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcCircleRank : UITableViewCell


@property(nonatomic, weak)  IBOutlet UILabel *lblNumber;
@property(nonatomic, weak)  IBOutlet UILabel *lblName;
@property(nonatomic, weak)  IBOutlet UILabel *lblValue;
@property(nonatomic, weak)  IBOutlet UIImageView *imv;



+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
