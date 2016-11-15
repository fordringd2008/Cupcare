//
//  vcFirst.h
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcFirstDelegate <NSObject>

-(void)pageControlHidden:(BOOL)isHidden;

@end

@interface vcFirst : vcBase

@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UIView *viewStar;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;

@property (strong, nonatomic) Friend *model;                      // 好友界面传进来的好友对象

@property (assign, nonatomic) NSInteger indexSub;                 // 当前的标签  1：日  2：月   3：年

@property (assign, nonatomic) NSInteger yearSub1;                 // 选中的年             // tab1模式下
@property (assign, nonatomic) NSInteger monthSub1;                // 选中的月
@property (assign, nonatomic) NSInteger daySub1;                  // 选中的天
@property (assign, nonatomic) NSInteger yearSub2;                 // 选中的年             // tab2模式下
@property (assign, nonatomic) NSInteger monthSub2;                // 选中的月
@property (assign, nonatomic) NSInteger yearSub3;                 // 选中的年             // tab3模式下
@property (assign, nonatomic) NSInteger percent;                  // 得分   0 - 100;

@property (copy, nonatomic) NSString *acc;

@property (nonatomic, assign) id<vcFirstDelegate> delegate;

//pickView消失
- (void)pickerViewDisappear;




@end
