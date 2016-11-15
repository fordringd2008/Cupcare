/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The interaction controller for the Swipe demo.  Tracks a UIScreenEdgePanGestureRecognizer
  from a specified screen edge and derives the completion percentage for the
  transition.
 */

#import <UIKit/UIKit.h>

//#import "UIViewController+LSNavigationBarTransition.h"
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_Height [UIScreen mainScreen].bounds.size.height

@interface LSStack : NSObject
- (id)getTop;
- (void)push:(id)obj;
- (void)pop;
@end

@interface LSInteractionTransition : NSObject<UIViewControllerInteractiveTransitioning,UIViewControllerAnimatedTransitioning>
- (void)updateWithPercent:(CGFloat)percent;

- (void)finishBy:(BOOL)finished;
@end


// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com