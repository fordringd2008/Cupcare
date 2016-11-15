//
//  vcNewPerfectInfo.h
//  Coasters
//
//  Created by 丁付德 on 16/1/10.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcBase.h"

//@protocol vcNewPerfectInfoDelegate  <NSObject>
//
//-(void)setDataFromThird:(NSArray *)arrDataFromThird;
//
//@end

@interface vcNewPerfectInfo : vcBase

@property (strong, nonatomic) NSArray *arrDataFromThird; // 第三方的一些信息

@property (assign, nonatomic) BOOL isAcceptBack;         // 是否允许返回

//
//@property (nonatomic, assign) id<vcNewPerfectInfoDelegate> delegate;


@end
