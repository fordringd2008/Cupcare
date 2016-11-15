//
//  vcNewLogin.m
//  Coasters
//
//  Created by 丁付德 on 15/12/28.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcNewLogin.h"
#import "HTAutocompleteManager.h"
#import "vcBase+Share.h"
#import "SectionsViewController.h"
#import "YJLocalCountryData.h"
#import "vcBase+PostSMS.h"
#import "vcNewBackPassword.h"
#import "vcNewRegisiter.h"
#import "vcNewPerfectInfo.h"
#import "NSString+Verify.h"

@interface vcNewLogin () < SecondViewControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, vcNewBackPasswordDelegate, vcNewRegisiterDelegate>
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
    NSArray *                   arrDataFromThird;          // 第三方登陆返回的信息数组
}


@property (weak, nonatomic) IBOutlet UIButton *         btnLoginTitleLeft;
@property (weak, nonatomic) IBOutlet UIButton *         btnLoginTitleRight;
@property (weak, nonatomic) IBOutlet UIView *           lineLeft;
@property (weak, nonatomic) IBOutlet UIView *lineRight;

@property (weak, nonatomic) IBOutlet UIScrollView *     scrContent;

@property (weak, nonatomic) IBOutlet  UIButton *        btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *          lblLoginThird;



@property (strong, nonatomic) UIButton *                btnForgot;
@property (strong, nonatomic) UIButton *                btnSelectArea;
@property (strong, nonatomic) UIButton *                btnPostSMS;
@property (strong, nonatomic) HTAutocompleteTextField * txfAccount;
@property (strong, nonatomic) UITextField *             txfPassword;
@property (strong, nonatomic) UITextField *             txfPhoneNumber;
@property (strong, nonatomic) UITextField *             txfMessage;
@property (strong, nonatomic) UITextField *             txfCountry;
@property (strong, nonatomic) UILabel *                 lblPhoneCode;
@property (strong, nonatomic) UIView *                  viewRight;

@end

@implementation vcNewLogin

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    [self setNavTitle:self title:@"登录"];
    [self initRightButton:nil text:@"注册"];

    [self initData];
    [self initView];
}

-(void)dealloc
{
    NSLog(@"vcNewLogin销毁了");
}

