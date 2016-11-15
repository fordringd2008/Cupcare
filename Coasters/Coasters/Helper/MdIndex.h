//
//  mdIndex.h
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MdIndex : NSObject

@property (nonatomic, assign) NSInteger type;          // 1: 最近喝水
                                                       // 2: 喝水
                                                       // 3: 江华提醒你该喝水了 (知道了)                  这个是好友提醒的（推送）
                                                       // 4: 你今天喝水已经达到目标了（的一半） 你已经多久没喝水了
                                                       // 5: 江华加你为好友    （接受）                   这个是好友提醒的（推送）
                                                       // 6: 江华已经接受了你的好友申请
                                                       // 7:
                                                       // 8:
@property (nonatomic, copy) NSString *  imgString;     // 图片名称

@property (nonatomic, strong) NSDate *  date;          // 时间

@property (nonatomic, copy) NSString *  msg;           // 提示语句

@property (nonatomic, copy) NSString *  msgML;         // 50ML

@property (nonatomic, assign) BOOL      isOver;        // 是否已经处理过

@property (nonatomic, copy) NSString *  uerid;         //     uerid

@property (nonatomic, copy) NSString *  name;          //    昵称

@property (nonatomic, strong) FriendRequest *fr;       //  请求数据模型


@end
