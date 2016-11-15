//
//  vcEditClock.h
//  Coasters
//
//  Created by 丁付德 on 15/8/17.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcEditClock : vcBase

@property (nonatomic, strong) Clock *clock;                 // 上个界面传进的闹钟模型  如果 为nil 就是添加

@property (nonatomic, assign) BOOL isChange;                // 是否改变了

@property (nonatomic, assign) BOOL isAdd;                   // 是否是添加的

@end