-(void)initView
{
    self.view.backgroundColor = RGB(238, 240, 241);
    self.scrContent.bounces = NO;
    self.scrContent.pagingEnabled = YES;
    self.scrContent.showsHorizontalScrollIndicator = NO;
    self.scrContent.scrollEnabled = NO;
    self.scrContent.contentSize =  CGSizeMake(ScreenWidth * 2, 180);
    UIButton *btnBig = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth * 2, self.scrContent.bounds.size.height)];
    btnBig.tag = 99;
    [btnBig addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrContent addSubview:btnBig];
    
    UIView *viewLeft1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft1.userInteractionEnabled = NO;
    UIView *viewLeft2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    viewLeft2.userInteractionEnabled = NO;
    UIView *viewLeft3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    viewLeft3.userInteractionEnabled = NO;
    UIView *viewLeft4 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    viewLeft4.userInteractionEnabled = NO;
    UIView *viewLeft5 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
    self.viewRight = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];

    self.txfAccount = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(20, 15, ScreenWidth - 40, 40)];
    [HTAutocompleteTextField setDefaultAutocompleteDataSource:[HTAutocompleteManager sharedManager]];
    self.txfAccount.autocompleteType = HTAutocompleteTypeEmail;
    self.txfAccount.keyboardType = UIKeyboardTypeEmailAddress;
    self.txfAccount.tag = 1;
    self.txfAccount.delegate = self;
    self.txfAccount.leftView = viewLeft1;
    self.txfAccount.leftViewMode = UITextFieldViewModeAlways;
    self.txfAccount.placeholder = kString(@"手机号/邮箱");
    Border(self.txfAccount, DLightGray);
    self.txfAccount.layer.cornerRadius = 5;
    self.txfAccount.layer.masksToBounds = YES;
    self.txfAccount.backgroundColor = DWhite;
    self.txfAccount.font = [UIFont systemFontOfSize:14];
    [self.txfAccount setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.txfAccount.returnKeyType = UIReturnKeyNext;
    [self.scrContent addSubview:self.txfAccount];
    
    self.txfPassword = [[UITextField alloc] initWithFrame:CGRectMake(20, 70, ScreenWidth - 40, 40)];
    self.txfPassword.tag = 2;
    self.txfPassword.delegate = self;
    self.txfPassword.leftView = viewLeft2;
    self.txfPassword.leftViewMode = UITextFieldViewModeAlways;
    self.txfPassword.placeholder = kString(@"密码");
    Border(self.txfPassword, DLightGray);
    self.txfPassword.layer.cornerRadius = 5;
    self.txfPassword.layer.masksToBounds = YES;
    [self.txfPassword setSecureTextEntry:YES];
    self.txfPassword.backgroundColor = DWhite;
    self.txfPassword.font = [UIFont systemFontOfSize:14];
    [self.txfPassword setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.txfPassword.returnKeyType = UIReturnKeyGo;
    [self.scrContent addSubview:self.txfPassword];
    
    self.txfCountry = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 15, ScreenWidth - 40, 40)];
    self.txfCountry.tag = 3;
    self.txfCountry.enabled = NO;
    self.txfCountry.delegate = self;
    UIView *viewLeft3Left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 40)];
    viewLeft3Left.backgroundColor = self.view.backgroundColor;
    [viewLeft3 addSubview:viewLeft3Left];
    self.txfCountry.leftView = viewLeft3;
    self.txfCountry.leftViewMode = UITextFieldViewModeAlways;
    self.txfCountry.font = [UIFont systemFontOfSize:14];
    self.txfCountry.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfCountry setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.txfCountry.text = countryName;
    self.txfCountry.layer.cornerRadius = 5;
    self.txfCountry.layer.masksToBounds = YES;
    self.txfCountry.backgroundColor = DWhite;
    Border(self.txfCountry, DLightGray);
    [self.scrContent addSubview:self.txfCountry];
    
    self.btnSelectArea = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 15, 80, 40)];
    [self.btnSelectArea setTitle:kString(@"国家/地区") forState:UIControlStateNormal];
    self.btnSelectArea.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.btnSelectArea setTitleColor:DBlack forState:UIControlStateNormal];
    self.btnSelectArea.tag = 3;
    [self.btnSelectArea addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSelectArea.layer.cornerRadius = 5;
    [self.btnSelectArea.layer setMasksToBounds:YES];
    [self.scrContent addSubview:self.btnSelectArea];
    
    self.lblPhoneCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    self.lblPhoneCode.textColor = DBlack;
    self.lblPhoneCode.font = [UIFont systemFontOfSize:14];
    self.lblPhoneCode.textAlignment = NSTextAlignmentCenter;
    self.lblPhoneCode.text = [NSString stringWithFormat:@"+%@", countryCode];
    [viewLeft4 addSubview:self.lblPhoneCode];
    
    self.txfPhoneNumber = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 70, ScreenWidth - 40, 40)];
    self.txfPhoneNumber.tag = 4;
    self.txfPhoneNumber.delegate = self;
    self.txfPhoneNumber.leftView = viewLeft4;
    self.txfPhoneNumber.leftViewMode = UITextFieldViewModeAlways;
    self.txfPhoneNumber.placeholder = kString(@"手机号码");
    self.txfPhoneNumber.font = [UIFont systemFontOfSize:14];
    self.txfPhoneNumber.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfPhoneNumber setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.txfPhoneNumber.layer.cornerRadius = 5;
    self.txfPhoneNumber.layer.masksToBounds = YES;
    self.txfPhoneNumber.backgroundColor = DWhite;
    Border(self.txfPhoneNumber, DLightGray);
    [self.scrContent addSubview:self.txfPhoneNumber];
    
    self.txfMessage = [[UITextField alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 120, ScreenWidth - 40, 40)];
    self.txfMessage.tag = 5;
    self.txfMessage.delegate = self;
    self.txfMessage.leftView = viewLeft5;
    self.txfMessage.rightView = self.viewRight;
    self.txfMessage.leftViewMode = UITextFieldViewModeAlways;
    self.txfMessage.rightViewMode = UITextFieldViewModeAlways;
    self.txfMessage.placeholder = kString(@"验证码");
    self.txfMessage.font = [UIFont systemFontOfSize:14];
    self.txfMessage.keyboardType = UIKeyboardTypeNumberPad;
    [self.txfMessage setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    self.txfMessage.layer.cornerRadius = 5;
    self.txfMessage.layer.masksToBounds = YES;
    self.txfMessage.backgroundColor = DWhite;
    Border(self.txfMessage, DLightGray);
    [self.scrContent addSubview:self.txfMessage];

    self.btnPostSMS = [[UIButton alloc] initWithFrame:CGRectMake(2 * ScreenWidth - 140 , 120, 120, 40)];
    [self.btnPostSMS setTitle:kString(@"发送验证码") forState:UIControlStateNormal];
    self.btnPostSMS.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.btnPostSMS setTitleColor:DWhite forState:UIControlStateNormal];
    self.btnPostSMS.tag = 4;
    [self.btnPostSMS addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPostSMS.layer.cornerRadius = 2;
    [self.btnPostSMS.layer setMasksToBounds:YES];
    [self.scrContent addSubview:self.btnPostSMS];
    
    
    CGFloat btnForgotSWidth = [DFD getLanguage] == 1 ? 65 : 110;
    self.btnForgot = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 20 - btnForgotSWidth , 120, btnForgotSWidth, 30)];
