//
//  vcFriendDetails.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriendDetails.h"
#import "tvcIndex.h"
#import "vcChart.h"
#import "NSMutableArray+Sort.h"
#import "LXEmojiKeyboardView.h"
#import "LXGrowingInputView.h"
#import <Masonry.h>
#import "NSString+Verify.h"

#define tableViewHeight         Bigger(RealHeight(100), 50)

@interface vcFriendDetails ()<UITableViewDataSource, UITableViewDelegate, LXGrowingInputViewDelegate>
{
    UITapGestureRecognizer *tap;
    UIVisualEffectView *effectView;
    UIVisualEffectView *effectViewHead;
    BOOL _isForKeybaordTypeChange;
    BOOL isSending;                                 // 是否正在发送
    NSString *content;
}
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewFirst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight;
@property (weak, nonatomic) IBOutlet UIView *viewSecond;
@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imvGender;
@property (weak, nonatomic) IBOutlet UIButton *btnRemind;
@property (weak, nonatomic) IBOutlet UILabel *lblRemind;



@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNameTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnRemindTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Bottom;


@property (strong, nonatomic) UITableView *tabView;
@property (strong, nonatomic) NSMutableArray *arrData;

@property (strong, nonatomic) LXEmojiKeyboardView * emojiView;
@property (strong, nonatomic) LXGrowingInputView * inputView;

- (IBAction)btnClick:(id)sender;

@end

@implementation vcFriendDetails

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:@"详细信息"];
    [self initRightButton:@"cupcare-Data" text:nil];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    self.model = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.model.access, self.model.user_id] inContext:DBefaultContext];
    [self initData];
    [self initView];

    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imvTap)];
    [self.imvLogo addGestureRecognizer:tap];
    self.imvLogo.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [self removeObserverForKeyboardNotifications];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"vcFriendDetails 被销毁了");
    [self.imvLogo removeGestureRecognizer:tap];
    [effectViewHead removeFromSuperview];
}

-(void)rightButtonClick
{
    [self performSegueWithIdentifier:@"details_to_chart" sender:nil];
}

-(void)imvTap
{
    [self.imvLogo removeGestureRecognizer:tap];
    [self editViewHide];
    CGFloat width = 200 / 720.0 * ScreenWidth;
    [UIView transitionWithView:self.imvLogo duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         if (self.imvLogo.tag) {
             self.imvLogo.frame = CGRectMake((ScreenWidth - width ) / 2, 25, width, width);
             self.imvLogo.layer.cornerRadius = self.imvLogo.frame.size.height / 2;
             [_imvLogo.layer setMasksToBounds:YES];
             if (effectView) {
                 effectView.alpha = 0;
                 effectViewHead.alpha = 0;
             }
         }else{
             self.imvLogo.frame = CGRectMake(10, 10, ScreenWidth - 20, ScreenWidth - 20);
             self.imvLogo.layer.cornerRadius = 20;
             [_imvLogo.layer setMasksToBounds:YES];
             if (effectView) {
                 effectView.alpha = 0.8;
                 effectViewHead.alpha = 0.8;
             }
         }
         
     } completion:^(BOOL finished) {
         [self.imvLogo addGestureRecognizer:tap];
         self.imvLogo.tag = self.imvLogo.tag ? 0:1;
         
     }];
}

