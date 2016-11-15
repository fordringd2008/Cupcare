//
//  vcNewBackPassword.m
//  Coasters
//
//  Created by 丁付德 on 16/1/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcNewBackPassword.h"
#import "HTAutocompleteManager.h"
#import "vcBase+Share.h"
#import "SectionsViewController.h"
#import "YJLocalCountryData.h"
#import "vcBase+PostSMS.h"
#import "NSString+Verify.h"
#import <TPKeyboardAvoidingScrollView.h>

@interface vcNewBackPassword () < SecondViewControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate>
{
    BOOL                        isLeftFrame;               // 是否是左布局
    BOOL                        isLeft;                    // 要改动的布局 是否是左布局
    UIView *                    viewLoginByThird;
    NSMutableArray*             _areaArray;
    NSString *                  countryName;               // 选中的国家名字
    NSString *                  countryCode;               // 选中的国家 电话 前缀
    NSTimer*                    timerCountdown;            // 倒计时
    NSDictionary *              dicDCountryCode;           // 国家简称与区号的键值对
    NSDictionary *              dicDCountryCodeTurn;       // 上面的键值对翻转
    NSString *                  acc;
    CGFloat                     moved;                      // 向上移动的距离
}

@property (weak, nonatomic) IBOutlet UIButton *         btnLoginTitleLeft;
@property (weak, nonatomic) IBOutlet UIButton *         btnLoginTitleRight;
@property (weak, nonatomic) IBOutlet UIView *           lineLeft;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrContent;
@property (weak, nonatomic) IBOutlet  UIButton *        btnSubmit;
@property (weak, nonatomic) IBOutlet UIView *           lineRight;
@property (weak, nonatomic) IBOutlet UILabel *          lblPrompt;


@property (strong, nonatomic)  UIButton *               btnSelectArea;
@property (strong, nonatomic)  UIButton *               btnPostSMS;
@property (strong, nonatomic)  UITextField *            txfPhoneNumber;
@property (strong, nonatomic)  UITextField *            txfMessage;
@property (strong, nonatomic)  UITextField *            txfPhonePassWord;
@property (strong, nonatomic)  UITextField *            txfPhonePassWordAgain;
@property (strong, nonatomic)  HTAutocompleteTextField *txfEmail;
@property (strong, nonatomic)  UILabel *                lblPhoneCode;
@property (strong, nonatomic)  UIView *                 viewRight;
@property (strong, nonatomic)  UITextField *            txfCountry;


@end

@implementation vcNewBackPassword

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    [self initLeftButton:nil text:@"找回密码"];
    
    [self initData];
    [self initView];
}



-(void)dealloc
{
    NSLog(@"vcNewBackPassword 被销毁了");
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self viewMove:NO];  // 让 Offset 生效
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
    [self setTheLocalAreaCode];
}

