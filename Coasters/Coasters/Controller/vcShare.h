//
//  vcShare.h
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcBase.h"

@interface vcShare : vcBase

@property (strong, nonatomic) NSMutableArray *arrShareData; //传进的数组
                                                            // 0: 2015年10月15日喝水记录"
                                                            // 1: 得分前的语句
                                                            // 2: 得分 NSNumber
                                                            // 3: lbl1.text
                                                            // 4: lbl2
                                                            // 5: lbl3
                                                            // 6: lbl4
                                                            // 7: lbl5
                                                            // 8: lbl6

@end
