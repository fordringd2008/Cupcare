//
//  LXEmojiKeyboardView.h
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXEmojiKeyboardView : UIView<UIInputViewAudioFeedback>

@property (nonatomic,strong) UITextView *textView;
@property (assign, nonatomic) NSInteger length;
@property (assign, nonatomic) NSInteger bottomEdgeSpacing;
@property (assign, nonatomic) NSInteger horizontalEdgeSpacing;
@property (nonatomic,strong) NSArray *arrData;
@property (strong, nonatomic) UITableView * tabView;


+ (id) keybaordViewWithFrame:(CGRect)frame;

/*! 刷新界面 */
- (void) layoutAllButtons;

@end
