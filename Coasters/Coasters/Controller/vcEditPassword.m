//
//  vcEditPassword.m
//  Coasters
//
//  Created by 丁付德 on 15/8/26.
//  Copyright (c) 2015年 dfd. All rights reserved.
////
//


#import "vcEditPassword.h"
#import "vcBase+PostSMS.h"
#import "NSString+Verify.h"

#define viewFirstDefaultFrame           CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(200), 100))
#define viewFirstChangeFrame            CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(200), 100) + 150)

@interface vcEditPassword ()<UITextFieldDelegate>
{
    CGFloat                     moved;                      // 向上移动的距离
    BOOL                        isDefault;                  // 是否是默认的
    NSTimer*                    timerCountdown;             // 倒计时
}



@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblTitlePassword;

@property (weak, nonatomic) IBOutlet UIView *viewFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;

@property (weak, nonatomic) IBOutlet UITextField *txfFirst;
@property (weak, nonatomic) IBOutlet UITextField *txfSecond;
@property (weak, nonatomic) IBOutlet UITextField *txfThird;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblEmailTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblPassTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txf1Top;

@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (weak, nonatomic) IBOutlet UILabel *lblPost;
@property (weak, nonatomic) IBOutlet UILabel *lblSave;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnPostWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *txfFirstRight;
@property (weak, nonatomic) IBOutlet UIImageView *imvDown;



- (IBAction)btnClick:(UIButton *)sender;

@end

@implementation vcEditPassword

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"修改密码"];
    
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (timerCountdown) {
        [timerCountdown DF_stop];
        timerCountdown = nil;
    }
}

-(void)initData
{
    
}

-(void)back
{
    [super back];
}

-(void)initView
{
    if ([self.userInfo.loginType intValue] == 0) {
        self.btnPostWidth.constant = 0;
        self.txfFirstRight.constant = 0;
    }else
    {
        self.txfFirst.enabled = self.txfSecond.enabled = self.txfThird.enabled = NO;
    }
    
    _viewMainHeight.constant = ScreenHeight;
    self.view.backgroundColor = _viewMain.backgroundColor = DLightGrayBlackGroundColor;
    _btnSave.layer.borderWidth = 1;
    _btnSave.layer.borderColor = RGB(31, 164, 184).CGColor;
    _btnSave.layer.cornerRadius = 5;
    [_btnSave.layer setMasksToBounds:YES];
    self.lblSave.text = kString(@"确定");
    self.lblPost.text = kString(@"发送验证码");
    
    _lblEmailTop.constant = _lineTop.constant = _lblPassTop.constant = _txf1Top.constant =(Bigger(RealHeight(100), 50) - 21) / 2.0;
    
    [_btnSave setBackgroundImage:[UIImage imageFromColor:RGB(23, 183, 251)] forState:UIControlStateNormal];
    [_btnSave setBackgroundImage:[UIImage imageFromColor:RGB(23, 163, 251)] forState:UIControlStateHighlighted];
    
    
    _btnPost.layer.borderWidth = 1;
    _btnPost.layer.borderColor = RGB(31, 164, 184).CGColor;
    _btnPost.layer.cornerRadius = 5;
    [_btnPost.layer setMasksToBounds:YES];
    [_btnPost setBackgroundImage:[UIImage imageFromColor:RGB(23, 183, 251)] forState:UIControlStateNormal];
    [_btnPost setBackgroundImage:[UIImage imageFromColor:RGB(23, 163, 251)] forState:UIControlStateHighlighted];
    [_btnPost setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateDisabled];
    
    
    _viewFirstHeight.constant = Bigger(RealHeight(200), 100);
    [_viewFirst.layer setMasksToBounds:YES];
    [_btnSave setAlpha:0];
    [self.lblSave setAlpha:0];
    isDefault = YES;
    
    _lblTitleEmail.text = [self.userInfo.loginType intValue] == 0 ? kString(@"邮箱") : kString(@"手机号码");
    _lblTitlePassword.text = kString(@"修改密码");
    
    _lblEmail.text = self.userInfo.account;
    _txfFirst.placeholder = [NSString stringWithFormat:@" %@", [self.userInfo.loginType intValue] == 0 ? kString(@"输入原密码") :kString(@"验证码")];
    _txfSecond.placeholder = [NSString stringWithFormat:@" %@", kString(@"输入新密码")];//kString(@"输入新密码");
    _txfThird.placeholder = [NSString stringWithFormat:@" %@", kString(@"确认新密码")];//kString(@"确认新密码");
    _txfFirst.layer.borderWidth = _txfSecond.layer.borderWidth = _txfThird.layer.borderWidth = 1;
    _txfFirst.layer.borderColor = _txfSecond.layer.borderColor = _txfThird.layer.borderColor = DLightGray.CGColor;
    _txfFirst.delegate = self;
    _txfSecond.delegate = self;
    _txfThird.delegate = self;
    
    [self.btnPost setTitleColor:DWhite forState:UIControlStateNormal];
    self.btnPost.tag = 4;
    [self.btnPost addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPost.layer.cornerRadius = 2;
    [self.btnPost.layer setMasksToBounds:YES];
    
    if ([self.userInfo.loginType intValue] == 1) {
        _txfFirst.keyboardType = UIKeyboardTypeNumberPad;
    }
}

-(void)resign
{
    [_txfFirst resignFirstResponder];
    [_txfFirst resignFirstResponder];
    [_txfThird resignFirstResponder];
    
    [self viewMove:NO];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    moved = 0;
    if(IPhone4){
        switch (textField.tag) {
            case 1:
                moved = 50;
                break;
            case 2:
                moved = 80;
                break;
            case 3:
                moved = 110;
                break;
        }
    } else if (IPhone5){
        if (textField.tag == 3) {
            moved = 20;
        }
    }
    
    [self viewMove:YES];
}


-(void)viewMove:(BOOL)isTop
{
    [UIView transitionWithView:self.view duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (isTop)
            [_viewFirst setFrame:CGRectMake(0, 20 - moved, ScreenWidth, Bigger(RealHeight(200), 100) + 150)];
        else
            [_viewFirst setFrame:CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(200), 100) + 150)];
    } completion:^(BOOL finished) {
        if (!isTop) {
            [self.view endEditing:YES];
        }
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)btnClick:(UIButton *)sender
{
    [self resign];
    switch (sender.tag)
    {
        case 1:
            [self moveHide];
            break;
        case 2:
            [self save];
            break;
        case 4:
        {
            MBShowAll;
            self.txfFirst.enabled = self.txfSecond.enabled = self.txfThird.enabled = NO;
            __block vcEditPassword *blockSelf = self;
            [self postSMS:self.userInfo.account countrycode:self.userInfo.area_code block:^() {
                MBHideInBlock;
                NSLog(@"验证码发送成功");
                LMBShowInBlock(@"短信已发送, 请注意查收");
                self.txfFirst.enabled = self.txfSecond.enabled = self.txfThird.enabled = YES;
                [blockSelf setSMSInterval];
                timerCountdown = [NSTimer scheduledTimerWithTimeInterval:1 target:blockSelf selector:@selector(refreshBtnPostSMSAfterPostSMS) userInfo:nil repeats:YES];
            }];
        }
            break;
    }
}

