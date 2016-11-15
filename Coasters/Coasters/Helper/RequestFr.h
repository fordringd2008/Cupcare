//
//  RequestFr.h
//  Coasters
//
//  Created by 丁付德 on 15/9/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestFr : NSObject

@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSNumber *user_gender;
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL      isOver;
@property (strong, nonatomic) id        model;      // 当前对象   可能是请求  也可能是 朋友

@end
