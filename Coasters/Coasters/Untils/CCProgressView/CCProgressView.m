//
//  CCProgressView.m
//  ProgressViewDemo
//
//  Created by mr.cao on 14-5-27.
//  Copyright (c) 2014年 mrcao. All rights reserved.
//

#import "CCProgressView.h"
#import "UICountingLabel.h"

@interface CCProgressView()
{
    
    
    float _currentLinePointY;
    
    float a;
    float b;
    
    BOOL jia;

}
@end

@implementation CCProgressView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer*)self.layer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.lastValue = -1;
        CGFloat startAngle =0;
        CGFloat endAngle = 360;
        
        _lineWidth = [NSNumber numberWithFloat:4.0]; // 外环的宽度
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width/2,frame.size.height/2) radius:self.frame.size.height * 0.5 startAngle:DEGREES_TO_RADIANS(startAngle) endAngle:DEGREES_TO_RADIANS(endAngle) clockwise:YES];
        
        _circleBG             = [CAShapeLayer layer];
        _circleBG.path        = circlePath.CGPath;
        _circleBG.lineCap     = kCALineCapRound;
//        _circleBG.fillColor   = [UIColor clearColor].CGColor;
//        _circleBG.fillColor   = RGB(132, 146, 155).CGColor;
        
        _circleBG.lineWidth   = [_lineWidth floatValue];
        _circleBG.strokeColor = RGBA(255, 255, 255, 0.5).CGColor;  //外环的填充颜色
        _circleBG.zPosition   = -1;
        
        [self.layer addSublayer:_circleBG];
        
        CAShapeLayer* maskLayer = [CAShapeLayer layer];
        maskLayer.path = circlePath.CGPath;
        self.gradientLayer.mask = maskLayer;
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[RGBA(56, 170, 238, 1) CGColor],(id)[RGBA(56, 170, 238, 1) CGColor], nil];
        self.gradientLayer.locations = @[@0.f, @0.f];
        
        self.gradientLayer.startPoint =CGPointMake(0.5, 1);
        self.gradientLayer.endPoint = CGPointMake(0.5, 0);
    }
    
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    if (self.isOnly) {
        [super setBackgroundColor:backgroundColor];
    }else
    {
        _circleBG.fillColor = backgroundColor.CGColor;
        [super setBackgroundColor:backgroundColor];
    }
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    CGFloat rescaledProgress = MIN(MAX(progress, 0.f), 1.f);
    NSArray* newLocations =@[[NSNumber numberWithFloat:rescaledProgress], [NSNumber numberWithFloat:rescaledProgress]];
    
    if (animated)
    {
        NSTimeInterval duration = 0.5;
        [UIView animateWithDuration:duration animations:^{
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"locations"];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.duration = duration;
            animation.delegate = self;
            animation.fromValue = self.gradientLayer.locations;
            animation.toValue = newLocations;
            [self.gradientLayer addAnimation:animation forKey:@"animateLocations"];
        }];
    }
    else
    {
        [self.gradientLayer setNeedsDisplay];
    }
    
    self.gradientLayer.locations = newLocations;
    a = 0;                                          //  起始振幅
    b = 0;
    jia = NO;
    _currentLinePointY = self.frame.size.height*(1-progress);
    _currentWaterColor = RGB(56, 170, 238);
    
    
    //NSLog(@"--------------- > %@, _currentLinePointY : %f", [NSThread currentThread], _currentLinePointY);
    
    //_currentLinePointY = 250;
    if(_theTimer)
    {
        [_theTimer invalidate];
        _theTimer=nil;
    }
     _theTimer=[NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
}


-(void)animateWave
{
    
    if (jia) {
        a += 0.01;
    }else{
        a -= 0.01;
    }
    
    if (a<=0.1) {// 这里控制振幅                      这里控制的是  初始后， 在原来的振幅上震动过几次后， 稳定下来的振幅
        jia = YES;
    }
    
    if (a>=0.2) {
        jia = NO;
    }
    
    
    b+=0.1;
    
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef path = CGPathCreateMutable();
    
    //画水
    CGContextSetLineWidth(context, 1);
    CGContextSetFillColorWithColor(context, [_currentWaterColor CGColor]);
//    CGContextSetFillColorWithColor(context, [DRed CGColor]);
    
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0;x<=ScreenWidth;x++){
        y= a * sin( x/180*M_PI + 8*b/M_PI ) * 10 + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, ScreenWidth, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
//    CGPathAddLineToPoint(path, nil, 0, _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    
}

@end