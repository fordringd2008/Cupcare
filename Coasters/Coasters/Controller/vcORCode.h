//
//  vcORCode.h
//  Coasters
//
//  Created by 丁付德 on 15/8/12.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

typedef enum {

    UserORCode = 0,                 // 个人的二维码
    CircleORCode                    // 圈子的二维码
    
} ORCodeType;



@interface vcORCode : vcBase

@property (nonatomic, assign) ORCodeType orcodeType;

@property (nonatomic, strong) Group *group;              // 传进来的圈子

@end
