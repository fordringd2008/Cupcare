//
//  vcLeft.h
//  MasterDemo
//
//  Created by 丁付德 on 15/6/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@protocol vcLeftDelegate <NSObject>

-(void)selected:(NSInteger)ind;

@end

@interface vcLeft : vcBase

@property (nonatomic, assign) id<vcLeftDelegate> delegate;

@end