//    Border(self.btnForgot, DRed);
    [self.btnForgot setTitle:kString(@"忘记密码?") forState:UIControlStateNormal];
    [self.btnForgot setTitleColor:DBlack forState:UIControlStateNormal];
    self.btnForgot.titleLabel.font = [UIFont systemFontOfSize:12];
    self.btnForgot.tag = 5;
    [self.btnForgot addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrContent addSubview:self.btnForgot];
    
    self.lblLoginThird.text = kString(@"第三方账号登陆");
    [self.btnLoginTitleLeft setTitle:kString(@"账号登录") forState:UIControlStateNormal];
    [self.btnLoginTitleRight setTitle:kString(@"短信验证码登录") forState:UIControlStateNormal];
    
    [self.btnLoginTitleLeft setTitleColor:DidDisconnectColor forState:UIControlStateNormal];
    [self.btnLoginTitleLeft setTitleColor:DidConnectColor forState:UIControlStateDisabled];
    [self.btnLoginTitleRight setTitleColor:DidDisconnectColor forState:UIControlStateNormal];
    [self.btnLoginTitleRight setTitleColor:DidConnectColor forState:UIControlStateDisabled];
    
    
    [self.btnLogin setTitle:kString(@"登录") forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:DWhite forState:UIControlStateNormal];
    [self.btnLogin setTitleColor:DWhite forState:UIControlStateHighlighted];
    [self.btnLogin setBackgroundImage:[UIImage imageFromColor:DButtonHighlight] forState:UIControlStateHighlighted];
    self.btnLogin.layer.cornerRadius = 5;
    self.btnLogin.layer.masksToBounds = YES;

    
    [self refreshBtnLoginTurn:YES];
    self.txfMessage.enabled = NO;
    [self refreshBtnLogin:YES];
    [self refreshBtnPostSMS:NO];
    
    isLeft = isLeftFrame = YES;
    [self checkBtnLogin:nil password:nil];
    [self initShareButton];
    
    
    self.txfAccount.clearButtonMode = self.txfMessage.clearButtonMode = self.txfPassword.clearButtonMode = self.txfPhoneNumber.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    // 小汤的账号
//    self.txfAccount.text = @"120809833@qq.com";
//    self.txfPassword.text = @"123456";
    
//    self.txfAccount.text = @"789@qq.com";
//    self.txfPassword.text = @"123456";
    
    
    
    
    //  短信验证登陆被去掉了  ~~~~~~~~~~
    self.btnLoginTitleLeft.hidden = self.btnLoginTitleRight.hidden = self.lineLeft.hidden = YES;
}

