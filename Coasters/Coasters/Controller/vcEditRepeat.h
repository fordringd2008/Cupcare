//
//  vcEditRepeat.h
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcEditRepeatDelegate <NSObject>

-(void)changeRepeat:(NSMutableArray *)arr;

@end

@interface vcEditRepeat : vcBase

@property (nonatomic, strong) Clock *clock;                 // 上个界面传进的闹钟模型

@property (nonatomic, assign) id<vcEditRepeatDelegate> delegate;

@end
