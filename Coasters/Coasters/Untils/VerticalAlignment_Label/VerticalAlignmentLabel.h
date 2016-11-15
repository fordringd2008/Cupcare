//
//  VerticalAlignmentLabel.h
//  Coasters
//
//  Created by 丁付德 on 15/9/16.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface VerticalAlignmentLabel : UILabel
{
    @private
    VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;


@end
