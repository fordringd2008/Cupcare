//
//  LXEmojiKeyboardView.m
//  LXEmojiKeyboard
//
//  Created by 李新星 on 15/11/18.
//  Copyright © 2015年 xx-li. All rights reserved.
//

#import "LXEmojiKeyboardView.h"

@interface LXEmojiKeyboardView ()<UITableViewDelegate, UITableViewDataSource> {
    NSInteger _pageCount;
    CGSize _oldLayoutSize;
    NSArray *arrData;
}

@property (strong, nonatomic, readonly) NSArray     * allEmojis;
@property (strong, nonatomic, readonly) NSArray     * allButtons;
@property (strong, nonatomic, readonly) NSBundle    * assetBundle;


@end

@implementation LXEmojiKeyboardView


@synthesize allEmojis = _allEmojis, allButtons = _allButtons, arrData;

+ (id) keybaordViewWithFrame:(CGRect)frame {
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomEdgeSpacing = 30;
        self.horizontalEdgeSpacing = 10;
        
        UITableView *tabView = [[UITableView alloc] init];
        tabView.dataSource = self;
        tabView.delegate = self;
        tabView.rowHeight = 40;
        tabView.showsVerticalScrollIndicator = NO;
        tabView.scrollEnabled = NO;
        tabView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        [self addSubview:tabView];
        tabView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraints:@[
                               [NSLayoutConstraint constraintWithItem:tabView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:tabView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:tabView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                               [NSLayoutConstraint constraintWithItem:tabView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0]
                               ]];
        _tabView = tabView;
    }
    return self;
}

#pragma mark - private Method
#pragma mark Text Operation
- (BOOL)textInputShouldReplaceTextInRange:(UITextRange *)range replacementText:(NSString *)replacementText {
    
    BOOL shouldChange = YES;
    
    NSInteger startOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.start];
    NSInteger endOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.end];
    NSRange replacementRange = NSMakeRange(startOffset, endOffset - startOffset);
    
    if ([self.textView isKindOfClass:UITextView.class]) {
        UITextView *textView = (UITextView *)self.textView;
        if ([textView.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]){
            shouldChange = [textView.delegate textView:textView shouldChangeTextInRange:replacementRange replacementText:replacementText];
        }
    }
    
    if ([self.textView isKindOfClass:UITextField.class]) {
        UITextField *textField = (UITextField *)self.textView;
        if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
            shouldChange = [textField.delegate textField:textField shouldChangeCharactersInRange:replacementRange replacementString:replacementText];
        }
    }
    
    return shouldChange;
}

- (void)replaceTextInRange:(UITextRange *)range withText:(NSString *)text {
    if (range && [self textInputShouldReplaceTextInRange:range replacementText:text]) {
        [self.textView replaceRange:range withText:text];
        
        NSInteger number = [self.textView.text length];
        if (number > _length) {
            self.textView.text = [self.textView.text substringToIndex:_length];
        }
    }
    
}

//输入文本
- (void)inputText:(NSString *)text {
    [self replaceTextInRange:self.textView.selectedTextRange withText:text];

}

- (BOOL)stringIsEmoji:(NSString *)str {
    return [self.allEmojis containsObject:str];
}

- (void)setTextView:(UITextView *)textView {

    if (textView == nil) {
        if ([_textView isKindOfClass:[UITextView class]]) {
            [(UITextView *)_textView setInputView:nil];
        }
        else if ([_textView isKindOfClass:[UITextField class]]) {
            [(UITextField *)_textView setInputView:nil];
        }
    }
    else {
        if ([textView isKindOfClass:[UITextView class]]) {
            [(UITextView *)textView setInputView:self];
        }
        else if ([textView isKindOfClass:[UITextField class]]) {
            [(UITextField *)textView setInputView:self];
        }
    }
    _textView = textView;
}

#pragma mark - Layout UI
//所有的按钮布局
- (void) layoutAllButtons {
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Size有变化，则重新布局
    if (!CGSizeEqualToSize(_oldLayoutSize, self.bounds.size)) {
        [self layoutAllButtons];
    }
}


#pragma mark protocol UIInputViewAudioFeedback
- (BOOL)enableInputClicksWhenVisible {
    return YES;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = arrData[indexPath.row];
    cell.backgroundColor = self.tabView.backgroundColor;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[UIDevice currentDevice] playInputClick];
    NSString * title = arrData[indexPath.row];
    [self inputText:title];
}


@end
