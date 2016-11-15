//
//  DFDAnimationCell.m
//  Coasters
//
//  Created by 丁付德 on 16/7/5.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "DFDAnimationCell.h"
#import "POP.h"

@implementation DFDAnimationCell

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.highlighted) {
        POPBasicAnimation *scaleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.duration = 0.1;
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.95, 0.95)];
        [self.contentView pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    } else {
        POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        scaleAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        scaleAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(2, 2)];
        scaleAnimation.springBounciness = 20.f;
        [self.contentView pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    }
}

@end
