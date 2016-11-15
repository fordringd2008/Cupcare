//
//  tvcSearch.h
//  Coasters
//
//  Created by 丁付德 on 15/8/25.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface tvcSearch : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
