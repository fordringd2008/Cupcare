//
//  TAlertView.m
//  Taxation
//
//  Created by Seven on 15-1-13.
//  Copyright (c) 2015年 Allgateways. All rights reserved.
//

#import "TAlertView.h"

@interface TAlertView (){
    ALERT_TYPE _alert_type;
}
@property (nonatomic, strong) UIView *dialogView;
@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *messageString;

@property (nonatomic, strong) action sure;
@property (nonatomic, strong) action cancel;
@property (nonatomic, strong) actionReturn sureReturn;
@property (nonatomic, strong) action camera;
@property (nonatomic, strong) action photo;

@property (nonatomic, strong) UITextField *txf;

@property (nonatomic, assign) UIKeyboardType keyboardType;

@property (nonatomic, assign) NSString *str;

@property (nonatomic, strong) UITapGestureRecognizer *ges;
@end

@implementation TAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)msg
{
    self = [super init];
    if (self)
    {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _titleString = kString(title); //title;
        _messageString = kString(msg);
        self.ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction:)];
        [self addGestureRecognizer:self.ges];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)msg cancelStr:(NSString *)cancelStr sureStr:(NSString *)surStr
{
    self.cancelStr = cancelStr;
    self.surStr = surStr;
    return [self initWithTitle:title message:msg];
}


