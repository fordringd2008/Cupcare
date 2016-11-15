//
//  tvcUser.h
//  Coasters
//
//  Created by 丁付德 on 15/8/26.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcUser : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imvBig;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
//@property (weak, nonatomic) IBOutlet UIImageView *line;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvBigHeight;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
