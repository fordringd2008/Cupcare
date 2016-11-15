//
//  UIViewController+LSNavigationBarTransition.h
//  LSNavigationBarTransition
//
//  Created by ls on 16/1/16.
//  Copyright © 2016年 song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (LSNavigationBarTransition)

@property (nonatomic, strong) UINavigationBar *ls_navigationBar;
@property (nonatomic, assign) BOOL ls_prefersNavigationBarBackgroundViewHidden;
- (void)ls_addNavigationBarIfNeed;
@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com