-(void)initRightButton:(NSString *)imgName text:(NSString *)text
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(rightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:kString(text) forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, [DFD getLanguage] == 1 ? 40 : 55, 22);
    [button setTitleColor:DWhite forState:UIControlStateNormal];
    [button setBackgroundColor:DClear];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    button.layer.borderColor = DWhite.CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}


-(void)rightButtonClick
{
    [self performSegueWithIdentifier:@"newlogin_newregister" sender:nil];
}

-(void)initData
{
//    [self setTheLocalAreaCode];
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 1 切换左视图 2 切换右视图 3 弹出地区选择 4 发送验证码 5 忘记密码  6 登陆  11,12,13,14第三方登陆  99 键盘缩进
- (IBAction)btnClick:(UIButton *)sender
{
    [self.view endEditing:YES];
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
            __block vcNewLogin *blockSelf = self;
            MBShowAll;
            [self postSMS:self.txfPhoneNumber.text countrycode:countryCode block:^() {
                MBHideInBlock;
                blockSelf.txfMessage.enabled = YES;
                [blockSelf refreshBtnPostSMSAfterPostSMS];
                NSLog(@"验证码发送成功 %@", [NSThread currentThread]);
                LMBShowInBlock(@"验证码已发送,请查收");
                SetUserDefault(dateLastPostSMS, DNow);
                blockSelf->timerCountdown = [NSTimer scheduledTimerWithTimeInterval:1 target:blockSelf selector:@selector(refreshBtnPostSMSAfterPostSMS) userInfo:nil repeats:YES];
            }];
            [self refreshBtnPostSMS:NO];
        }
            break;
        case 5:
        {
            [self performSegueWithIdentifier:@"newlogin_newbackpassword" sender:nil];
        }
            break;
        case 6:
        {
            __block vcNewLogin *blockSelf = self;
            MBShowAll;
            if (isLeft)
            {
                __block int typeInt = 0;
                if      ([self.txfAccount.text isEmailType]) typeInt = 1;
                else    typeInt = 2;
                
                RequestCheckAfter(
                      [net login:blockSelf.txfAccount.text
                            type:typeInt
                        password:blockSelf.txfPassword.text];,
                      [blockSelf dataSuccessBack_login:dic];);

            }
        }
            break;
        case 11:
        case 12:
        case 13:
        case 14:
        {
            __block vcNewLogin *blockSelf = self;
            __block int logType = (int)sender.tag - 10;
            MBShowAll;
            [self loginByThird:logType block:^(NSArray *arr)
            {
                NSLog(@"回调回来了");
                if (arr)
                {
                    arrDataFromThird = arr;
                    [blockSelf loginByThirdNext:logType];
                }else
                {
                    MBHideInBlock;
                }
            }];
        }
            break;
    }
}

-(void)loginByThirdNext:(int)typeID
{
    //  调用第三方登陆接口（后台服务器）， 返回后， 拉去个人信息，如果没有个人信息，跳转完善个人信心界面，如果有，跳转
    __block vcNewLogin *blockSelf = self;
    __block NSString  *thirdID = arrDataFromThird[0];
    RequestCheckAfter(
          [net loginByThird:thirdID
                       type:typeID];,
          [blockSelf dataSuccessBack_loginByThird:dic type:typeID];);
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
        self.txfAccount.text = self.txfPassword.text = self.txfPhoneNumber.text = self.txfMessage.text = @"";
        [self checkBtnLogin:nil password:nil];
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
    NSLog(@"----- > 电话号码 %@ 验证结果 : %@", text ? text : self.txfPhoneNumber.text, @(isFix));
    [self refreshBtnPostSMS:(isFix && !timerCountdown)];
    return isFix;
}


-(void)checkBtnLogin:(NSString *)account password:(NSString *)password
{
    NSString *strText = account ? account : self.txfAccount.text;
    NSString *strPassword = password ? password : self.txfPassword.text;
    
    if (isLeft)
    {
        if(strText.length > 0 && strPassword.length > 5 && strPassword.length <=16)
        {
            [self refreshBtnLogin:YES];
        }else
        {
            [self refreshBtnLogin:NO];
        }
    }else
    {
//        if (self.txfMessage.text.length && [self checkbtnPostSMS:(text ? text : self.txfPhoneNumber.text)])
//        {
//            [self refreshBtnLogin:YES];
//        }else
//        {
//            [self refreshBtnLogin:NO];
//        }
    }
}

