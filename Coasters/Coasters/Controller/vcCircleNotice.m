//
//      ┏┛ ┻━━━━━┛ ┻┓
//      ┃　　　　　　 ┃
//      ┃　　　━　　　┃
//      ┃　┳┛　  ┗┳　┃
//      ┃　　　　　　 ┃
//      ┃　　　┻　　　┃
//      ┃　　　　　　 ┃
//      ┗━┓　　　┏━━━┛
//        ┃　　　┃   神兽保佑
//        ┃　　　┃   代码无BUG！
//        ┃　　　┗━━━━━━━━━┓
//        ┃　　　　　　　    ┣┓
//        ┃　　　　         ┏┛
//        ┗━┓ ┓ ┏━━━┳ ┓ ┏━┛
//          ┃ ┫ ┫   ┃ ┫ ┫
//          ┗━┻━┛   ┗━┻━┛
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcCircleNotice.h"
#import "NSString+Verify.h"

#pragma mark - 宏命令

@interface vcCircleNotice () <UITextViewDelegate>
{
    __weak IBOutlet UIImageView *imvLogo;
    __weak IBOutlet UILabel *lblName;
    __weak IBOutlet UILabel *lblDateTime;
    __weak IBOutlet UITextView *txvNotice;
    __weak IBOutlet NSLayoutConstraint *viewMainHeight;
    __weak IBOutlet UIView *line;
    
    __weak IBOutlet UILabel *lblPlaceholder;
    __weak IBOutlet NSLayoutConstraint *txvTop;
    
    NSString *newNotice;
}

@end

@implementation vcCircleNotice

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"圈子公告"];
    
    
    [self initData];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    // 这里移除观察者
    NSLog(@"vcCircleNotice销毁了");
}

-(void)rightButtonClick
{
    [txvNotice resignFirstResponder];
    if (!newNotice.length) {
        return;
    }
    
    if ([NSString isHaveEmoji:newNotice]) {
        LMBShow(@"包含了不能识别的字符");
        return;
    }
    
    __block vcCircleNotice *blockSelf = self;
    RequestCheckAfter(
          [net updateGroupNotice:blockSelf.userInfo.access
                        group_id:blockSelf.group.group_id
                    group_notice:blockSelf->newNotice];,
          [blockSelf dataSuccessBack_updateGroupNotice:dic];);
}


// 初始化数据
- (void)initData
{
    
}

// 初始化布局控件
- (void)initView
{
    viewMainHeight.constant = ScreenHeight - NavBarHeight - 44;
    txvNotice.text = newNotice = _group.group_notice;
    lblPlaceholder.text  = newNotice.length ? @"": kString(@"这个圈主有点懒,什么都没留下.");
    
    
    // 当我是群主，并且有字的时候
    
    if([_group.is_admin boolValue] && ![_group.group_notice length])
    {
        [self initRightButton:@"save" text:nil];
        txvNotice.editable = YES;
        txvNotice.delegate = self;
        
        txvTop.constant = - 110;
        imvLogo.hidden = lblName.hidden = lblDateTime.hidden = line.hidden =  YES;
    }else
    {
        if ([_group.is_admin boolValue]) {
            txvNotice.editable = YES;
            [self initRightButton:@"save" text:nil];
            txvNotice.delegate = self;
        }
        
        imvLogo.layer.cornerRadius = 40;
        imvLogo.layer.masksToBounds = YES;
        NSLog(@"%@", _group.admin_user_nick_name);
        [imvLogo sd_setImageWithURL:[NSURL URLWithString:_group.admin_user_pic_url] placeholderImage:DefaultLogo_Gender([_group.admin_user_gender boolValue])];
        
        lblName.text = _group.admin_user_nick_name;
        lblDateTime.text = [[NSDate dateWithTimeIntervalSince1970:[_group.group_notice_time longLongValue] / 1000] toString:@"YYYY-MM-dd HH:mm"];
    }
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
#pragma mark 1 target-action                    普通

#pragma mark 2 delegate dataSource protocol     代理协议

#pragma mark UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView
{
    newNotice =  textView.text;
    if (newNotice.length == 0) {
        lblPlaceholder.text = kString(@"请输入你的宝贵意见");
    }else{
        lblPlaceholder.text = @"";
    }
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    if (textView.text.length > 100) {
        textView.text = [textView.text substringToIndex:100];
    }
}


#pragma mark - ------------------------------------- 私有方法

- (void)beginText
{
    self.modalPresentationCapturesStatusBarAppearance = NO;
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    self.extendedLayoutIncludesOpaqueBars = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txvNotice resignFirstResponder];
}

-(void)dataSuccessBack_updateGroupNotice:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        _group.group_notice = newNotice;  //  1465719703598
        _group.update_time = @([dic[@"update_time"] longLongValue]);
        
        DBSave;
        LMBShow(@"更新成功");
        if (self.editOKBlock) {
            _editOKBlock(_group);
        }
        __strong vcCircleNotice *blockSelf = self;
        NextWaitInMainAfter([blockSelf back];, 1);
    }
    else
    {
        NSLog(@"---------- 出错了");
    }
}

#pragma mark - ------------------------------------- 属性实现

#pragma mark -





































@end