-(void)refreshBtnPostSMSAfterPostSMS
{
    int inter = [self getSMSInterval];
    if (inter > 0)
    {
        NSString *text;
        if([DFD getLanguage] == 1)
        {
            text = [NSString stringWithFormat:@"%d秒重新发送", inter];
        }else
        {
            text = [NSString stringWithFormat:@"Last %ds", inter];
        }
        self.lblPost.text = text;
        [self refreshBtnPostSMS:NO];
    }else
    {
        self.lblPost.text = kString(@"发送验证码");
        [self refreshBtnPostSMS:YES];
        [timerCountdown DF_stop];
        timerCountdown = nil;
    }
}

// 刷新发送按钮  1， 启用 2， 禁用
-(void)refreshBtnPostSMS:(BOOL)isEnable
{
    self.btnPost.enabled = isEnable;
}

-(void)moveHide
{
    [UIView transitionWithView:self.viewFirst duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (isDefault)
        {
            [self.viewFirst setFrame:CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(200), 100) + 150)];
            [self.btnSave setAlpha:1];
            [self.lblSave setAlpha:1];
            [self.imvDown setAlpha:0];
            self.btnSave.enabled = YES;
        }
        else
        {
            [self.btnSave setAlpha:0];
            [self.lblSave setAlpha:0];
            [self.imvDown setAlpha:1];
            self.btnSave.enabled = NO;
            [self.viewFirst setFrame:CGRectMake(0, 20, ScreenWidth, Bigger(RealHeight(200), 100))];
        }
        
    } completion:^(BOOL finished) {
        isDefault = !isDefault;
        _txfFirst.text = _txfSecond.text = _txfThird.text = @"";
    }];
}

-(void)save
{
    NSString *oldPd = _txfFirst.text;
    NSString *newPd = _txfSecond.text;
    NSString *newAgainPd = _txfThird.text;
    
    if ([self.userInfo.loginType intValue] == 0)
    {
        if (!oldPd.length)
        {
            LMBShow(@"请输入原始密码");
            return;
        }
        if (![oldPd isEqualToString:self.userInfo.password])
        {
            LMBShow(@"密码输入错误");
            return;
        }
    }else if ([self.userInfo.loginType intValue] == 1) {
        if (oldPd.length != 4){
            LMBShow(@"请输入有效的验证码");
            return;
        }
    }
    
    if (![newPd isEqualToString:newAgainPd])
    {
        LMBShow(@"两次输入的密码不一致");
        return;
    }
    
    if ([NSString isHaveEmoji:newPd])
    {
        LMBShow(@"包含了不能识别的字符");
        return;
    }
    
    if (![self.userInfo.loginType intValue])
    {
        __block vcEditPassword *blockSelf = self;
        RequestCheckAfter(
                          [net updatePasswordByEmail:blockSelf.userInfo.account old:blockSelf.userInfo.password new:newPd];,
                          [blockSelf dataSuccessBack_updatePasswordByEmail:dic];);
    }else
    {
        __block vcEditPassword *blockSelf = self;
        RequestCheckAfter(
              [net updatePasswordByPhone:blockSelf.userInfo.account areaCode:blockSelf.userInfo.area_code authCode:blockSelf.txfFirst.text password:blockSelf.txfSecond.text];,
              [blockSelf dataSuccessBack_updatePasswordByEmail:dic];);
    }
}

-(void)dataSuccessBack_updatePasswordByEmail:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        UserInfo *user = [UserInfo findFirstByAttribute:@"access" withValue:self.userInfo.access inContext:DBefaultContext];
        user.password = _txfSecond.text;
        user.token = dic[@"token"];
        DBSave;
        self.userInfo = myUserInfo;
        DBSave;
        [self moveHide];
        LMBShow(@"修改成功");
        _txfFirst.text = _txfSecond.text = _txfThird.text = @"";
    }
    else
    {
        LMBShow(@"密码不正确");
    }
}








@end