// 刷新切换按钮  1， 启用  2， 禁用
-(void)refreshBtnLoginTurn:(BOOL)isleft
{
    self.btnLoginTitleLeft.enabled = !isleft;
    self.btnLoginTitleRight.enabled = isleft;
}


// 刷新登陆按钮  1， 启用 正常  2，启用 按下的状态  3， 禁用
-(void)refreshBtnLogin:(BOOL)isEnable
{
    self.btnLogin.enabled = isEnable;
    self.btnLogin.backgroundColor = isEnable ? DidConnectColor : DLightGray;
}

// 刷新发送按钮  1， 启用 2， 禁用
-(void)refreshBtnPostSMS:(BOOL)isEnable
{
    self.btnPostSMS.enabled = isEnable;
    self.viewRight.backgroundColor = isEnable ? DidConnectColor : DLightGray;
}

-(void)refreshBtnPostSMSAfterPostSMS
{
    int inter = (int)[(NSDate *)GetUserDefault(dateLastPostSMS) timeIntervalSinceNow] + 60;
    NSLog(@"------ > %d", inter);
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



//- (IBAction)btnClick:(UIButton *)sender
//{
//    if (sender.tag == 6)
//    {
//        __weak vcNewLogin *blockSelf = self;
//        MBShowAll;
//        [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:@"13538134032"
//                                       zone:@"86"
//                           customIdentifier:nil
//                                     result:^(NSError *error)
//         {
//             MBHideInBlock;
//             if (!error)
//             {
//                 NSLog(@"验证码发送成功");
//             }
//             else
//             {
//                 NSLog(@"验证码发送失败");
//             }
//
//         }];
//    }
//    else
//    {
//        [self loginByThird:(int)sender.tag block:^{
//            NSLog(@"------  我擦");
//        }];
//    }
//    
//}

    
-(void)initShareButton
{
    NSInteger isAddCount = 0;                       // 已添加的个数
    BOOL isHaveWeiXin = [self isHave:1];
    BOOL isHaveXinLang = [self isHave:2];
    BOOL isHaveQQ = [self isHave:3];
    BOOL isHaveFacebook = [self isHave:4];
    //BOOL isHaveTwitter = [self isHave:5];
    //NSLog(@"是否安装了 微信：%hhd,  新浪：%hhd,  QQ：%hhd,  facebook : %hhd, twitter: %hhd", isHaveWeiXin, isHaveXinLang, isHaveQQ, isHaveFacebook, isHaveTwitter);
    if (!isHaveWeiXin && !isHaveXinLang && !isHaveQQ && !isHaveFacebook) {
        isHaveWeiXin = isHaveXinLang = isHaveQQ = isHaveFacebook = YES;
    }
    
    viewLoginByThird = [[UIView alloc] initWithFrame:CGRectMake(20, ScreenHeight - NavBarHeight - 80, ScreenWidth - 40, 45)];
    [self.view addSubview:viewLoginByThird];

    [self addButtonAddImage:isAddCount++ type:11];
    [self addButtonAddImage:isAddCount++ type:12];
    [self addButtonAddImage:isAddCount++ type:13];
    [self addButtonAddImage:isAddCount++ type:14];
}


// 添加  index： 前面有几个   type：1： qq  2： 新浪微博 3：facebook 4：Qtwitter
-(void)addButtonAddImage:(NSInteger)index type:(NSInteger)type
{
    CGFloat width = (ScreenWidth - 40) / 4.0;
    CGFloat btnheight = 45;
    CGFloat imvheight = 35;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index * width, 0, width, btnheight)];
    btn.tag = type;
    btn.backgroundColor = DClear;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imvheight, imvheight)];
    switch (type) {
        case 11:
            imv.image = [UIImage imageNamed:@"share_qq"];
            break;
        case 12:
            imv.image = [UIImage imageNamed:@"share_weibot"];
            break;
        case 13:
            imv.image = [UIImage imageNamed:@"share_facebook"];
            break;
        case 14:
            imv.image = [UIImage imageNamed:@"share_twitter"];
            break;
            
        default:
            break;
    }
    
    imv.center = btn.center;
    [viewLoginByThird addSubview:imv];
    [viewLoginByThird addSubview:btn];
    