-(UIView *)creatDialogView{
    UIView *dialog = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 295, 220)];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:dialog.bounds];
    imageview.image = [UIImage imageNamed:@"alert_back"];
    [dialog addSubview:imageview];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width, 20)];
    title.font = [UIFont systemFontOfSize:16];
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = self.titleString;
    title.center = CGPointMake(dialog.bounds.size.width / 2, title.bounds.size.height + 10);
    [dialog addSubview:title];
    
    if (_alert_type == ALERT_TIP_ACTION)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.frame = CGRectMake(0, 0, 127, 49);
        button.center = CGPointMake((dialog.bounds.size.width / 4) * 3, dialog.bounds.size.height - button.bounds.size.height);
        
        [button addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        //[button setTitle:kString(@"确定") forState:UIControlStateNormal];
        [button setTitle:self.surStr ? kString(self.surStr) : kString(@"确定") forState:UIControlStateNormal];
        
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_sure_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_sure_focus"] forState:UIControlStateHighlighted];
        [dialog addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.frame = CGRectMake(0, 0, 127, 49);
        button.center = CGPointMake(dialog.bounds.size.width / 4, dialog.bounds.size.height - button.bounds.size.height);
        [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //[button setTitle:kString(@"取消") forState:UIControlStateNormal];
        [button setTitle:self.cancelStr ? kString(self.cancelStr) : kString(@"取消") forState:UIControlStateNormal];
        
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_cancle_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_cancle_focus"] forState:UIControlStateHighlighted];
        [dialog addSubview:button];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width - 20, 85)];
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.numberOfLines = 0;
        //    contentLabel.lineBreakMode =
        contentLabel.center = CGPointMake(dialog.bounds.size.width / 2, 95);
        contentLabel.textColor = RGBA(0, 0, 0, 0.7);
        contentLabel.text = self.messageString;
        [dialog addSubview:contentLabel];
        
    }else if(_alert_type == ALERT_TIP)
    {
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width - 20, 130)];
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        contentLabel.numberOfLines = 0;
        //    contentLabel.lineBreakMode =
        contentLabel.center = CGPointMake(dialog.bounds.size.width / 2, 95);
        contentLabel.textColor = RGBA(0, 0, 0, 0.7);
        contentLabel.text = self.messageString;
        [dialog addSubview:contentLabel];
    
    }else if(_alert_type == ALERT_ACTION)
    {
        UIImageView *imagev = [[UIImageView alloc] initWithFrame:CGRectMake(10, 55 + (dialog.bounds.size.height - 55) / 2.0f / 2.0f - 15, 30, 30)];
        imagev.image = [UIImage imageNamed:@"piker_photo"];
        [dialog addSubview:imagev];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(imagev.frame.origin.x + imagev.frame.size.width + 10, imagev.frame.origin.y, 100, imagev.bounds.size.height)];
        textLabel.text = kString(@"相册");
        textLabel.font = [UIFont systemFontOfSize:17];
        textLabel.textColor = [UIColor colorWithRed:0.0f green:.0f blue:.0f alpha:.7f];
        [dialog addSubview:textLabel];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 55, dialog.bounds.size.width, (dialog.bounds.size.height - 55) / 2.0f);
        [button setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(photo:) forControlEvents:UIControlEventTouchUpInside];
        [dialog addSubview:button];
        [dialog sendSubviewToBack:button];
        
        CALayer *line = [CALayer layer];
        line.frame = CGRectMake(0, 55 + (dialog.bounds.size.height - 55) / 2.0f - 3, dialog.bounds.size.width, .5);
        line.backgroundColor = [UIColor grayColor].CGColor;
        [dialog.layer addSublayer:line];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 55 + (dialog.bounds.size.height - 55) / 2.0f, dialog.bounds.size.width, (dialog.bounds.size.height - 55) / 2.0f - 10);
        [button setBackgroundImage:[UIImage imageFromColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(camera:) forControlEvents:UIControlEventTouchUpInside];
        [dialog addSubview:button];
        [dialog sendSubviewToBack:button];
        
        imagev = [[UIImageView alloc] initWithFrame:CGRectMake(10, 55 + (dialog.bounds.size.height - 55) / 2.0f + (dialog.bounds.size.height - 55) / 2.0f / 2.0f - 15, 30, 30)];
        imagev.image = [UIImage imageNamed:@"picker_camera"];
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(imagev.frame.origin.x + imagev.frame.size.width + 10, imagev.frame.origin.y, 100, imagev.bounds.size.height)];
        textLabel.text = kString(@"我的相机");
        textLabel.font = [UIFont systemFontOfSize:17];
        textLabel.textColor = [UIColor colorWithRed:0.0f green:.0f blue:.0f alpha:.7f];
        [dialog addSubview:textLabel];
        
        [dialog addSubview:imagev];
        
    }else if (_alert_type == ALERT_DATEPICKER)
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width, dialog.bounds.size.height - 60)];
        [dialog addSubview:picker];
    }else if (_alert_type == ALERT_TXF)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.frame = CGRectMake(0, 0, 127, 49);
        button.center = CGPointMake(dialog.bounds.size.width / 4 * 3, dialog.bounds.size.height - button.bounds.size.height);
        [button addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:kString(@"确定") forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_sure_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_sure_focus"] forState:UIControlStateHighlighted];
        [dialog addSubview:button];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.frame = CGRectMake(0, 0, 127, 49);
        button.center = CGPointMake((dialog.bounds.size.width / 4), dialog.bounds.size.height - button.bounds.size.height);
        [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitle:kString(@"取消") forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_cancle_normal"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"close_dialog_cancle_focus"] forState:UIControlStateHighlighted];
        [dialog addSubview:button];
        
        // ------
        self.txf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width - 20, 30)];
        self.txf.text = self.strOriginal;
        self.txf.center = CGPointMake(dialog.bounds.size.width / 2, 105);
        self.txf.keyboardType = self.keyboardType;
        [self.txf becomeFirstResponder];
        [dialog addSubview:self.txf];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, dialog.bounds.size.width - 20, 1)];
        line.center = CGPointMake(dialog.bounds.size.width / 2, 120);
        line.backgroundColor = [UIColor lightGrayColor]; //RGBA(255, 255, 255, 0.3);
        [dialog addSubview:line];
        
        [self removeGestureRecognizer:self.ges];
        self.ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(txflostReginer:)];
        [self addGestureRecognizer:self.ges];
    }
    else if (_alert_type == ALERT_ACTIONS)
    {
        NSUInteger count = _arrActions.count;
        CGFloat contentheight = 168.0;
        CGFloat contentWidth = dialog.bounds.size.width - 20;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, contentheight)];
        contentView.center = CGPointMake(dialog.bounds.size.width / 2, 135);
        //  contentView.backgroundColor = [UIColor yellowColor];
        [dialog addSubview:contentView];
        
        for (CGFloat i = 0; i < count; i++)
        {
            UIButton *  button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.titleLabel.font = [UIFont systemFontOfSize:18];
            button.frame = CGRectMake(0, 0, dialog.bounds.size.width - 20, contentheight / count);
            CGPoint p = CGPointMake(contentWidth / 2, contentheight * ((i * 2.0 + 1.0) / ((CGFloat)count * 2.0)));
            
            button.center = p;
            button.tag = (int)i;
            [button addTarget:self action:@selector(customActions:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            NSString *str = self.arrTitle[(int)i];
            [button setTitle: kString(str) forState:UIControlStateNormal];
            [contentView addSubview:button];
            
            UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 1)];
            p = CGPointMake(contentWidth / 2, contentheight * ((i + 1) * 2) / ((CGFloat)count * 2.0));
            //NSLog(@"%f, %f", p.x, p.y);
            line.center = p;
            
            line.backgroundColor = [UIColor lightGrayColor];
            if (i != count - 1)
             [contentView addSubview:line];
        }
        
        
    }
    
    return dialog;
}

