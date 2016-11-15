//
//  UIViewController+Delay.h
//  
//
//  Created by 丁付德 on 15/5/21.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Delay)


/**
 *  自定义跳转动画
 *
 *  @param isBack 是否向左边跳转
 */
//-(void)JumpAnimation:(BOOL)isBack;

/**
 *  跳转到任意一个故事板的任意界面
 *
 *  @param storyboardName 故事板名称
 *  @param identifier     指定view的identifier
 */
-(void)JumpToOtherView:(NSString *)storyboardName storyboardID:(NSString *)storyboardID;

/**
 *  跳转到任意一个故事板的任意界面
 *
 *  @param storyboardName 故事板名称
 *  @param storyboardID   指定view的identifier
 *  @param dic            传送的字典
 */
//-(void)JumpToOtherViewWithValue:(NSString *)storyboardName storyboardID:(NSString *)storyboardID array:(NSArray *)array;


@end
