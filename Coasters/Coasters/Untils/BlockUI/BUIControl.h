#import <UIKit/UIKit.h>

@interface UIControl (BUIControl)

- (void)handleControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block;
- (void)removeHandlerForEvent:(UIControlEvents)event;

@end
