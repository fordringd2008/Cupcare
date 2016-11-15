//
//  LSNavigationController.h
//  LSNavigationBarTransition
//
//  Created by ls on 16/1/16.
//  Copyright © 2016年 song. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSInteractionTransition.h"


@interface LSNavigationController : UINavigationController<UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIViewControllerInteractiveTransitioning, UIViewControllerTransitioningDelegate, UINavigationBarDelegate>

//交互动画
@property (nonatomic, strong) LSInteractionTransition *interactionAnimation;

@property (nonatomic, strong) LSStack* stack;
//是否开启全屏右滑
@property (nonatomic, assign) BOOL fullScreenGesture;

@property (nonatomic, copy) void (^showLeft)();         // 当只有一个控制器的时候 显示左侧栏

-(void)refreshBackgroundImage;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com