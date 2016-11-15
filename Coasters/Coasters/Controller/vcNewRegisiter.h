//
//  vcNewRegisiter.h
//  Coasters
//
//  Created by 丁付德 on 16/1/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcNewRegisiterDelegate  <NSObject>

-(void)FillIn:(NSString *)email;

@end

@interface vcNewRegisiter : vcBase

@property (nonatomic, assign) id<vcNewRegisiterDelegate> delegate;


@end