//    Border(imv, DRed);
//    Border(btn, DBlue);
    
}


-(void)dataSuccessBack_loginByThird:(NSDictionary *)dic type:(int)typeID
{
    if(CheckIsOK)
    {
        SetUserDefault(IsLogined, @(YES));
        SetUserDefault(userInfoAccess, dic[@"access"]);  // 保存在本地
        NSString *token = dic[@"token"];
        NSArray *arrKV = @[ self.txfAccount.text, self.txfPassword.text, dic[@"user_id"], @(typeID), token];
        NSDictionary *dicData = @{ dic[@"access"] : arrKV };
        SetUserDefault(userInfoData, dicData);
        
//        self.userInfo = myUserInfo;
//        self.userInfo.token = token;
//        self.userInfo.user_id = @([(NSString *)dic[@"user_id"] intValue]);
//        self.userInfo.account = arrDataFromThird[0];
//        self.userInfo.loginType = @(typeID + 1);  //// ----  QQ 1 Sina 2
//        NSLog(@"token:%@, user_id:%@, email:%@, loginType:%@", token, self.userInfo.user_id, self.userInfo.account, self.userInfo.loginType);
//        DBSave;
        
        NSString *acount    = arrDataFromThird[0];
        NSNumber *loginType = @(typeID + 1);
        
        __block vcNewLogin *blockSelf = self;
        self.userInfo = [UserInfo objectByDictionary:dic
                                             context:DBefaultContext
                                        perfectBlock:^(id model) {
                                            UserInfo * user = model;
                                            user.account    = acount;
                                            user.loginType  = loginType;
                                        }];
        
        
        NSLog(@"%@", dic);
        NSString * access = dic[@"access"];
        RequestCheckAfter(
              [net getUserInfo:access];,
              [blockSelf dataSuccessBack_getUserInfo:dic isThird:YES];);
    }
}

-(void)updateUserinfo
{
//    NSMutableDictionary *dicUp = [NSMutableDictionary new];
//    [dicUp setValue:self.userInfo.access forKey:@"access"];
//    [dicUp setValue:self.userInfo.logo forKey:@"user_pic_url"];
//    [dicUp setValue:self.userInfo.user_nick_name forKey:@"user_nick_name"];
//    [dicUp setValue:self.userInfo.user_gender forKey:@"user_gender"];
//    [dicUp setValue:self.userInfo.user_height forKey:@"user_height"];
//    [dicUp setValue:self.userInfo.user_weight forKey:@"user_weight"];
//    [dicUp setValue:[self.userInfo.user_birthday toString:@"YYYYMMdd"]  forKey:@"user_birthday"];
//    [dicUp setValue:self.userInfo.user_drink_target forKey:@"user_drink_target"];
//    [dicUp setObject:self.userInfo.countryID forKey:@"user_country_code"];
//    [dicUp setObject:self.userInfo.stateID forKey:@"user_state_code"];
//    [dicUp setObject:self.userInfo.cityID forKey:@"user_city_code"];
//    [dicUp setObject:[NSString stringWithFormat:@"%02d", [DFD getLanguage]] forKey:@"user_language_code"];
//    
//    
//    NSLog(@"-- > %@", dicUp);
//    
    
    self.userInfo.user_language_code = [NSString stringWithFormat:@"%02d", [DFD getLanguage]];
    DBSave;
    
    NSDictionary *dicUp = self.userInfo.objectToDictionary;
    NSLog(@"-- < %@", dicUp);
    
    __block vcNewLogin *blockSelf = self;
    RequestCheckAfter(
          [net updateUserInfo:dicUp];,
          [blockSelf dataSuccessBack_updateUserInfo:dic];);
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        self.userInfo.isNeedUpdate = @YES;
        DBSave;
        [self performSegueWithIdentifier:@"newlogin_newperfect" sender:nil];
    }
    else
    {
        NSLog(@"    这里出错了");
    }
}

