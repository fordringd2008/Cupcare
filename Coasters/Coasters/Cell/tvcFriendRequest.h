//
//  tvcFriendRequest.h
//  Coasters
//
//  Created by 丁付德 on 15/9/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "RequestFr.h"
#import "MGSwipeTableCell.h"

@protocol tvcFriendRequestDelegate <NSObject>

-(void)accept:(RequestFr *)rf;

@end

@interface tvcFriendRequest : MGSwipeTableCell

@property (strong, nonatomic) RequestFr *model;


@property (assign, nonatomic) id<tvcFriendRequestDelegate> delegateA;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