-(void)initData
{
    self.arrData = [NSMutableArray new];
    NSArray *arrWater = [self.model.water_array componentsSeparatedByString:@","];
    NSArray *arrTime = [self.model.time_array componentsSeparatedByString:@","];
    if (arrWater.count > 0 && arrTime.count > 0 && [arrWater[0] description].length > 0)
    {
        for (int i = 0; i < arrWater.count; i++)
        {
            MdIndex *model = [MdIndex new];
            model.type = 2;
            model.msg = kString(@"喝水");
            
            model.date = [DFD getDateTimeFormDateValue:[arrTime[i] intValue]];
            model.msgML = [NSString stringWithFormat:@"%@ ml", arrWater[i]];
            [self.arrData addObject:model];
        }
    }
    else
    {
        MdIndex *model = [MdIndex new];
        model.type = 4;
        model.msg = kString(@"今天没有喝水哟");
        model.date = [DNow getNowDateFromatAnDate];
        model.msgML = @"";
        [self.arrData addObject:model];
        
    }
    
    _arrData = [_arrData startArraySort:@"date" isAscending:NO];
}
-(void)initView
{
    [self.viewMain setHidden:NO];
    
    self.viewMainHeight.constant = ScreenHeight - NavBarHeight;
    self.viewFirst.backgroundColor = DidConnectColor;
    
    self.imvLogo.layer.cornerRadius = ScreenWidth * (20 / 75.0) / 2;
    [self.imvLogo.layer setMasksToBounds:YES];
    
    _viewFirstHeight.constant = RealHeight(650);
    _imvTop.constant = IPhone4 ? 10 : RealHeight(78);
    _lblNameTop.constant = _btnRemindTop.constant = IPhone4 ? 10 : RealHeight(30);
    _lbl2Bottom.constant = Bigger(RealHeight(100), 50);
    
    
    [self.imvLogo sd_setImageWithURL:[NSURL URLWithString:self.model.user_pic_url] placeholderImage: DefaultLogo_Gender([self.model.user_gender boolValue])];
    self.lblName.text = self.model.user_nick_name;
    self.imvGender.image =  [UIImage imageNamed:([self.model.user_gender boolValue] ?  @"gender_female" : @"gender_male")];
    self.lblRemind.text = kString(@"提醒Ta喝水");
    [self.btnRemind setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateHighlighted];
    
    self.btnRemind.layer.cornerRadius = 5;
    [self.btnRemind.layer setMasksToBounds:YES];
    
    self.lbl1.text = kString(@"今日喝水量");
    self.lbl2.text = kString(@"目标日喝水量");
    self.lbl3.text = kString(@"上次提醒时间");
    self.lbl4.text = [self.model.waterCount integerValue] > 0 ? [NSString stringWithFormat:@"%@ml", self.model.waterCount] : @"---";
    self.lbl5.text = [self.model.waterCount integerValue] > 0 ? [NSString stringWithFormat:@"%@ml", self.model.user_drink_target] : @"---";
    [self refreshLastRemindTime];
    [self initTable];
    
    if(SystemVersion >= 8)
    {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectView.alpha = 0;
        [self.viewFirst insertSubview:effectView belowSubview:self.imvLogo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            effectViewHead = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
            effectViewHead.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            effectViewHead.alpha = 0;
            [self.view.window addSubview:effectViewHead];
        });
    }
}

-(void)initTable
{
    self.tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight - _viewFirstHeight.constant)]; // - 270
    self.tabView.dataSource = self;
    self.tabView.delegate = self;
    self.tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcIndex" bundle:nil] forCellReuseIdentifier:@"Cell"];
    [self.viewSecond addSubview:self.tabView];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcIndex *cell = [tvcIndex cellWithTableView:tableView];
    MdIndex *model = self.arrData[indexPath.row];
    cell.isNotComeOn = YES;                                     // 要求不含有再接再厉
    cell.model = model;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MdIndex *model= _arrData[indexPath.row];
    if (model.type == 4)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@", model.msg, model.msgML ? model.msgML : @""];
        CGFloat titleHeight = [DFD getTextSizeWith:str fontNumber:14 biggestWidth:(ScreenWidth - (model.type == 4 ? 100 : 160))].height;
        titleHeight = (titleHeight > 21 ? titleHeight : 21) + (tableViewHeight - 21);
        return titleHeight;
    }
    return tableViewHeight;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"details_to_chart"])
    {
        vcChart *vc = (vcChart *)segue.destinationViewController;
        vc.model = self.model;
    }
}

- (IBAction)btnClick:(id)sender
{
    if (!self.model.lastRemindDatetime || fabs([self.model.lastRemindDatetime timeIntervalSinceNow]) > 1 * 60 * 60) // 60 * 60 一个小时
    {
        if (!self.emojiView) {
            [self initRemind];
        }
    }
    else
    {
        LMBShow(@"你刚刚已经提醒过Ta一次了,稍后再提醒吧");
    }
}


