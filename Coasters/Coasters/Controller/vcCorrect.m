//
//  vcCorrect.m
//  Coasters
//
//  Created by 丁付德 on 15/12/25.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcCorrect.h"

@interface vcCorrect ()

@property (strong, nonatomic) UIButton *btnCorrect;
@property (strong, nonatomic) UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIScrollView *scrMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewMain;


@end

@implementation vcCorrect

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButton:nil text:@"校准"];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    [self initView];
}

-(void)initView
{
    NSArray *arrStr = @[ kString(@"    为了让杯垫更精确的计算您的喝水状况，需要您将其校准，如果杯垫一切正常，您无需校准。"),
                         kString(@"请按照以下步骤进行操作:"),
                         kString(@"1.请移走杯垫上的杯子，保证杯垫上没有重物。"),
                         kString(@"2.请点击“开始校准”按钮，杯垫会进入校准状态。"),
                         kString(@"3.杯垫显示“OK”之后，请点击“保存”按钮, 此时杯垫校准完成。")];
    
    UILabel *lbl1 = [[UILabel alloc] init];
    lbl1.text = arrStr[0];
    lbl1.font = [UIFont systemFontOfSize:14];
    lbl1.textColor = DBlack;
    lbl1.numberOfLines = 0;
    CGFloat height1 = [DFD getTextSizeWith:lbl1.text fontNumber:14 biggestWidth:ScreenWidth - 40].height + 21;
    lbl1.frame = CGRectMake(20, 20, ScreenWidth - 40, height1);
    [self.viewMain addSubview:lbl1];

    UILabel *lbl2 = [[UILabel alloc] init];
    lbl2.text = arrStr[1];
    lbl2.font = [UIFont systemFontOfSize:14];
    lbl2.textColor = DBlack;
    lbl2.numberOfLines = 0;
    
    CGFloat height2 = [DFD getTextSizeWith:lbl2.text fontNumber:14 biggestWidth:ScreenWidth - 40].height;
    lbl2.frame = CGRectMake(20, 40 + height1, ScreenWidth - 40, height2);
    [self.viewMain addSubview:lbl2];
    
    UILabel *lbl3 = [[UILabel alloc] init];
    lbl3.text = arrStr[2];
    lbl3.font = [UIFont systemFontOfSize:14];
    lbl3.textColor = DBlack;
    lbl3.numberOfLines = 0;
    
    CGFloat height3 = [DFD getTextSizeWith:lbl3.text fontNumber:14 biggestWidth:ScreenWidth - 40].height;
    lbl3.frame = CGRectMake(20, 50 + height1 + height2, ScreenWidth - 40, height3);
    [self.viewMain addSubview:lbl3];

    UILabel *lbl4 = [[UILabel alloc] init];
    lbl4.text = arrStr[3];
    lbl4.font = [UIFont systemFontOfSize:14];
    lbl4.textColor = DBlack;
    lbl4.numberOfLines = 0;
    
    CGFloat height4 = [DFD getTextSizeWith:lbl4.text fontNumber:14 biggestWidth:ScreenWidth - 40].height;
    lbl4.frame = CGRectMake(20, 60 + height1 + height2 + height3, ScreenWidth - 40, height4);
    [self.viewMain addSubview:lbl4];

    self.btnCorrect = [[UIButton alloc] init];
    self.btnCorrect.tag = 1;
    [self.btnCorrect setTitle:kString(@"开始校准") forState:UIControlStateNormal];
    self.btnCorrect.titleLabel.textColor = DWhite;
    self.btnCorrect.layer.cornerRadius = 5;
    self.btnCorrect.layer.masksToBounds = YES;
    self.btnCorrect.titleLabel.font = [UIFont systemFontOfSize:14];
    CGFloat btnHeight = Bigger(RealHeight(88), 40);
    self.btnCorrect.frame = CGRectMake(40, 70 + height1 + height2 + height3 + height4, ScreenWidth - 80, btnHeight);
    [self.viewMain addSubview:self.btnCorrect];

    UILabel *lbl5 = [[UILabel alloc] init];
    lbl5.text = arrStr[4];
    lbl5.font = [UIFont systemFontOfSize:14];
    lbl5.textColor = DBlack;
    lbl5.numberOfLines = 0;
    
    
    
    CGFloat height5 = [DFD getTextSizeWith:lbl5.text fontNumber:14 biggestWidth:ScreenWidth - 40].height;
    lbl5.frame = CGRectMake(20, 80 + height1 + height2 + height3 + height4 + btnHeight, ScreenWidth - 40, height5);
    [self.viewMain addSubview:lbl5];

    
    self.btnSave = [[UIButton alloc] init];
    self.btnSave.tag = 2;
    [self.btnSave setTitle:kString(@"完成") forState:UIControlStateNormal];
//    self.btnSave.backgroundColor = DidConnectColor;
    self.btnSave.titleLabel.textColor = DWhite;
    self.btnSave.layer.cornerRadius = 5;
    self.btnSave.layer.masksToBounds = YES;
    self.btnSave.titleLabel.font = [UIFont systemFontOfSize:14];
    self.btnSave.frame = CGRectMake(40, 90 + height1 + height2 + height3 + height4 + height5 + btnHeight, ScreenWidth - 80, btnHeight);
    [self.viewMain addSubview:self.btnSave];
    
    [self.btnCorrect addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnSave addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.scrMain.scrollEnabled = IPhone4;
    self.viewMainHeight.constant = 90 + height1 + height2 + height3 + height4 + height5 + 2 * btnHeight;
    
    
    [self.btnCorrect setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor1] forState:UIControlStateNormal];
    [self.btnCorrect setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor2] forState:UIControlStateHighlighted];
    
    [self.btnSave setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor1] forState:UIControlStateNormal];
    [self.btnSave setBackgroundImage:[UIImage imageFromColor:btnRegisterBackColor2] forState:UIControlStateHighlighted];
    
    self.btnSave.enabled = NO;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self.Bluetooth setCorrect:self.userInfo.pUUIDString type:3];
    [super viewWillDisappear:animated];
}

- (IBAction)btnClick:(UIButton *)sender
{
    switch (sender.tag) {
        case 1:
        {
            [self.Bluetooth setCorrect:self.userInfo.pUUIDString type:1];
            __block vcCorrect *blockSelf = self;
            NextWaitInMainAfter(
                     blockSelf.btnSave.enabled = YES;
                     , 1);
        }
            break;
        case 2:
        {
            [self.Bluetooth setCorrect:self.userInfo.pUUIDString type:2];
            self.btnSave.enabled = NO;
        }
            break;
            
        default:
            break;
    }
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
