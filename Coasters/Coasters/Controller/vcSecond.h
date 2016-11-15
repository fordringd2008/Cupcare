//
//  vcSecond.h
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcSecond : vcBase

@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UIView *viewStar;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;

@property (assign, nonatomic)  NSInteger year;
@property (assign, nonatomic)  NSInteger month;
@property (assign, nonatomic)  NSInteger percent;              // 得分   0 - 100;

@property (copy, nonatomic) NSString *acc;


@end