-(void)initRemind
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (!self.emojiView)
    {
        self.emojiView = [[LXEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
        self.emojiView.length = 30;
        self.emojiView.arrData = @[ kString(@"亲爱的朋友,你该喝水了哟~"), kString(@"友情提示, 朋友，你该喝水了~")];
        
        LXGrowingInputView * inputView = [[LXGrowingInputView alloc] init];
        inputView.translatesAutoresizingMaskIntoConstraints = NO;
        inputView.length = 30;
        [self.view addSubview:inputView];
        
        [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
            make.height.mas_equalTo(45);
        }];
        
        inputView.delegate = self;
        _inputView = inputView;
        [_inputView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, 45)];
    }
    
    [UIView transitionWithView:_inputView duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [_inputView setFrame:CGRectMake(0 , ScreenHeight-45, ScreenWidth, 45)];
    } completion:^(BOOL finished) {}];
}

#pragma mark - UIKeyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)removeObserverForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShown:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    CGSize kbSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = kbSize.height;
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-keyboardHeight);
    }];
    
    [UIView animateWithDuration:durtion - 0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if (_isForKeybaordTypeChange) {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:durtion animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Delegate
- (void) inputView:(LXGrowingInputView *)inputView willChangeHeight:(float)height {
    
    if (height > 100) {
        return;
    }
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)inputView:(LXGrowingInputView *)inputView keyboardChangeButtonClick:(UIButton *)button keyboardType:(LXKeyboardType)type {
    
    _isForKeybaordTypeChange = YES;
    
    NSTimeInterval durtion = 0;
    if ([inputView.textView isFirstResponder]) {
        durtion = 0.06;
    }
    
    [inputView.textView resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (type == LXKeyboardTypeDefault) {
            _emojiView.textView = nil;
        }
        else {
            _emojiView.textView = _inputView.textView;
        }
        
        [_inputView.textView reloadInputViews];
        [_inputView.textView becomeFirstResponder];
    });
}

- (void) didInputViewSendButtonClick:(LXGrowingInputView *)inputView {
    _isForKeybaordTypeChange = NO;
    [_inputView.textView resignFirstResponder];
    content = inputView.textView.text;
    if (content.length) [self passRemind];
}

-(void)passRemind
{
    if (isSending) return;
    isSending = YES;
    NextWaitInMainAfter(isSending = NO;, 10);
    NSString *pushContent = [NSString stringWithFormat:@"%@", content];
    __block vcFriendDetails *blockSelf = self;
    
    
    if ([NSString isHaveEmoji:content]) {
        LMBShow(@"包含了不能识别的字符");
        return;
    }
    
    NSLog(@"------ > 请求一次");
    
    RequestCheckBefore(
           [net pushDrinkHint:blockSelf.userInfo.access
                         type:@"3"
                    friend_id:blockSelf.model.user_id
                      content:pushContent];,
           [blockSelf dataSuccessBack_pushDrinkHint:dic];,
           isSending = NO;,NO)
}

-(void)refreshLastRemindTime
{
   self.lbl6.text = [self.model.lastRemindDatetime isToday] ? [self.model.lastRemindDatetime toString:@"hh:mm a"] : @"---";
}


-(void)dataSuccessBack_pushDrinkHint:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        LMBShow(@"已发送提醒");
        Friend *fr = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat: @"access == %@ and user_id == %@", self.userInfo.access, self.model.user_id] inContext:DBefaultContext];
        fr.lastRemindDatetime = self.model.lastRemindDatetime = DNow;
        DBSave;
        
        [self refreshLastRemindTime];
        [self editViewHide];
    }
}

-(void)editViewHide
{
    if (!_emojiView) return;
    _isForKeybaordTypeChange = YES;
    NSTimeInterval durtion = 0;
    if ([_inputView.textView isFirstResponder]) durtion = 0.03;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView transitionWithView:_inputView duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [_inputView setFrame:CGRectMake(0 , ScreenHeight+100, ScreenWidth, 45)];
            [_emojiView setFrame:CGRectMake(0 , ScreenHeight+100, ScreenWidth, 45)];
        } completion:^(BOOL finished) {
            [_inputView removeFromSuperview];
            [_emojiView removeFromSuperview];
            _inputView = nil;
            _emojiView = nil;
        }];
    });
}



@end
