//
//  Message.m
//  Coasters
//
//  Created by 丁付德 on 15/8/21.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "Message.h"

extern NSString *CTSettingCopyMyPhoneNumber();

@implementation Message

+(NSString *)myNumber{
    return CTSettingCopyMyPhoneNumber();
}

@end
