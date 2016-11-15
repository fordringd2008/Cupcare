//
//  UIViewController+Delay.m
//  
//
//  Created by 丁付德 on 15/5/21.
//  Copyright (c) 2015年 yyh. All rights reserved.
//

#import "UIViewController+Delay.h"
#import "vcBase.h"

@implementation UIViewController (Delay)


///**
// *  延迟执行
// *
// *  @param block 执行的block
// *  @param delay 延迟的时间：秒
// */
//- (void)performBlock:(void(^)())block afterDelay:(NSTimeInterval)delay {
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), block);
//}

/**
 *  跳转到任意一个故事板的任意界面
 *
 *  @param storyboardName 故事板名称
 *  @param identifier     指定view的identifier
 */
-(void)JumpToOtherView:(NSString *)storyboardName storyboardID:(NSString *)storyboardID
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *vc = [story instantiateViewControllerWithIdentifier:storyboardID];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  跳转到任意一个故事板的任意界面
 *
 *  @param storyboardName 故事板名称
 *  @param storyboardID   指定view的identifier
 *  @param dic            传送的字典
 */
//-(void)JumpToOtherViewWithValue:(NSString *)storyboardName storyboardID:(NSString *)storyboardID array:(NSArray *)array;
//{
//    UIStoryboard *story = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
//    vcBase *vc = [story instantiateViewControllerWithIdentifier:storyboardID];
//    vc.arrPush = array;
//    [self.navigationController pushViewController:vc animated:YES];
//}

/**
 *  自定义跳转动画
 *
 *  @param isBack 是否向左边跳转
 */

//-(void)JumpAnimation:(BOOL)isBack
//{
//    CATransition *transition = [CATransition animation];
//    transition.duration = 1;
//    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//    transition.type = kCATransitionReveal;  // kCATransitionPush, kCATransitionFade, kCATransitionMoveIn, kCATransitionReveal
//    
//    if (isBack) {
//        transition.subtype = kCATransitionFromLeft;
//    }
//    else
//    {
//        transition.subtype = kCATransitionFromRight;
//    }
//    //transition.subtype = kCATransitionFromTop; // kCATransitionFromLeft, kCATransitionFromTop, kCATransitionFromBottom
//    transition.delegate = self;
//    [self.navigationController.view.layer addAnimation:transition forKey:nil];
//}








@end
