//
//  tvcCircleRequest.h
//  Coasters
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

@interface tvcCircleRequest : MGSwipeTableCell

@property (nonatomic, strong) FriendRequest *fr;

@property (nonatomic, copy) void (^acceptRequest)();

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
