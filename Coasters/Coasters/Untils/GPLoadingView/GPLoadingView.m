//
//  GPLoadingView.m
//  GPLoadingView
//
//  Created by crazypoo on 14/7/29.
//  Copyright (c) 2014年  广州文思海辉亚信外派iOS开发小组. All rights reserved.
//

#import "GPLoadingView.h"

#define ANGLE(a) 2*M_PI/360*a

@interface GPLoadingView ()

@property (nonatomic, assign) CGFloat anglePer;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GPLoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAnglePer:(CGFloat)anglePer
{
    _anglePer = anglePer;
    [self setNeedsDisplay];
}

- (void)startAnimation
{
    if (self.isAnimating) {
        [self stopAnimation];
        [self.layer removeAllAnimations];
    }
    _isAnimating = YES;
    
    self.anglePer = 0.5;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.001f target:self selector:@selector(drawPathAnimation:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation
{
    _isAnimating = NO;
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [self stopRotateAnimation];
}

- (void)drawPathAnimation:(NSTimer *)timer
{
    self.anglePer += 0.03f;
//    NSLog(@"----------------------- self.anglePer = %f", self.anglePer);
    if (self.anglePer >= 1) {
        self.anglePer = 1;
        [timer invalidate];
        self.timer = nil;
        [self startRotateAnimation];
    }
}

- (void)startRotateAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2*M_PI);
    animation.duration = 2.f;
    animation.repeatCount = INT_MAX;
    [self.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

- (void)stopRotateAnimation
{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.anglePer = 0;
        [self.layer removeAllAnimations];
        self.alpha = 1;
    }];
}

//- (void)drawRect:(CGRect)rect
//{
//    if (self.anglePer <= 0) {
//        _anglePer = 0;
//    }
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetLineWidth(context, self.lineWidth);
//
//    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
//
//    CGContextAddArc(context, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds), CGRectGetWidth(self.bounds)/2-self.lineWidth, ANGLE(270), ANGLE(270)+ANGLE(320)*self.anglePer, 0);
//
//    CGContextStrokePath(context);
//}
#pragma MARK - 腾腾转
typedef void (^voidBlock)(void);
typedef float (^floatfloatBlock)(float);
typedef UIColor * (^floatColorBlock)(float);

-(CGPoint) pointForTrapezoidWithAngle:(float)a andRadius:(float)r  forCenter:(CGPoint)p{
    return CGPointMake(p.x + r*cos(a), p.y + r*sin(a));
}

-(void)drawGradientInContext:(CGContextRef)ctx  startingAngle:(float)a endingAngle:(float)b intRadius:(floatfloatBlock)intRadiusBlock outRadius:(floatfloatBlock)outRadiusBlock withGradientBlock:(floatColorBlock)colorBlock withSubdiv:(int)subdivCount withCenter:(CGPoint)center withScale:(float)scale
{
    float angleDelta = (b-a)/subdivCount;
    float fractionDelta = 1.0/subdivCount;
    
    CGPoint p0,p1,p2,p3, p4,p5;
    float currentAngle=a;
    p4=p0 = [self pointForTrapezoidWithAngle:currentAngle andRadius:intRadiusBlock(0) forCenter:center];
    p5=p3 = [self pointForTrapezoidWithAngle:currentAngle andRadius:outRadiusBlock(0) forCenter:center];
    CGMutablePathRef innerEnveloppe=CGPathCreateMutable(),
    outerEnveloppe=CGPathCreateMutable();
    
    CGPathMoveToPoint(outerEnveloppe, 0, p3.x, p3.y);
    CGPathMoveToPoint(innerEnveloppe, 0, p0.x, p0.y);
    CGContextSaveGState(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    
    for (int i=0;i<subdivCount;i++)
    {
        float fraction = (float)i/subdivCount;
        currentAngle=a+fraction*(b-a);
        CGMutablePathRef trapezoid = CGPathCreateMutable();
        
        p1 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:intRadiusBlock(fraction+fractionDelta) forCenter:center];
        p2 = [self pointForTrapezoidWithAngle:currentAngle+angleDelta andRadius:outRadiusBlock(fraction+fractionDelta) forCenter:center];
        
        CGPathMoveToPoint(trapezoid, 0, p0.x, p0.y);
        CGPathAddLineToPoint(trapezoid, 0, p1.x, p1.y);
        CGPathAddLineToPoint(trapezoid, 0, p2.x, p2.y);
        CGPathAddLineToPoint(trapezoid, 0, p3.x, p3.y);
        CGPathCloseSubpath(trapezoid);
        
        CGPoint centerofTrapezoid = CGPointMake((p0.x+p1.x+p2.x+p3.x)/4, (p0.y+p1.y+p2.y+p3.y)/4);
        
        CGAffineTransform t = CGAffineTransformMakeTranslation(-centerofTrapezoid.x, -centerofTrapezoid.y);
        CGAffineTransform s = CGAffineTransformMakeScale(scale, scale);
        CGAffineTransform concat = CGAffineTransformConcat(t, CGAffineTransformConcat(s, CGAffineTransformInvert(t)));
        CGPathRef scaledPath = CGPathCreateCopyByTransformingPath(trapezoid, &concat);
        
        CGContextAddPath(ctx, scaledPath);
        CGContextSetFillColorWithColor(ctx,colorBlock(fraction).CGColor);
        CGContextSetStrokeColorWithColor(ctx, colorBlock(fraction).CGColor);
        CGContextSetMiterLimit(ctx, 0);
        
        CGContextDrawPath(ctx, kCGPathFillStroke);
        
        CGPathRelease(trapezoid);
        p0=p1;
        p3=p2;
        
        CGPathAddLineToPoint(outerEnveloppe, 0, p3.x, p3.y);
        CGPathAddLineToPoint(innerEnveloppe, 0, p0.x, p0.y);
        
        CGPathRelease(scaledPath);
    }
    CGContextSetLineWidth(ctx, 0);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextAddPath(ctx, outerEnveloppe);
    CGContextAddPath(ctx, innerEnveloppe);
    CGContextMoveToPoint(ctx, p0.x, p0.y);
    CGContextAddLineToPoint(ctx, p3.x, p3.y);
    CGContextMoveToPoint(ctx, p4.x, p4.y);
    CGContextAddLineToPoint(ctx, p5.x, p5.y);
    CGContextStrokePath(ctx);
    
    CGPathRelease(innerEnveloppe);
    CGPathRelease(outerEnveloppe);
    
    
}

-(void)drawRect:(CGRect)rect {
    if (self.anglePer <= 0) {
        _anglePer = 0;
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] set];
    UIRectFill(self.bounds);
    
    CGRect r = self.bounds;
    
    if (r.size.width > r.size.height)
        r.size.width=r.size.height;
    else
        r.size.height=r.size.width;
    
    float radius=r.size.width/2;
    
    [self drawGradientInContext:ctx  startingAngle:M_PI/16 endingAngle:2*M_PI-M_PI/4 intRadius:^float(float f) {
        return radius/1.05;
    } outRadius:^float(float f) {
        return radius;
    } withGradientBlock:^UIColor *(float f) {
        float sr=190;
        float er=255;
//        return [UIColor colorWithRed:(f*sr+(1-f)*er)/255. green:0 blue:0 alpha:f];
        return [UIColor colorWithWhite:255 - (f*sr+(1-f)*er)/255 alpha:f];
        
    } withSubdiv:240 withCenter:CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r)) withScale:1];
    
}

@end
