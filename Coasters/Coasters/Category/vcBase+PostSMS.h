//
//  vcBase+PostSMS.h
//  Coasters
//
//  Created by 丁付德 on 16/6/18.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcBase (PostSMS)

-(void)postSMS:(NSString *)phoneNumber countrycode:(NSString *)countrycode block:(void(^)())block;


@end
