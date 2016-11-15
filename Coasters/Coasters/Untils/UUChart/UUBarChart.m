//
//  UUBarChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBarChart.h"
#import "UUChartLabel.h"
#import "UUBar.h"

@interface UUBarChart ()
{
    UIScrollView *myScrollView;
}
@end

@implementation UUBarChart
{
    NSHashTable *_chartLabelsForX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width-UUYLabelwidth, frame.size.height)];
        myScrollView.scrollEnabled = NO;
        [self addSubview:myScrollView];
    }
    return self;
}

-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setYLabels:yValues];
}

-(void)setYLabels:(NSArray *)yLabels
{
    NSInteger max = 0;
    NSInteger min = 1000000000;
    for (NSArray * ary in yLabels) {
        for (NSString *valueString in ary) {
            NSInteger value = [valueString integerValue];
            if (value > max) {
                max = value;
            }
            if (value < min) {
                min = value;
            }
        }
    }
    if (max < 5) {
        max = 5;
    }
    if (self.showRange) {
        _yValueMin = (int)min;
    }else{
        _yValueMin = 0;
    }
    _yValueMax = (int)max;
    
    if (_chooseRange.max!=_chooseRange.min) {
        _yValueMax = _chooseRange.max;
        _yValueMin = _chooseRange.min;
    }
    
    float level = (_yValueMax-_yValueMin) /4.0;
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight /4.0;
    
    for (int i=0; i<5; i++)
    {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0.0,chartCavanHeight-i*levelHeight+5, UUYLabelwidth, UULabelHeight)];
        label.textColor = DWhite;
        label.text = [NSString stringWithFormat:@"%.0f",level * i+_yValueMin];
        [self addSubview:label];
    }
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(UUYLabelwidth,UULabelHeight+4*levelHeight )];
    [path addLineToPoint:CGPointMake(self.frame.size.width,UULabelHeight+4*levelHeight)];
    [path closePath];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = DWhiteA(0.3).CGColor;
    shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
    shapeLayer.lineWidth = 1;
    [self.layer addSublayer:shapeLayer];
    
}

-(void)setXLabels:(NSArray *)xLabels
{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }

    _xLabels = xLabels;
    NSInteger num = xLabels.count;
    _xLabelWidth = myScrollView.frame.size.width/num;
    
    
    for (int i=0; i<xLabels.count; i++) {
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake((i *  _xLabelWidth )-3, self.frame.size.height - UULabelHeight, _xLabelWidth + 8, UULabelHeight)];
        label.text = xLabels[i];
        label.textColor = DWhite;
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = DClear;
        if (i % self.Interval == 0)
            [myScrollView addSubview:label];
    }
    
    float max = (([xLabels count]-1)*_xLabelWidth + chartMargin)+_xLabelWidth;
    if (myScrollView.frame.size.width < max-10) {
        myScrollView.contentSize = CGSizeMake(max, self.frame.size.height);
    }
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
}
- (void)setChooseRange:(CGRange)chooseRange
{
    _chooseRange = chooseRange;
}
-(void)strokeChart
{
    CGFloat chartCavanHeight = myScrollView.frame.size.height - UULabelHeight*3;
    //NSLog(@"-----------  chartCavanHeight = %.0f", chartCavanHeight);
    
    for (int i=0; i<_yValues.count; i++) {
        if (i==2)
            return;
        NSArray *childAry = _yValues[i];
        for (int j=0; j<childAry.count; j++)
        {
            NSString *valueString = childAry[j];
            float value = [valueString floatValue];
//            NSLog(@"value %f", value);
//            if (value == 58 || value == 6208) {
//                NSLog(@"");
//            }
            float grade = ((float)value-_yValueMin) / ((float)_yValueMax-_yValueMin);
            
            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake((j+(_yValues.count==1?0.1:0.25))*_xLabelWidth +i*_xLabelWidth * 0.1, 0, _xLabelWidth * (_yValues.count==1?0.8:0.45), chartCavanHeight + UULabelHeight)];
            
//            Border(bar, DRed);
            
            bar.barColor = [_colors objectAtIndex:i];
            bar.grade = grade;
            //NSLog(@"frame left:%f top:%f width:%f height:%f grade:%f", bar.frame.origin.x, bar.frame.origin.y, bar.frame.size.width, bar.frame.size.height, grade);
            [myScrollView addSubview:bar];
        }
    }
}


- (NSArray *)chartLabelsForX
{
    return [_chartLabelsForX allObjects];
}

@end






















