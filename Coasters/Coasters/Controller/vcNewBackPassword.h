//
//  vcNewBackPassword.h
//  Coasters
//
//  Created by 丁付德 on 16/1/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcNewBackPasswordDelegate  <NSObject>

-(void)FillIn:(NSString *)email;

@end

@interface vcNewBackPassword : vcBase

@property (nonatomic, assign) id<vcNewBackPasswordDelegate> delegate;

@end
