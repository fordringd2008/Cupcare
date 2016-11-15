//
//  tvcFriendRank.h
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>


@class tvcFriendRank;
@protocol tvcFriendRankDelegate <NSObject>

-(void)btnClickLike:(tvcFriendRank *)cell;

@end


@interface tvcFriendRank : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblValue;
@property (weak, nonatomic) IBOutlet UILabel *lblLikeNumber;
@property (weak, nonatomic) IBOutlet UIImageView *imvHeart;
@property (weak, nonatomic) IBOutlet UIButton *btnlike;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblValueRight;

@property (weak, nonatomic) IBOutlet UILabel *lblNameTop;
@property (weak, nonatomic) IBOutlet UILabel *lblNameBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNumberWidth;


- (IBAction)btnClick:(id)sender;

@property (assign,nonatomic) id<tvcFriendRankDelegate> delegate;

@property (assign, nonatomic) BOOL isLiked;     // 是否已经点过赞了
@property (assign, nonatomic) BOOL isMySelf;    // 是否是自己
@property (strong, nonatomic) Friend *model;

@property (strong, nonatomic) FriendInGlobal *fgModel;



+ (instancetype)cellWithTableView:(UITableView *)tableView;



@end
