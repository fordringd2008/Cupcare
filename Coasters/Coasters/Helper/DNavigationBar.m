//
//  DNavigationBar.m
//  Coasters
//
//  Created by 丁付德 on 15/12/20.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "DNavigationBar.h"

@implementation DNavigationBar

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)])
    {
        NSArray *list= self.subviews;
        for (id obj in list)
        {
            if ([obj isKindOfClass:[UIImageView class]])
            {
                UIImageView *imageView = (UIImageView *)obj;
                NSArray *list2 = imageView.subviews;
                for (id obj2 in list2)
                {
                    if ([obj2 isKindOfClass:[UIImageView class]])
                    {
                        UIImageView *imageView2 = (UIImageView *)obj2;
                        imageView2.hidden = YES;
                    }
                }
            }
        }
    }
    
    [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.shadowImage = [[UIImage alloc] init];
    self.backgroundColor = DClear;
}

@end
