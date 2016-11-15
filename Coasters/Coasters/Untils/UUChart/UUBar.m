//
//  UUBar.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBar.h"
#import "UUColor.h"

@implementation UUBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		_chartLine = [CAShapeLayer layer];
		_chartLine.lineCap = kCALineCapSquare;
		_chartLine.fillColor   = [[UIColor whiteColor] CGColor];
		_chartLine.lineWidth   = self.frame.size.width;
		_chartLine.strokeEnd   = 0.0;
		self.clipsToBounds = YES;
		[self.layer addSublayer:_chartLine];
		self.layer.cornerRadius = 2.0;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setGrade:(float)grade
{
    if (grade==0)
    return;
    
	_grade = grade;
	UIBezierPath *progressline = [UIBezierPath bezierPath];
    
    [progressline moveToPoint:CGPointMake(self.frame.size.width/2.0, self.frame.size.height)];//  这里减去了30
//	[progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - grade) * (float)(self.frame.size.height - 10)+15)];
    
    
    CGFloat tag = 19;
    if ([[UIScreen mainScreen] bounds].size.height == 667)
        tag = 21;
    else if ([[UIScreen mainScreen] bounds].size.height == 736)
        tag = 23;

    [progressline addLineToPoint:CGPointMake(self.frame.size.width/2.0, (1 - grade) * (float)(self.frame.size.height - 10)+tag)];
    [progressline setLineWidth:1.0];
    [progressline setLineCapStyle:kCGLineCapSquare];
	_chartLine.path = progressline.CGPath;

	if (_barColor) {
		_chartLine.strokeColor = [_barColor CGColor];
	}else{
        _chartLine.strokeColor = [UIColor redColor].CGColor;//[UUGreen CGColor];
	}
    // 动画
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.5;
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:1.0f];
    pathAnimation.autoreverses = NO;
    [_chartLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    
    _chartLine.strokeEnd = 2.0;
}

- (void)drawRect:(CGRect)rect
{
	//Draw BG
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
	CGContextFillRect(context, rect);
    
}


@end