-(void)dataSuccessBack_login:(NSDictionary *)dic
{
    NSInteger statue = [dic[@"status"] integerValue];
    switch (statue) {
        case 2:
            MBHide;
            LMBShow(@"账号不存在");
            return;
        case 3:
            MBHide;
            LMBShow(@"密码不正确");
            return;
    }
    
    if (!CheckIsOK) return;
    
    SetUserDefault(IsLogined, @YES);
    SetUserDefault(userInfoAccess, dic[@"access"]);  // 保存在本地
    
    NSString *token = dic[@"token"];
    NSArray *arrKV = @[ self.txfAccount.text, self.txfPassword.text, dic[@"user_id"], @0, token];
    NSDictionary *dicData = @{ dic[@"access"] : arrKV };
    SetUserDefault(userInfoData, dicData);
    
    
    __block vcNewLogin *blockSelf = self;
    self.userInfo = [UserInfo objectByDictionary:dic
                                         context:DBefaultContext
                                    perfectBlock:^(id model) {
                                        UserInfo * user = model;
                                        user.password = self.txfPassword.text;
                                        user.loginType = [blockSelf.txfAccount.text rangeOfString:@"@"].length ? @0:@1;
                                    }];
    
    NSLog(@"%@", dic);
    NSString * access = dic[@"access"];
    RequestCheckAfter(
          [net getUserInfo:access];,
          [blockSelf dataSuccessBack_getUserInfo:dic isThird:NO];);
}

-(void)dataSuccessBack_getUserInfo:(NSDictionary *)dic isThird:(BOOL)isThird
{
    int status = [dic[@"status"] intValue];
    if (status == 4) {
        [self updateUserinfo];  // 第三方跳转 到完善信息
        return;
    }
    if (!CheckIsOK) return;
    
    __block vcNewLogin *blockSelf = self;
    self.userInfo = [UserInfo objectByDictionary:dic
                                         context:DBefaultContext
                                    perfectBlock:^(id model) {
                                        UserInfo * user = model;
                                        user.account = isThird ? blockSelf.userInfo.account : blockSelf.txfAccount.text;
                                        if ([user.countryID isEqualToString:@"0"]) {
                                            user.countryID = @"1";
                                            user.stateID = @"11";
                                        }
                                    }];
    
    NSInteger countInLocal = [[DataRecord numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext] integerValue];
    if (!countInLocal)
    {
        RequestCheckAfter(
              [net getDrinkData:blockSelf.userInfo.access user_id:nil k_date_from:0 k_date_to:10000];,
              [blockSelf dataSuccessBack_getDrinkData:dic];);
    }
    else
    {
        MBHide;
        self.txfPassword.text = @"";
        [self refreshBtnLogin:NO];
        [self gotoMainStoryBoard];
    }
}

-(void)dataSuccessBack_getDrinkData:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        //NSLog(@"------ %@", dic);
        __block vcNewLogin *blockSelf = self;
        [DataRecord objectsByArray:dic[@"drink_data"]
                           context:DBefaultContext
                      perfectBlock:^(id model) {
                          DataRecord *dr = model;
                          dr.access = blockSelf.userInfo.access;
                          dr.target = blockSelf.userInfo.user_drink_target;
                          dr.isUpload = @YES;
                          if ([dr.date isToday])
                             [dr MR_deleteEntityInContext:DBefaultContext];
                      }];
        //NSLog(@"服务器上数据共 %@ 天, 同步到本地完成", @(arrModel.count));
        
        self.txfPassword.text = @"";
        [self refreshBtnLogin:NO];
        [self gotoMainStoryBoard];
        
        
        
