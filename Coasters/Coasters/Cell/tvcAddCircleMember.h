//
//  tvcCircleMember.h
//  Coasters
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcAddCircleMember : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imvCheck;

@property (nonatomic, weak) IBOutlet UIImageView *imvUrl;

@property (nonatomic, weak) IBOutlet UILabel *lblName;



+ (instancetype)cellWithTableView:(UITableView *)tableView;



@end