-(void)initView
{
    self.view.backgroundColor = RGB(238, 240, 241);
    self.scrContent.bounces = NO;
    self.scrContent.pagingEnabled = YES;
    self.scrContent.showsHorizontalScrollIndicator = NO;
    self.scrContent.scrollEnabled = NO;
    self.scrContent.contentSize =  CGSizeMake(ScreenWidth * 2, 210);
    UIButton *btnBig = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth * 2, self.scrContent.bounds.size.height)];
    btnBig.tag = 99;
    [btnBig addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrContent addSubview:btnBig];
    
    UIFont *font = [UIFont systemFontOfSize:14];
    
    UIView *viewLeft1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft1.userInteractionEnabled = NO;
    UIView *viewLeft2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft2.userInteractionEnabled = NO;
    UIView *viewLeft3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft3.userInteractionEnabled = NO;
    UIView *viewLeft4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    viewLeft4.userInteractionEnabled = NO;
    UIView *viewLeft5 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    viewLeft5.userInteractionEnabled = NO;
    UIView *viewLeft6 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft6.userInteractionEnabled = NO;
    UIView *viewLeft7 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft7.userInteractionEnabled = NO;
    UIView *viewLeft8 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft7.userInteractionEnabled = NO;
    self.viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    
    self.txfEmail = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 15, ScreenWidth - 40, 40)];
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    self.txfEmail.autocompleteType = HTAutocompleteTypeEmail;
    self.txfEmail.keyboardType = UIKeyboardTypeEmailAddress;
    self.txfEmail.tag = 1;
    self.txfEmail.delegate = self;
    self.txfEmail.leftView = viewLeft1;
    self.txfEmail.leftViewMode = UITextFieldViewModeAlways;
    self.txfEmail.placeholder = kString(@"邮箱");
    Border(self.txfEmail, DLightGray);
    self.txfEmail.layer.cornerRadius = 5;
    self.txfEmail.layer.masksToBounds = YES;
    self.txfEmail.backgroundColor = DWhite;
    self.txfEmail.font = font;
    [self.txfEmail setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfEmail.returnKeyType = UIReturnKeyDone;
    [self.scrContent addSubview:self.txfEmail];
    
    self.lblPrompt.text = kString(@"*请到您注册的邮箱查看邮件");
    
    self.txfCountry = [[UITextField alloc] initWithFrame:CGRectMake(20, 15, ScreenWidth - 40, 40)];
    self.txfCountry.tag = 4;
    self.txfCountry.enabled = NO;
    self.txfCountry.delegate = self;
    UIView *viewLeft4Left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 40)];
    viewLeft4Left.backgroundColor = self.view.backgroundColor;
    [viewLeft4 addSubview:viewLeft4Left];
    self.txfCountry.leftView = viewLeft4;
    self.txfCountry.leftViewMode = UITextFieldViewModeAlways;
    self.txfCountry.font = font;
    self.txfCountry.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfCountry setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfCountry.text = countryName;
    self.txfCountry.layer.cornerRadius = 5;
    self.txfCountry.layer.masksToBounds = YES;
    self.txfCountry.backgroundColor = DWhite;
    Border(self.txfCountry, DLightGray);
    [self.scrContent addSubview:self.txfCountry];
    
    self.btnSelectArea = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, 80, 40)];
    [self.btnSelectArea setTitle:kString(@"国家/地区") forState:UIControlStateNormal];
    self.btnSelectArea.titleLabel.font = font;
    [self.btnSelectArea setTitleColor:DBlack forState:UIControlStateNormal];
    self.btnSelectArea.tag = 3;
    [self.btnSelectArea addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSelectArea.layer.cornerRadius = 5;
    [self.btnSelectArea.layer setMasksToBounds:YES];
    [self.scrContent addSubview:self.btnSelectArea];
    
    self.lblPhoneCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    self.lblPhoneCode.textColor = DBlack;
    self.lblPhoneCode.font = font;
    self.lblPhoneCode.textAlignment = NSTextAlignmentCenter;
    self.lblPhoneCode.text = [NSString stringWithFormat:@"+%@", countryCode];
    [viewLeft5 addSubview:self.lblPhoneCode];
    
    self.txfPhoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, ScreenWidth - 40, 40)];
    self.txfPhoneNumber.tag = 4;
    self.txfPhoneNumber.delegate = self;
    self.txfPhoneNumber.leftView = viewLeft5;
    self.txfPhoneNumber.leftViewMode = UITextFieldViewModeAlways;
    self.txfPhoneNumber.placeholder = kString(@"手机号码");
    self.txfPhoneNumber.font = font;
    self.txfPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfPhoneNumber setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfPhoneNumber.layer.cornerRadius = 5;
    self.txfPhoneNumber.layer.masksToBounds = YES;
    self.txfPhoneNumber.backgroundColor = DWhite;
    Border(self.txfPhoneNumber, DLightGray);
    self.txfPhoneNumber.returnKeyType = UIReturnKeyDone;
    [self.scrContent addSubview:self.txfPhoneNumber];
    
    self.txfMessage = [[UITextField alloc] initWithFrame:CGRectMake(20, 120, ScreenWidth - 40, 40)];
    self.txfMessage.tag = 5;
    self.txfMessage.delegate = self;
    self.txfMessage.leftView = viewLeft6;
    self.txfMessage.rightView = self.viewRight;
    self.txfMessage.leftViewMode = UITextFieldViewModeAlways;
    self.txfMessage.rightViewMode = UITextFieldViewModeAlways;
    self.txfMessage.placeholder = kString(@"验证码");
    self.txfMessage.font = font;
    self.txfMessage.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfMessage setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfMessage.layer.cornerRadius = 5;
    self.txfMessage.layer.masksToBounds = YES;
    self.txfMessage.backgroundColor = DWhite;
    Border(self.txfMessage, DLightGray);
    self.txfMessage.returnKeyType = UIReturnKeyNext;
    [self.scrContent addSubview:self.txfMessage];
    
    self.btnPostSMS = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 140 , 120, 120, 40)];
    [self.btnPostSMS setTitle:kString(@"发送验证码") forState:UIControlStateNormal];
    self.btnPostSMS.titleLabel.font = font;
    [self.btnPostSMS setTitleColor:DWhite forState:UIControlStateNormal];
    self.btnPostSMS.tag = 4;
    [self.btnPostSMS addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPostSMS.layer.cornerRadius = 2;
    [self.btnPostSMS.layer setMasksToBounds:YES];
    [self.scrContent addSubview:self.btnPostSMS];
    
    self.txfPhonePassWord = [[UITextField alloc] initWithFrame:CGRectMake(20, 170, ScreenWidth - 40, 40)];
    self.txfPhonePassWord.tag = 6;
    self.txfPhonePassWord.delegate = self;
    self.txfPhonePassWord.leftView = viewLeft7;
    self.txfPhonePassWord.leftViewMode = UITextFieldViewModeAlways;
    self.txfPhonePassWord.placeholder = kString(@"密码(6-16位数字或字母)");
    self.txfPhonePassWord.font = font;
    [self.txfPhonePassWord setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfPhonePassWord.layer.cornerRadius = 5;
    self.txfPhonePassWord.layer.masksToBounds = YES;
    self.txfPhonePassWord.backgroundColor = DWhite;
    [self.txfPhonePassWord setSecureTextEntry:YES];
    Border(self.txfPhonePassWord, DLightGray);
    self.txfPhonePassWord.returnKeyType = UIReturnKeyNext;
    [self.scrContent addSubview:self.txfPhonePassWord];
    
    self.txfPhonePassWordAgain = [[UITextField alloc] initWithFrame:CGRectMake(20, 220, ScreenWidth - 40, 40)];
    self.txfPhonePassWordAgain.tag = 7;
    self.txfPhonePassWordAgain.delegate = self;
    self.txfPhonePassWordAgain.leftView = viewLeft8;
    self.txfPhonePassWordAgain.leftViewMode = UITextFieldViewModeAlways;
    self.txfPhonePassWordAgain.placeholder = kString(@"请再次输入密码");
    self.txfPhonePassWordAgain.font = font;
    [self.txfPhonePassWordAgain setValue:font forKeyPath:@"_placeholderLabel.font"];
    self.txfPhonePassWordAgain.layer.cornerRadius = 5;
    self.txfPhonePassWordAgain.layer.masksToBounds = YES;
    self.txfPhonePassWordAgain.backgroundColor = DWhite;
    [self.txfPhonePassWordAgain setSecureTextEntry:YES];
    Border(self.txfPhonePassWordAgain, DLightGray);
    self.txfPhonePassWordAgain.returnKeyType = UIReturnKeyDone;
    [self.scrContent addSubview:self.txfPhonePassWordAgain];
    
    self.txfPhoneNumber.clearButtonMode = self.txfMessage.clearButtonMode = self.txfPhonePassWord.clearButtonMode = self.txfPhonePassWordAgain.clearButtonMode = self.txfEmail.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    [self.btnLoginTitleLeft setTitle:kString(@"重置密码") forState:UIControlStateNormal];
    [self.btnLoginTitleRight setTitle:kString(@"邮箱找回") forState:UIControlStateNormal];
    
    [self.btnLoginTitleLeft setTitleColor:DidDisconnectColor forState:UIControlStateNormal];
    [self.btnLoginTitleLeft setTitleColor:DidConnectColor forState:UIControlStateDisabled];
    [self.btnLoginTitleRight setTitleColor:DidDisconnectColor forState:UIControlStateNormal];
    [self.btnLoginTitleRight setTitleColor:DidConnectColor forState:UIControlStateDisabled];
    
    [self.btnSubmit setTitle:kString(@"完成") forState:UIControlStateNormal];
    [self.btnSubmit setTitleColor:DWhite forState:UIControlStateNormal];
    [self.btnSubmit setTitleColor:DWhite forState:UIControlStateHighlighted];
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DButtonHighlight] forState:UIControlStateHighlighted];
    self.btnSubmit.layer.cornerRadius = 5;
    self.btnSubmit.layer.masksToBounds = YES;
    
    [self refreshBtnLoginTurn:YES];
    self.txfMessage.enabled = self.txfPhonePassWord.enabled = self.txfPhonePassWordAgain.enabled = NO;
    [self refreshbtnSubmit:YES];
    [self refreshBtnPostSMS:NO];
    self.lblPrompt.hidden = YES;
    
    isLeft = isLeftFrame = YES;
    [self checkbtnSubmit:nil passwordAgain:nil];
    [self.scrContent contentSizeToFit];
}