//        NSArray *arrData = dic[@"drink_data"];
//        for (int i = 0; i < arrData.count; i++)
//        {
//            NSDictionary *dicData = arrData[i];
//            NSString *k_date = dicData[@"k_date"];
//            NSString *time_array = dicData[@"time_array"];
//            NSString *water_array = dicData[@"water_array"];
//            NSString *counts = dicData[@"counts"];
//            
//            DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", self.userInfo.access, k_date] inContext:DBefaultContext];
//            if (!dr)
//            {
//                dr = [DataRecord MR_createEntityInContext:DBefaultContext];
//                dr.access = self.userInfo.access;
//                dr.dateValue = @([k_date integerValue]);
//                if ([dr.dateValue integerValue] == 0) {
//                    NSLog(@"- 尼玛  等于0");
//                }
//                dr.date = [DFD HmF2KNSIntToDate:[k_date intValue]];
//                dr.cout = @([counts integerValue]);
//                dr.waterCount = @([DFD getWaterCountFromWater_array:water_array time_array:time_array]);
//                dr.time_array = time_array;
//                dr.water_array = water_array;
//                dr.water_array_Hours = [DFD getWater_array_Hour_FromArray:water_array time_array:time_array];
//                dr.target = @([self.userInfo.user_drink_target integerValue]);
//                dr.isUpload = @(YES);
//                [dr perfect];
//            }
//            else if ([dr.cout integerValue] < [counts integerValue])
//            {
//                dr.cout = @([counts integerValue]);
//            }
//            
//            // 删除今日数据
//            if ([dr.date isToday])
//                [dr MR_deleteEntityInContext:DBefaultContext];
//        }
//        DBSave;
//        NSLog(@"服务器上数据共 %@ 天, 同步到本地完成", @(arrData.count));
//        
//        self.txfPassword.text = @"";
//        [self refreshBtnLogin:NO];
//        [self gotoMainStoryBoard];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"newlogin_newbackpassword"])
    {
        vcNewBackPassword *vc = (vcNewBackPassword *)segue.destinationViewController;
        vc.delegate = self;
    }else if([segue.identifier isEqual:@"newlogin_newregister"])
    {
        vcNewRegisiter *vc = (vcNewRegisiter *)segue.destinationViewController;
        vc.delegate = self;
    }else if([segue.identifier isEqual:@"newlogin_newperfect"])
    {
        vcNewPerfectInfo *vc = (vcNewPerfectInfo *)segue.destinationViewController;
        vc.arrDataFromThird = arrDataFromThird;
        vc.isAcceptBack = YES;
    }
}


#pragma mark UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self checkBtnLogin:nil password:nil];
    if ([textField isEqual:self.txfPhoneNumber]) {
        [self checkbtnPostSMS:nil];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.txfAccount])
    {
        if (!range.length) {
            [self checkBtnLogin:[NSString stringWithFormat:@"%@%@", textField.text, string] password:nil];
        }else
        {
            NSString *newText = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)];
            [self checkBtnLogin:newText password:nil];
        }
    }else if ([textField isEqual:self.txfPassword])
    {
        if (!range.length) {
            [self checkBtnLogin:nil password:[NSString stringWithFormat:@"%@%@", textField.text, string]];
        }else
        {
            NSString *newText = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)];
            [self checkBtnLogin:nil password:newText];
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
    if ([textField isEqual:_txfAccount]) {
        [_txfPassword becomeFirstResponder];
    }else if ([textField isEqual:_txfPassword]){
        if (_txfAccount.text.length && _txfPassword.text.length) {
            [self btnClick:_btnLogin];
        }
    }
    return true;
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int subIndex = scrollView.contentOffset.x / ScreenWidth;
    isLeft = subIndex == 0;
    [self viewMove];
}

#pragma mark  vcBackPasswordDelegate + vcNewRegisiterDelegate
-(void)FillIn:(NSString *)email
{
    self.txfAccount.text = email;
}



#pragma mark SecondViewControllerDelegate xuanzhong
- (void)setSecondData:(SMSSDKCountryAndAreaCode *)data
{
    NSLog(@"name: %@ code:%@, pingyin:%@", data.countryName, data.areaCode, data.pinyinName);
    countryCode = data.areaCode;
    countryName = data.countryName;
    self.txfCountry.text = countryName;
    self.lblPhoneCode.text = [NSString stringWithFormat:@"+%@", countryCode];
    [self checkbtnPostSMS:nil];
}


@end