- (void)showWithTXFActionSure:(actionWithStr)actionStr cancel:(action)cancel keyboardType:(UIKeyboardType)keyboardType
{
    _alert_type = ALERT_TXF;
    self.actionStr = actionStr;
    self.cancel = cancel;
    self.keyboardType = keyboardType;
    [self showAlert];
}




-(void)showWithActionSure:(action)sure cancel:(action)cancel{
    _alert_type = ALERT_TIP_ACTION;
    self.sure = sure;
    self.cancel = cancel;
    [self showAlert];
}

-(void)showTips{
    _alert_type = ALERT_TIP;
    [self showAlert];
}

-(void)showActionCamera:(action)camera photoA:(action)picker{
    _alert_type = ALERT_ACTION;
    self.camera = camera;
    self.photo = picker;
    [self showAlert];
}


- (void)showActionDate:(actionWithParam)dateselected{
    _alert_type = ALERT_DATEPICKER;
    [self showAlert];
}



- (void)showWithAcitons:(NSArray *)arr arrActions:(NSArray *)arrAcitons{
    _alert_type = ALERT_ACTIONS;
    _arrTitle = arr;
    _arrActions = arrAcitons;
    [self showAlert];
}

-(void)showAlert{
    _dialogView = [self creatDialogView];
    
    if (_alert_type == ALERT_TXF)
        _dialogView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 - 30);
    else
        _dialogView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    
    
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:_dialogView];
    
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
}


// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    CATransform3D currentTransform = _dialogView.layer.transform;
    
    CGFloat startRotation = [[_dialogView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CATransform3D rotation = CATransform3DMakeRotation(-startRotation + M_PI * 270.0 / 180.0, 0.0f, 0.0f, 0.0f);
    
    _dialogView.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1));
    _dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

-(void)sureAction:(id)sender{
    if (_alert_type == ALERT_TXF) {
        [self.txf resignFirstResponder];
        self.actionStr(self.txf.text);
    }
    else if (self.sure) {
        self.sure();
    }
    [self close];
}

-(void)closeAction:(id)sender{
    if (self.cancel) {
        self.cancel();
    }
    
    [self close];
}

-(void)txflostReginer:(id)sender{
    [self.txf resignFirstResponder];
}

-(void)photo:(id)sender{
    if (self.photo) {
        self.photo();
    }
     [self close];
}

-(void)camera:(id)sender{
    if (self.camera) {
        self.camera();
    }
     [self close];
}

-(void)customActions:(UIButton *)sender{
    [self close];
    if (self.arrActions) {
        void (^block)() = self.arrActions[sender.tag];
        block();
    }
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