-(void)setTheLocalAreaCode
{
    NSLocale *locale = [NSLocale currentLocale];
    dicDCountryCode = [NSDictionary dictionaryWithObjectsAndKeys:@"972", @"IL",
                       @"93", @"AF", @"355", @"AL", @"213", @"DZ", @"1", @"AS",
                       @"376", @"AD", @"244", @"AO", @"1", @"AI", @"1", @"AG",
                       @"54", @"AR", @"374", @"AM", @"297", @"AW", @"61", @"AU",
                       @"43", @"AT", @"994", @"AZ", @"1", @"BS", @"973", @"BH",
                       @"880", @"BD", @"1", @"BB", @"375", @"BY", @"32", @"BE",
                       @"501", @"BZ", @"229", @"BJ", @"1", @"BM", @"975", @"BT",
                       @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                       @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                       @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                       @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                       @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                       @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                       @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                       @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                       @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                       @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                       @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                       @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                       @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                       @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                       @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                       @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                       @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                       @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                       @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                       @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                       @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                       @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                       @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                       @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                       @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                       @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                       @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                       @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                       @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                       @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                       @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                       @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                       @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                       @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                       @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                       @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                       @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                       @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                       @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                       @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                       @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                       @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                       @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                       @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                       @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                       @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                       @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                       @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                       @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                       @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                       @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                       @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963", @"SY",
                       @"886", @"TW", @"255", @"TZ", @"670", @"TL", @"58", @"VE",
                       @"84", @"VN", @"1", @"VG", @"1", @"VI", nil];
    
    NSString* tt = [locale objectForKey:NSLocaleCountryCode];
    NSString* defaultCode = [dicDCountryCode objectForKey:tt];
    NSString* defaultCountryName = [locale displayNameForKey:NSLocaleCountryCode value:tt];
    countryCode = defaultCode;
    countryName = defaultCountryName;
}




