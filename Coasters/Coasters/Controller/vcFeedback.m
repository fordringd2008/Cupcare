//
//  vcFeedback.m
//  Coasters
//
//  Created by 丁付德 on 15/9/5.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFeedback.h"
#import "NSString+Verify.h"

@interface vcFeedback()<UITextViewDelegate>
{
    NSString *content;
}

@property (weak, nonatomic) IBOutlet UITextView *txv;
@property (weak, nonatomic) IBOutlet UILabel    *lblPlaceholder;
@property (weak, nonatomic) IBOutlet UILabel    *lblNumber;

@end

@implementation vcFeedback

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"意见反馈"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    [self initRightButton:@"save" text:nil];

    self.view.backgroundColor = DLightGrayBlackGroundColor;
    self.txv.delegate         = self;
    self.lblPlaceholder.text  = kString(@"请输入你的宝贵意见");

    [self beginText];
}

-(void)rightButtonClick
{
    [self.txv resignFirstResponder];
    if (!content || !content.length) {
        return;
    }
    
    if ([NSString isHaveEmoji:content]) {
        LMBShow(@"包含了不能识别的字符");
        return;
    }
    
    __block vcFeedback *blockSelf = self;
    RequestCheckAfter(
          [net updateFeedback:blockSelf.userInfo.access content:content];,
          [blockSelf dataSuccessBack_updateFeedback:dic];);
}


#pragma mark UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    content =  textView.text;
    [self refreshNumber];
}


- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (textView.text.length > 200) {
        textView.text = [textView.text substringToIndex:200];
    }
}

- (void)beginText
{
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txv resignFirstResponder];
}

-(void)dataSuccessBack_updateFeedback:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        LMBShow(@"提交成功");
         __block vcFeedback *blockSelf = self;
        NextWaitInMainAfter([blockSelf back];, 1);
    }
    else
    {
        NSLog(@"---------- 出错了");
    }
}


-(void)refreshNumber
{
    self.lblNumber.text = [NSString stringWithFormat:@"%lu/200", (unsigned long)(content.length > 200 ? 200 : content.length)];
    if (content.length == 0) {
        self.lblPlaceholder.text = kString(@"请输入你的宝贵意见");
    }else{
        self.lblPlaceholder.text = @"";
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}









@end
