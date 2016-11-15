//
//  TAlertView.h
//  Taxation
//
//  Created by Seven on 15-1-13.
//  Copyright (c) 2015年 Allgateways. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ALERT_TIP,
    ALERT_ACTION,
    ALERT_TIP_ACTION,
    ALERT_DATEPICKER,
    ALERT_TXF,
    ALERT_ACTIONS           // 自定义 多事件
} ALERT_TYPE;

typedef void(^action)(void);
typedef void(^actionWithParam)(id date);
typedef void(^actionWithStr)(id str);

typedef NSInteger(^actionReturn) (NSInteger a);

@interface TAlertView : UIView

- (id)initWithTitle:(NSString *)title message:(NSString *)msg;
- (void)showWithActionSure:(action)sure cancel:(action)cancel;
- (void)showTips;
- (void)showActionCamera:(action)camera photoA:(action)picker;
- (void)showActionDate:(actionWithParam)dateselected;
- (void)close;

// 自定义 按钮文字
- (id)initWithTitle:(NSString *)title message:(NSString *)msg cancelStr:(NSString *)cancelStr sureStr:(NSString *)surStr;

// 弹出输入框
- (void)showWithTXFActionSure:(actionWithStr)actionStr cancel:(action)cancel keyboardType:(UIKeyboardType)keyboardType;

//- (void)showWithCustomeActionSure:(action)actionStr cancel:(action)cancel;

// 自定义多行， 多行的点击事件
- (void)showWithAcitons:(NSArray *)arr arrActions:(NSArray *)arrAcitons;

@property (nonatomic, copy) NSString *cancelStr;
@property (nonatomic, copy) NSString *surStr;
@property (nonatomic, strong) actionWithStr actionStr;

@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NSArray *arrActions;

@property (nonatomic, strong)  NSString * strOriginal;  // 原始的字符

@end

//@interface TAlertAction : NSObject
//
//@property (strong, nonatomic) NSString *title;
//@property (strong, nonatomic) void (^action)();
//
//+ (instancetype)actionWithTitle:(NSString *)title action:(void(^)())action;
//
//@end