-(void)viewMove:(BOOL)isTop
{
    if (!IPhone4 && !IPhone5 ) return;
    [UIView transitionWithView:self.view duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        if (isTop)
            [self.view setFrame:CGRectMake(0, -moved + NavBarHeight , ScreenWidth, ScreenHeight)];
        else
            [self.view setFrame:CGRectMake(0,NavBarHeight, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
}

// 更新布局
-(void)viewMove
{
    if (isLeft == isLeftFrame) return;
    [self refreshBtnLoginTurn: isLeft];
    [UIView transitionWithView:self.lineLeft duration:0.35 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         [self.lineLeft setAlpha:!isLeft ? 0 : 1];
         [self.lineRight setAlpha:isLeft ? 0 : 1];
         
     } completion:^(BOOL finished) {
         isLeftFrame = isLeft;
         [self checkbtnSubmit:nil passwordAgain:nil];
         self.txfEmail.text = self.txfPhoneNumber.text = self.txfPhonePassWord.text = self.txfPhonePassWordAgain.text = self.txfMessage.text = @"";
         if (!isLeft) {
             self.txfMessage.enabled = NO;
             [self refreshBtnPostSMS:NO];
         }
     }];
    
    [self.scrContent setContentOffset:CGPointMake(isLeft ? 0 : ScreenWidth, 0) animated:YES];
}

-(BOOL)checkbtnPostSMS:(NSString *)text
{
    if(!dicDCountryCodeTurn)
        dicDCountryCodeTurn = [[NSDictionary alloc] initWithObjects:dicDCountryCode.allKeys forKeys:dicDCountryCode.allValues];
    BOOL isFix = [text ? text : self.txfPhoneNumber.text isPhoneAllWold:dicDCountryCodeTurn[countryCode]];
    // NSLog(@"----- > 电话号码 %@ 验证结果 : %hhd", text ? text : self.txfPhoneNumber.text, isFix);
    [self refreshBtnPostSMS:(isFix && !timerCountdown)];
    return isFix;
}

-(void)checkbtnSubmit:(NSString *)phone passwordAgain:(NSString *)passwordAgain
{
    NSString *strPhone = phone ? phone : self.txfPhoneNumber.text;
    NSString *strPasswordAgain = passwordAgain ? passwordAgain : self.txfPhonePassWordAgain.text;
    if (!isLeft)
    {
        if(self.txfEmail.text.length && [self.txfEmail.text isEmailType])  // 这里有问题
        {
            [self refreshbtnSubmit:YES];
        }else
        {
            [self refreshbtnSubmit:NO];
        }
    }else
    {
        if (self.txfMessage.text.length && [self checkbtnPostSMS:strPhone] && strPasswordAgain.length > 5 && [self.txfPhonePassWord.text isEqualToString:strPasswordAgain])
        {
            [self refreshbtnSubmit:YES];
        }else
        {
            [self refreshbtnSubmit:NO];
        }
    }
}

// 刷新切换按钮  1， 启用  2， 禁用
-(void)refreshBtnLoginTurn:(BOOL)isleft
{
    self.btnLoginTitleLeft.enabled = !isleft;
    self.btnLoginTitleRight.enabled = isleft;
}

// 刷新注册按钮  1， 启用 正常  2，启用 按下的状态  3， 禁用
-(void)refreshbtnSubmit:(BOOL)isEnable
{
    self.btnSubmit.enabled = isEnable;
    self.btnSubmit.backgroundColor = isEnable ? DidConnectColor : DLightGray;
}

// 刷新发送按钮  1， 启用 2， 禁用
-(void)refreshBtnPostSMS:(BOOL)isEnable
{
    self.btnPostSMS.enabled = isEnable;
    self.viewRight.backgroundColor = isEnable ? DidConnectColor : DLightGray;
}

-(void)refreshBtnPostSMSAfterPostSMS
{
    int inter = [self getSMSInterval];
//    NSLog(@"------ > %d", inter);
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
        [self.btnPostSMS setTitle:text forState:UIControlStateNormal];
        [self refreshBtnPostSMS:NO];
    }else
    {
        [self.btnPostSMS setTitle:kString(@"发送验证码") forState:UIControlStateNormal];
        [self refreshBtnPostSMS:YES];
        [timerCountdown DF_stop];
        timerCountdown = nil;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    //[self viewMove::NO];
}

- (IBAction)btnClick:(UIButton *)sender
{
    [self.view endEditing:YES];
    //[self viewMove:NO];
    // 1 切换左视图 2 切换右视图 3 弹出地区选择 4 发送验证码 5 提交 99 键盘缩进
    switch (sender.tag) {
        case 1:
        {
            isLeft = YES;
            [self viewMove];
        }
            break;
        case 2:
        {
            isLeft = NO;
            [self viewMove];
        }
            break;
        case 3:
        {
            SectionsViewController* country2 = [[SectionsViewController alloc] init];
            country2.delegate = self;
            
            //读取本地countryCode
            if (_areaArray.count == 0)
            {
                NSMutableArray *dataArray = [YJLocalCountryData localCountryDataArray];
                _areaArray = dataArray;
            }
            
            [country2 setAreaArray:_areaArray];
            [self presentViewController:country2 animated:YES completion:NULL];
        }
            break;
        case 4:
        {
            NSLog(@"发送验证码, 发送前需要验证此号码是否已经被注册");
            // 测试
            
            __weak vcNewBackPassword *blockSelf = self;
            MBShowAll;
            RequestCheckAfter(
                  [net authPhoneExist:self.txfPhoneNumber.text
                             areaCode:countryCode];,
                  [blockSelf dataSuccessBack_rauthPhoneExist:dic];);
//            
//            
//            NSLog(@"发送验证码");
//            __weak vcNewBackPassword *blockSelf = self;
//            MBShowAll;
//            HDDAF;
//            [self postSMS:self.txfPhoneNumber.text countrycode:countryCode block:^(bool isSuccess) {
//                MBHideInBlock;
//                blockSelf.txfMessage.enabled = YES;
//                blockSelf.txfPhonePassWord.enabled = YES;
//                if (isSuccess) {
//                    NSLog(@"验证码发送成功 %@", [NSThread currentThread]);
//                    LMBShowInBlock(@"短信已发送, 请注意查收");
//                    SetUserDefault(dateLastPostSMS, [NSDate date]);
//                    timerCountdown = [NSTimer scheduledTimerWithTimeInterval:1 target:blockSelf selector:@selector(refreshBtnPostSMSAfterPostSMS) userInfo:nil repeats:YES];
//                }else
//                {
//                    NSLog(@"验证码发送失败");
//                }
//            }];
//            [self refreshBtnPostSMS:YES];
        }
            break;
        case 6:
        {
            __block vcNewBackPassword *blockSelf = self;
            MBShowAll;
            HDDAF;
            if(isLeft)
            {
                RequestCheckAfter(
                      [net updatePasswordByPhone:blockSelf.txfPhoneNumber.text
                                        areaCode:countryCode
                                        authCode:blockSelf.txfMessage.text
                                        password:blockSelf.txfPhonePassWord.text];,
                      [blockSelf dataSuccessBack_updatePasswordByPhone:dic];)
            }else
            {
                RequestCheckAfter(
                  [net findPasswordByEmail:self.txfEmail.text];,
                  [blockSelf dataSuccessBack_findPasswordByEmail:dic];)
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)dataSuccessBack_rauthPhoneExist:(NSDictionary *)dic
{
       //  0 : 不存在  1： 存在
    if (CheckIsOK)// 0
    {
        MBHide;
        LMBShow(@"此号码不存在");
    }else
    {
        NSLog(@"手机号码没有注册，发送验证码");
        __block vcNewBackPassword *blockSelf = self;
        
        
        [self postSMS:self.txfPhoneNumber.text countrycode:countryCode block:^() {
            MBHideInBlock;
            blockSelf.txfMessage.enabled = YES;
            blockSelf.txfPhonePassWord.enabled = blockSelf.txfPhonePassWordAgain.enabled = YES;
            NSLog(@"验证码发送成功 %@", [NSThread currentThread]);
            LMBShowInBlock(@"短信已发送, 请注意查收");
            [blockSelf setSMSInterval];
            timerCountdown = [NSTimer scheduledTimerWithTimeInterval:1 target:blockSelf selector:@selector(refreshBtnPostSMSAfterPostSMS) userInfo:nil repeats:YES];
        }];
        [self refreshBtnPostSMS:YES];
    }
}


-(void)dataSuccessBack_updatePasswordByPhone:(NSDictionary *)dic
{
    MBHide;
    NSInteger statue = [dic[@"status"] integerValue];
    switch (statue) {
        case 2:
            MBHide;
            LMBShow(@"账号不存在");
            return;
            break;
        case 1001:
        {
            MBHide;
            if ([dic[@"auth_code_status"] intValue] == 467) {
                LMBShow(@"验证请求过于频繁");
            }
            else LMBShow(@"验证码输入有误");
            return;
        }
            break;
            
        default:
            break;
    }
    if (!CheckIsOK) return;
    LMBShow(@"密码重置成功");
    __block vcNewBackPassword *blockSelf = self;
    NextWaitInMainAfter(
         [blockSelf.delegate FillIn:blockSelf.txfPhoneNumber.text];
         [blockSelf back];, 1);
}

-(void)dataSuccessBack_findPasswordByEmail:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
            LMBShow(@"邮件已发送,请注意查收");
            __block vcNewBackPassword *blockSelf = self;
            NextWaitInMainAfter(
                     [blockSelf.delegate FillIn:blockSelf.txfEmail.text];
                     [blockSelf back];, 1);
    }else
    {
        LMBShow(@"账号不存在");
    }
}

#pragma mark SecondViewControllerDelegate
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    NSLog(@"name: %@ code:%@, pingyin:%@", data.countryName, data.areaCode, data.pinyinName);
    countryCode = data.areaCode;
    countryName = data.countryName;
    self.txfCountry.text = countryName;
    self.lblPhoneCode.text = [NSString stringWithFormat:@"+%@", countryCode];
    self.txfPhoneNumber.text = @"";
    [self checkbtnPostSMS:nil];
}

#pragma mark UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    if (!textField.enabled) return;
//    if ([textField isEqual:self.txfPhoneNumber])
//    {
//        if (IPhone4)        moved = 20;
//        else if(IPhone5)    moved = 0;
//        else                moved = 0;
//    }
//    else if ([textField isEqual:self.txfPhonePassWord])
//    {
//        if (IPhone4)        moved = 100;
//        else if(IPhone5)    moved = 10;
//        else                moved = 0;
//    }
//    else if([textField isEqual:self.txfPhonePassWordAgain])
//    {
//        if (IPhone4)        moved = 150;
//        else if(IPhone5)    moved = 60;
//        else                moved = 0;
//    }else if([textField isEqual:self.txfMessage])
//    {
//        if (IPhone4)        moved = 50;
//        else                moved = 0;
//    }else
//    {
//        moved = 0;
//    }
//    
//    //[self viewMove:YES];
//}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkbtnSubmit:nil passwordAgain:nil];
    if ([textField isEqual:self.txfPhoneNumber]) {
        [self checkbtnPostSMS:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.txfPhoneNumber])
    {
        if (!range.length) {
            [self checkbtnPostSMS:[NSString stringWithFormat:@"%@%@", textField.text, string]];
            [self checkbtnSubmit:[NSString stringWithFormat:@"%@%@", textField.text, string] passwordAgain:nil];
        }else
        {
            NSString *newText = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)];
            [self checkbtnPostSMS:newText];
            [self checkbtnSubmit:newText passwordAgain:nil];
        }
    } else if([textField isEqual:self.txfPhonePassWord] || [textField isEqual:self.txfPhonePassWordAgain])
    {
        if([textField isEqual:self.txfPhonePassWordAgain])
        {
            NSString *strpasswordAgain = range.length ? [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)] : [NSString stringWithFormat:@"%@%@", textField.text, string];
            [self checkbtnSubmit:nil passwordAgain:strpasswordAgain];
        }
        int MAX_CHARS = 16;
        NSMutableString *newtxt = [NSMutableString stringWithString:textField.text];
        [newtxt replaceCharactersInRange:range withString:string];
        return ([newtxt length] <= MAX_CHARS);
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_txfEmail]) {
        [_txfEmail resignFirstResponder];
    }else if ([textField isEqual:_txfMessage]){
        [_txfPhonePassWord becomeFirstResponder];
    }else if ([textField isEqual:_txfPhonePassWord]){
        [_txfPhonePassWordAgain becomeFirstResponder];
    }else if ([textField isEqual:_txfPhonePassWordAgain]){
        [_txfPhonePassWordAgain resignFirstResponder];
        //[self viewMove:NO];
    }
    return true;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
