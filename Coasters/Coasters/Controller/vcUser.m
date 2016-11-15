//
//  vcUser.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUser.h"
#import "tvcUser.h"
#import "UIViewController+GetAccess.h"
#import "vcBase+Share.h"
#import "vcORCode.h"
#import "Country.h"
#import "State.h"
#import "City.h"
#import "TAlertView.h"
#import "HJCActionSheet.h"
#import "NSString+Verify.h"

@interface vcUser () <UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate, HJCActionSheetDelegate>
{
    NSString *      newNickName;
    BOOL            newGender;
    NSDate *        newBirthDay;
    CGFloat         newHeight;
    CGFloat         newWeight;
    NSInteger       newTarget;
    
    NSString *      sexShow;              // 显示
    NSString *      heightShow;           // 显示的
    NSString *      weightShow;
    NSString *      targetShow;
    NSString *      birthShow;            // 19890908
    
    NSInteger       selectedIndex;        // 当前选择的table 索引
    NSInteger       selectedPickIndex;    // pick选中的索引
    
    NSString *      unit;                 // 当前用户的体重单位
    
    BOOL            isChangeTarget;       // 是否修改目标值
    BOOL            isChangeOther;        // 是否修改了目标以外的
    BOOL            isAutoUpdate;         // 是否自动更新的
    
    NSArray *       arrCountry;
    NSArray *       arrState;
    NSArray *       arrCity;
    
    Country *       county_S;              // 用户穿进来的对象   （ 还没有点确定之前的存放 ）
    State  *        state_S;               // 用户穿进来的对象
    City   *        city_S;                // 用户穿进来的对象
    
    int             indexCountry;
    int             indexState;
    int             indexCity;
    
    NSString *      address;               // 数据源中 地址显示
    
    NSNumber *      language;
}



@property (strong, nonatomic) NSMutableArray                *arrData;
@property (strong, nonatomic) UITableView                   *tabView;
@property (nonatomic, strong) UIView                        *bgView;
@property (nonatomic, strong) UIDatePicker                  *datePicker;
@property (nonatomic, strong) UIPickerView                  *pickView;
@property (nonatomic, strong) UIPickerView                  *pickViewAddress;


@property (nonatomic, strong) NSMutableArray                *arrHeight;   //50 - 250
@property (nonatomic, strong) NSMutableArray                *arrWeigth;   //20 - 150
@property (nonatomic, strong) NSArray                       *arrSex;      //
@property (nonatomic, strong) NSMutableArray                *arrTarget;   //500 - 5000 100递增


@property (nonatomic, copy) NSString*                       photoUrl;


@end

@implementation vcUser

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"vcUser viewDidLoad");
    [self initLeftButton:nil text:@"个人信息"];
    [self initRightButton:@"save" text:nil];\
    language = @([DFD getLanguage]);
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self refreshData];
    [self initView];
    
    __block vcUser *blockSelf = self;
    RequestCheckNoWaring(
             [net getUserInfo:blockSelf.userInfo.access];,
             [blockSelf dataSuccessBack_getUserInfo:dic];);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:ConnectImg forBarMetrics:UIBarMetricsDefault];
    
    __weak vcUser *blockSelf = self;
    self.upLoad_Next = ^(NSString *url)
    {
        if(!url.length)
        {
            NSLog(@"图片上传失败");
            LMBShowInBlock(NONetTip);
        }else
        {
            blockSelf.photoUrl = url;
            [blockSelf saveToServer];
        }
    };
}


-(void)viewWillDisappear:(BOOL)animated
{
    self.upLoad_Next = nil;
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [self.ViewEffectBody removeFromSuperview];
    [self.ViewEffectHead removeFromSuperview];
    NSLog(@"vcUser 销毁了");
}

-(void)refreshData
{
    newNickName = self.userInfo.user_nick_name;
    newGender = [self.userInfo.user_gender boolValue];
    newBirthDay = self.userInfo.user_birthday ? self.userInfo.user_birthday : DNow;
    birthShow = [newBirthDay toString:@"YYYYMMdd"];
    newHeight = [self.userInfo.user_height doubleValue];
    newWeight = [self.userInfo.user_weight doubleValue];
    newTarget = [self.userInfo.user_drink_target integerValue];
    self.photoUrl = self.userInfo.logo;
    unit = [self.userInfo.unit boolValue] ? @"Kg" : @"Lb";
    
    if ([self.userInfo.unit boolValue])
    {
        heightShow = [NSString stringWithFormat:@"%.0fcm", newHeight];
        weightShow = [NSString stringWithFormat:@"%.0fKg", newWeight];
    }
    else
    {
        NSInteger ft = [self.userInfo.user_height doubleValue] * CmToFt;
        NSInteger iN =  round(([self.userInfo.user_height doubleValue] * CmToFt - ft) * 12.0);
        heightShow = [NSString stringWithFormat:@"%ld'%ld''", (long)ft, (long)iN];
        
        NSInteger wei = round([self.userInfo.user_weight floatValue] / KgToLb);
        weightShow = [NSString stringWithFormat:@"%ld%@", (long)wei, unit];
    }
    
    targetShow = [NSString stringWithFormat:@"%@ml", self.userInfo.user_drink_target];
    
    _arrHeight = [NSMutableArray new];
    _arrWeigth = [NSMutableArray new];
    _arrTarget = [NSMutableArray new];
    
    int begigWeight = 20;
    int endWeight = 150;
    if (![unit isEqualToString:@"Kg"]) {
        begigWeight = 44;
        endWeight = 331;
    }
    for (int i = begigWeight; i <= endWeight; i++)
        [_arrWeigth addObject:[NSString stringWithFormat:@"%d%@", i, unit]];
    
    //   1.7  8.2
    if ([self.userInfo.unit boolValue])
        for (int i = 50; i <= 250; i++)
            [_arrHeight addObject:[NSString stringWithFormat:@"%dcm", i]];
    else
        for (int i = 1; i <= 8; i++)
            for (int j = 1; j < 12; j++)
                if ((i == 1 && j >= 7) || (i == 8 && j <= 2) || (i != 1 && i != 8))
                    [_arrHeight addObject:[NSString stringWithFormat:@"%d'%d''", i, j]];
    
    for (int i = 500; i < 5000; i+=100)
        [_arrTarget addObject:[NSString stringWithFormat:@"%dml", i]];
    
    _arrSex = @[kString(@"男"), kString(@"女")];
    
    
    if (!self.userInfo.countryID)
    {
        self.userInfo.countryID = @"1";
        self.userInfo.stateID   = @"11";
        self.userInfo.cityID    = @"0";
    }
        
    DBSave;
    
    county_S = [Country findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and countryID == %@", language, self.userInfo.countryID] inContext:DBefaultContext];
    NSLog(@"国家:%@ %@", county_S.countryName, county_S.countryID);
    
    state_S = [State findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and country == %@ and stateID == %@", language, county_S, self.userInfo.stateID] inContext:DBefaultContext];
    
    NSLog(@"地区:%@ %@", state_S.stateName, state_S.stateID);
    city_S = [City findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@ and cityID == %@", language, state_S, self.userInfo.cityID] inContext:DBefaultContext];
    NSLog(@"城市:%@ %@", city_S.cityName, city_S.cityID);
    
    arrCountry = [Country MR_findAllSortedBy:@"countryID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@", language] inContext:DBefaultContext];
    
    arrState = [State MR_findAllSortedBy:@"stateID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and country == %@",language, county_S] inContext:DBefaultContext];
    arrCity = [City MR_findAllSortedBy:@"cityID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@",language, state_S] inContext:DBefaultContext];
    
    indexCountry = 0;
    indexState   = 0;
    indexCity    = 0;
    
    indexCountry     = (int)[arrCountry indexOfObject:county_S];
    if(state_S)
        indexState   = (int)[arrState indexOfObject:state_S];
    if(city_S)
        indexCity    = (int)[arrCity indexOfObject:city_S];
    
    
    [self refreshAddress];
}

-(void)refreshAddress
{
    if (county_S && state_S.stateID && city_S){
        if ([state_S.stateID isEqualToString:@"0"]) {
            address = [NSString stringWithFormat:@"%@ %@", county_S.countryName, city_S.cityName];
        }else{
            address = [NSString stringWithFormat:@"%@ %@", state_S.stateName, city_S.cityName];
        }
    }else{
        NSMutableString *str = [[NSMutableString alloc] init];
        if (county_S) [str appendFormat:@"%@ ", county_S.countryName];
        if (state_S) [str appendFormat:@"%@ ", state_S.stateName];
        address = str;
    }
}

-(void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    _tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    _tabView.dataSource = self;
    _tabView.delegate = self;
    _tabView.showsVerticalScrollIndicator = NO;
    _tabView.backgroundColor = DLightGrayBlackGroundColor;
//    _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tabView registerNib:[UINib nibWithNibName:@"tvcUser" bundle:nil] forCellReuseIdentifier:@"tvcUser"];
    [self.view addSubview:_tabView];
    
    _tabView.tableHeaderView = ({
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 10)];
        headView.backgroundColor = _tabView.backgroundColor;
        headView;
    });
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
    _tabView.tableFooterView = footView;
    
    UIButton *btnSignOut = [[UIButton alloc] initWithFrame:CGRectMake(RealWidth(160), 20, RealWidth(400), Bigger(RealHeight(70), 40))];
    [btnSignOut setBackgroundImage:[UIImage imageFromColor:DWhite] forState:UIControlStateNormal];
    [btnSignOut setBackgroundImage:[UIImage imageFromColor:DLightGrayBlackGroundColor] forState:UIControlStateHighlighted];
    
    btnSignOut.layer.borderWidth = 1;
    [btnSignOut setTitleColor:DRed forState:UIControlStateNormal];
    btnSignOut.titleLabel.font = [UIFont fontWithName : @"Helvetica-Bold Oblique" size : 20 ];
    btnSignOut.layer.borderColor = DLightGray.CGColor;
    btnSignOut.layer.cornerRadius = 20;
    [btnSignOut.layer setMasksToBounds:YES];
    
    [btnSignOut setTitle:kString(@"退出登录") forState:UIControlStateNormal];
    [btnSignOut addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:btnSignOut];
    
    
    __block vcUser *blockSelf = self;
    NextWaitInMain(
           [blockSelf initViewCover:300];
           [blockSelf initPickerView];
           [blockSelf initDatePickerView];);
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return section ? 6:4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcUser *cell = [tvcUser cellWithTableView:tableView];
    
    [cell.imvBig setHidden:YES];
    [cell.lblValue setHidden: NO];
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
                cell.lblTitle.text = kString(@"头像");
                [cell.lblValue setHidden: YES];
                [cell.imvBig setHidden: NO];
                if (self.image)
                    cell.imvBig.image = self.image;
                else
                    [cell.imvBig sd_setImageWithURL:[NSURL URLWithString:self.userInfo.logo] placeholderImage: DefaultLogo_Gender([self.userInfo.user_gender boolValue])];
                cell.imvBig.layer.borderWidth = 1;
                cell.imvBig.layer.borderColor = DWhite.CGColor;
                cell.imvBigHeight.constant = Bigger(RealHeight(120), 70) * 0.8;
                cell.imvBig.layer.cornerRadius = cell.imvBigHeight.constant / 2;
                [cell.imvBig.layer setMasksToBounds:YES];
                break;
            case 1:
                cell.lblTitle.text = kString(@"昵称");
                cell.lblValue.text = newNickName;
                break;
            case 2:
            {
                if(indexPath.row == 2 && [self.userInfo.loginType intValue] > 1)
                {
//                    cell.lblTitle.
                }else
                {
                    cell.lblTitle.text = kString(@"账号和密码");
                    cell.lblValue.text = self.userInfo.account;
                }
            }
                break;
            case 3:
                [cell.lblValue setHidden: YES];
                cell.lblTitle.text = kString(@"二维码名片");
                [cell.imvBig setHidden: NO];
                cell.imvBig.image = [UIImage imageNamed:@"qrCode"];
                cell.imvBigHeight.constant = Bigger(RealHeight(120), 70) * 0.5;
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                cell.lblTitle.text = kString(@"性别");
                cell.lblValue.text = newGender ? kString(@"女") :kString(@"男");
                break;
            case 1:
                cell.lblTitle.text = kString(@"出生日期");
                cell.lblValue.text = [newBirthDay toString:@"YYYY / MM / dd"];
                break;
            case 2:
                cell.lblTitle.text = kString(@"地区");
                cell.lblValue.text = address;
                break;
            case 3:
                cell.lblTitle.text = kString(@"身高");
                cell.lblValue.text = heightShow;
                break;
            case 4:
                cell.lblTitle.text = kString(@"体重");
                cell.lblValue.text = weightShow;
                break;
            case 5:
                cell.lblTitle.text = kString(@"日喝水目标");
                cell.lblValue.text = [NSString stringWithFormat:@"%ldml", (long)newTarget];
                break;
        }
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                HJCActionSheet *sheet = [[HJCActionSheet alloc] initWithDelegate:self CancelTitle:kString(@"取消") OtherTitles:kString(@"拍照"), kString(@"从手机相册中选择"), nil];
                [sheet show];
            }
                break;
            case 1:
            {
                TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入新昵称" message:@""];
                alterAccount.strOriginal = newNickName;
                [alterAccount showWithTXFActionSure:^(id str) {
                    newNickName = str;
                    newNickName = newNickName.length > 20 ? [newNickName substringToIndex:20] : newNickName;
                    isChangeOther = YES;
                    [_tabView reloadData];
                } cancel:^{} keyboardType:UIKeyboardTypeDefault];
            }
                break;
            case 2:
                [self performSegueWithIdentifier:@"user_to_editPassword" sender:nil];
                break;
            case 3:
                [self performSegueWithIdentifier:@"user_to_orcode" sender:nil];
                break;
        }
    }
    else
    {
        _pickView.dataSource        = self;
        _pickView.delegate          = self;
        _pickViewAddress.dataSource = self;
        _pickViewAddress.delegate   = self;
        
        selectedIndex = indexPath.row;
        _datePicker.hidden = _pickView.hidden = _pickViewAddress.hidden = YES;
        switch (indexPath.row) {
            case 0:
            {
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:0];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
            }
                break;
            case 1:
            {
                _datePicker.hidden = NO;
            }
                break;
            case 2:
            {
                _pickViewAddress.hidden = NO;
                if (indexCountry >= 0) [_pickViewAddress selectRow:indexCountry inComponent:0 animated:NO];
                if (indexState >= 0)   [_pickViewAddress selectRow:indexState inComponent:1 animated:NO];
                if (indexCity >= 0)    [_pickViewAddress selectRow:indexCity inComponent:2 animated:NO];
            }
                break;
            case 3:
            {
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:3];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
            }
                break;
            case 4:
            {
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:4];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
            }
                break;
            case 5:
            {
                _pickView.hidden = NO;
                NSInteger ind = [self getPickViewIndex:5];
                [_pickView selectRow:ind inComponent:0 animated:NO];
                selectedPickIndex = ind;
            }
                break;
        }
        [_pickView reloadAllComponents];
        [_pickViewAddress reloadAllComponents];
        [self showViewCover];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            return Bigger(RealHeight(120), 70);
        }else if(indexPath.row == 2 && [self.userInfo.loginType intValue] > 1) {
            return 0;
        }
    }
    
    return Bigger(RealHeight(90), 60);
}

-(void)btnClick
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定退出?"];
    [alert showWithActionSure:^
     {
         SetUserDefault(PushAlias, myUserInfoAccess);
         RemoveUserDefault(userInfoAccess);
         RemoveUserDefault(userInfoData);
         [self clearDataFrom3Class];
         
         // 断开所有连接
         SetUserDefault(isNotRealNewBLE, @0);
         [self.Bluetooth stopLink:nil];
         self.Bluetooth.delegate = nil;
         [BLEManager resetBLE];
         self.Bluetooth.isFailToConnectAgain = NO;
         [DFD returnUserNil];

         self.upLoad_Next = nil;
         [self.navigationController popViewControllerAnimated:NO];
         
         __strong vcUser *blockSelf = self;
         NextWaitInMainAfter([blockSelf gotoLoginStoryBoard:nil];, 0.3);
     } cancel:^{
     }];
}

#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:_pickView]) {
        switch (selectedIndex)
        {
            case 0:
                return 2;
                break;
            case 3:
                return  _arrHeight.count;
                break;
            case 4:
                return  _arrWeigth.count;
                break;
            case 5:
                return  _arrTarget.count;
                break;
        }
        return  0;
    }else{
        switch (component) {
            case 0:
                return arrCountry.count;
                break;
            case 1:
                return arrState.count;
                break;
            case 2:
                return arrCity.count;
                break;
        }
        return 0;
    }
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if ([pickerView isEqual:_pickView]) {
        return 1;
    }else{
        return 3;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([pickerView isEqual:_pickView]) {
        switch (selectedIndex) {
            case 0:
                return  _arrSex[row];
                break;
            case 3:
                return  _arrHeight[row];
                break;
            case 4:
                return  _arrWeigth[row];
                break;
            case 5:
                return  _arrTarget[row];
                break;
        }
        return  @"";
    }else{
        switch (component) {
            case 0:
                if(arrCountry.count > row)
                    return ((Country *)arrCountry[row]).countryName;
            case 1:
                if(arrState.count > row)
                    return ((State *)arrState[row]).stateName;
            case 2:
                if(arrCity.count > row)
                    return ((City *)arrCity[row]).cityName;
        }
        return @"";
    }
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if([pickerView isEqual:_pickView]){
        selectedPickIndex = row;
    }else{
        indexCountry = indexState = indexCity = -1;
        switch (component) {
            case 0:
            {
                indexCountry = (int)row;
                county_S = arrCountry[row];
                arrState = [State findAllSortedBy:@"stateID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and country == %@",language, county_S] inContext:DBefaultContext];
                
                state_S = nil;
                city_S =  nil;
                arrCity = nil;
                if (arrState.count) {
                    state_S = arrState[0];
                    indexState = 0;
                    [_pickViewAddress selectRow:0 inComponent:1 animated:NO];
                    arrCity = [City findAllSortedBy:@"cityID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@",language, state_S] inContext:DBefaultContext];
                    if (arrCity.count){
                        city_S = arrCity[0];
                        indexCity = 0;
                        [_pickViewAddress selectRow:0 inComponent:2 animated:NO];
                    }
                }
                [_pickViewAddress reloadComponent:1];
                [_pickViewAddress reloadComponent:2];
            }
                break;
            case 1:
            {
                indexState = (int)row;
                state_S = arrState[row];
                city_S =  nil;
                arrCity = [City findAllSortedBy:@"cityID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@",language, state_S] inContext:DBefaultContext];
                if (arrCity.count){
                    indexCity = 0;
                    city_S = arrCity[0];
                    [_pickViewAddress selectRow:0 inComponent:2 animated:NO];
                }
                [_pickViewAddress reloadComponent:2];
            }
                break;
            case 2:
            {
                indexCity = (int)row;
                city_S = arrCity[row];
            }
                break;
        }
        NSLog(@"选中的 %@ %@ %@", county_S.countryName, state_S.stateName, city_S.cityName);
    }
}

#pragma mark HJCActionSheetDelegate
- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [DFD getPictureFormPhotosOrCamera:buttonIndex != 1
                                   vc:self
                    checekBeforeBlock:^{[self getAccessNext:(buttonIndex == 1 ? CameraAccess:PhotosAccess ) block:^{}];}];
}


#pragma mark -- 选中图片后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    isChangeOther = YES;
    self.image = image;
    [_tabView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)initPickerView
{
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickView.backgroundColor = DWhite;
    [self.ViewCover addSubview:_pickView];
    
    self.pickViewAddress = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    self.pickViewAddress.backgroundColor = DWhite;
    [self.ViewCover addSubview:_pickViewAddress];
}

//初始化DatePickerView
- (void)initDatePickerView
{
    _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, ScreenHeight-256, ScreenWidth, 256 - NavBarHeight)];
    [_datePicker setLocale:[[NSLocale alloc]initWithLocaleIdentifier:[DFD getLanguage] == 1 ? @"zh_CN" :@"en_US"]];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    _datePicker.date = newBirthDay;
    _datePicker.backgroundColor = DWhite;
    _datePicker.maximumDate = DNow;
    [self.ViewCover addSubview:_datePicker];
}

// 获取当前的选中的内容在pickView中的索引
-(NSInteger)getPickViewIndex:(NSInteger)ind
{
    NSInteger inde = 0;
    switch (ind) {
        case 0:
        {
            inde = (int)newGender;
        }
            break;
        case 2:
        {
            // 位置
        }
            break;
        case 3:
        {
            for (NSInteger i = 0; i < _arrHeight.count; i++)
            {
                if ([_arrHeight[i] isEqualToString:heightShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 4:
        {
            for (NSInteger i = 0; i < _arrWeigth.count; i++)
            {
                if ([_arrWeigth[i] isEqualToString:weightShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
        case 5:
        {
            for (NSInteger i = 0; i < _arrTarget.count; i++)
            {
                if ([_arrTarget[i] isEqualToString:targetShow])
                {
                    inde = i;
                    break;
                }
            }
        }
            break;
    }
    return  inde;
}




-(void)rightButtonClick
{
    if (!isChangeOther && !isChangeTarget) return;
    if (newNickName.length == 0) {
        LMBShow(@"昵称未填写");
        return;
    }
    if ([newNickName rangeOfString:@"null"].length || [newNickName rangeOfString:@"nil"].length || [newNickName rangeOfString:@"NULL"].length || [NSString isHaveEmoji:newNickName]) {
        LMBShow(@"昵称中包含了不能识别的字符");
        return;
    }
    //  这里要发送指令                 //  是先 上传 还是 先发送指令
    //  情况1: 无网，  用户只修改了目标值  提示修改成功， 发送指令  更新本地个人目标信息，
    //  情况2: 无网，  用户修改了目标值， 并修改了其他需要网络的， 提示网络异常， 但是也要发送指令 更新本地喝水目标信息
    //  以上  拉去个人信息的时候， 要判断，时间戳， 比较本地上次修改时间戳，从而选择 最新的， 本地最新，覆盖服务器， 服务器最新，覆盖本地

    MBShowAll;
    if (self.image)                               // 如果用户更改了图片
        [self getTokenAndUpload];
    else
        [self saveToServer];
}


-(void)saveToServer
{
    NSString *stateID = state_S.stateID ? state_S.stateID :@"0";
    NSString *cityID = city_S.cityID ? city_S.cityID :@"0";
    
    __block vcUser *blockSelf = self;
    NSDictionary *dicUp = @{
                            @"access":blockSelf.userInfo.access,
                            @"user_pic_url":(blockSelf.photoUrl ? blockSelf.photoUrl : @"" ),
                            @"user_nick_name":blockSelf->newNickName,
                            @"user_gender":@(blockSelf->newGender ? 1 : 0),
                            @"user_height":@(blockSelf->newHeight ? blockSelf->newHeight : 170),
                            @"user_weight":@(blockSelf->newWeight ? blockSelf->newWeight : 70),
                            @"user_birthday":blockSelf->birthShow,
                            @"user_drink_target":@(blockSelf->newTarget ? blockSelf->newTarget : 2000),
                            @"user_country_code":blockSelf->county_S.countryID,
                            @"user_state_code":stateID,
                            @"user_city_code":cityID,
                            @"user_language_code": [NSString stringWithFormat:@"%02d", [blockSelf->language intValue]]};
    NSLog(@"dicUp %@", dicUp);
    
    
    self.userInfo.user_language_code = [NSString stringWithFormat:@"%02d", [DFD getLanguage]];
    DBSave;
    
//    NSDictionary *dicUp2 = self.userInfo.objectToDictionary;
//    NSLog(@"-- < %@", dicUp2);
//    
    
    if ([GetUserDefault(DNet) intValue])  // 有网
    {
        [blockSelf setTarget_:NO];
        if (!isAutoUpdate)
        {
            MBShowAll;
            HDDAF
            
        }
        RequestCheckAfter(
              [net updateUserInfo:dicUp];,
              [blockSelf dataSuccessBack_updateUserInfo:dic];);
    }
    else  // 无网
    {
        [blockSelf setTarget_:YES];
        if(isChangeOther)
        {
            if (!isAutoUpdate)
            {
                MBHide;
                LMBShow(NONetTip);
            }
        }
    }
}


// 设置目标， 是否提示
-(void)setTarget_:(BOOL)isPrompt
{
    if (isChangeTarget)    // 先发送指令
    {
        if(self.Bluetooth.isLink)
        {
            self.userInfo = [UserInfo MR_findFirstByAttribute:@"access" withValue:myUserInfoAccess inContext:DBefaultContext];
            self.userInfo.user_drink_target = @(newTarget);
            NSTimeInterval inter = [DNow timeIntervalSince1970] * 1000;
            self.userInfo.update_time = @(inter);
            DBSave;
            [self.Bluetooth setUserInfo:self.userInfo.pUUIDString arr:nil];
            if (isPrompt) LMBShow(@"喝水目标设置成功");
            isChangeTarget = NO;
        }
        else
        {
            if (isPrompt) LMBShow(@"请先连接杯垫");
        }
    }
}

-(void)dataSuccessBack_getUserInfo:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
//        self.userInfo = [[UserInfo findByAttribute:@"access" withValue:myUserInfoAccess inContext:DBefaultContext] firstObject];
//        self.userInfo.account            = myUserInfo.account;
//        self.userInfo.logo               = dic[@"user_pic_url"];
//        self.userInfo.user_nick_name     = dic[@"user_nick_name"];
//        self.userInfo.user_gender        = @([(NSString *)dic[@"user_gender"] intValue]);
//        self.userInfo.user_weight        = @([(NSString *)dic[@"user_weight"] doubleValue]);
//        self.userInfo.user_height        = @([(NSString *)dic[@"user_height"] doubleValue]);
//        self.userInfo.user_birthday      = [DFD toDateByString:dic[@"user_birthday"]];
//        self.userInfo.user_language_code = dic[@"user_language_code"];
//        self.userInfo.countryID          = dic[@"user_country_code"];
//        self.userInfo.stateID            = dic[@"user_state_code"];
//        self.userInfo.cityID             = dic[@"user_city_code"];
//        if ([self.userInfo.countryID isEqualToString:@"0"]) {
//            self.userInfo.countryID = @"1";
//            self.userInfo.stateID = @"11";
//        }
        
        long long interServer = [dic[@"update_time"] longLongValue];
        long long interLocal =  [self.userInfo.update_time longLongValue];
        
        // 拉去个人信息的时候， 要判断服务器时间戳是否大于本地
        if (interServer >= interLocal)
        {
            self.userInfo = [UserInfo objectByDictionary:dic
                                                 context:DBefaultContext
                                            perfectBlock:^(id model) {
                                                UserInfo * user = model;
                                                user.account = myUserInfo.account;
                                                if ([user.countryID isEqualToString:@"0"]) {
                                                    user.countryID = @"1";
                                                    user.stateID = @"11";
                                                }
                                            }];
        }else{
            __block NSNumber *update_time  = @([(NSString *)dic[@"update_time"] longLongValue]);
            __block NSNumber *drink_target = @([(NSString *)dic[@"user_drink_target"] longLongValue]);
            self.userInfo = [UserInfo objectByDictionary:dic
                                                 context:DBefaultContext
                                            perfectBlock:^(id model) {
                                                UserInfo * user = model;
                                                user.account = myUserInfo.account;
                                                if ([user.countryID isEqualToString:@"0"]) {
                                                    user.countryID = @"1";
                                                    user.stateID = @"11";
                                                }
                                                user.update_time        = update_time;
                                                user.user_drink_target  = drink_target;
                                            }];
            newTarget = [self.userInfo.user_drink_target integerValue];
            isAutoUpdate = YES;
            isChangeTarget = NO;
            isChangeOther = YES;
            __block vcUser *blockSelf = self;
            NextWaitInMain([blockSelf saveToServer];);
        }
        
        
        // 这里开始结检测
//        if (![self.userInfo.user_weight integerValue]) self.userInfo.user_weight = @(70);
//        if (![self.userInfo.user_height integerValue]) self.userInfo.user_height = @(170);
//        if (![self.userInfo.user_drink_target integerValue]) self.userInfo.user_drink_target = @(2000);
//        DBSave;
        
        [self refreshData];
        [self.tabView reloadData];
    }
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        NSString *update_time = dic[@"update_time"];
        if (!update_time) return;
        self.userInfo.user_nick_name = newNickName;
        self.userInfo.user_gender = @(newGender);
        self.userInfo.user_height = @(newHeight);
        self.userInfo.user_weight = @(newWeight);
        self.userInfo.user_birthday = newBirthDay;
        self.userInfo.user_drink_target = @(newTarget);
        self.userInfo.logo = self.photoUrl;
        
        //NSLog(@"回来的时候 %@，%@，%@", county_S.countryName, state_S.stateName, city_S.cityName);
        
        self.userInfo.countryID = county_S.countryID;
        self.userInfo.stateID = state_S.stateID;
        self.userInfo.cityID = city_S.cityID;
        
        if (!self.userInfo.stateID) self.userInfo.stateID = @"0";
        if (!self.userInfo.cityID) self.userInfo.cityID   = @"0";
        
        
        //NSLog(@"-- self.userinfo :%@ :%@ :%@", self.userInfo.countryID, self.userInfo.stateID, self.userInfo.cityID);
        
        [self setTarget_:NO];
        
        
        //  覆盖服务器的回调 有两种情况
        //  1, 用户更新
        //  2, 自动更新 （本地目标的最新 大于服务器最新）
        //UserInfo *user = myUserInfo;

        long long interServer = [dic[@"update_time"] longLongValue];
        self.userInfo.update_time = @(interServer);
        DBSave;
        
        NSDictionary *dicData = GetUserDefault(IndexData);
        NSArray *arrData = dicData[self.userInfo.access];
        NSInteger waterCount = [arrData[0] integerValue];
        CGFloat target = [self.userInfo.user_drink_target doubleValue];
        NSInteger percent = waterCount / target * 100;
        
        if (self.userInfo.access)       //  防止用户退出 导致的self.userInfo 为nil
        {
            NSDictionary *dic = @{ self.userInfo.access : @[ @(waterCount), @(percent), @(DDDay) ]};
            SetUserDefault(IndexData, dic);
            
            if (!isAutoUpdate) {
                LMBShow(@"个人信息更新成功");
            }
            isAutoUpdate = NO;
            isChangeOther = isChangeTarget = NO;
        }
    }
    else
    {
        NSLog(@"--------------- 保存失败");
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"user_to_orcode"]) {
        vcORCode *con = (vcORCode *)[segue destinationViewController];
        con.orcodeType = UserORCode;
    }
}

-(void)toolCancelBtnClickCompleted
{
    _pickView.dataSource        = nil;
    _pickView.delegate          = nil;
    _pickViewAddress.dataSource = nil;
    _pickViewAddress.delegate   = nil;
}


-(void)toolOKBtnClickAnimation
{
    switch (selectedIndex) {
        case 0:
        {
            isChangeOther = YES;
            NSString *sex = sexShow = _arrSex[selectedPickIndex];
            _arrData[1] = sex;
            newGender = (BOOL)selectedPickIndex;
        }
            break;
        case 1:
        {
            isChangeOther = YES;
            NSString *birth = [[_datePicker date] toString:@"YYYY / MM / dd"];
            _arrData[4] = birth;
            newBirthDay = [_datePicker date] ;
            birthShow = [newBirthDay toString:@"YYYYMMdd"];
        }
            break;
        case 2:
        {
            isChangeOther = YES;
            [self refreshAddress];
        }
            break;
        case 3:
        {
            isChangeOther = YES;
            NSString *height = _arrHeight[selectedPickIndex];
            if ([self.userInfo.unit boolValue])
            {
                heightShow = [NSString stringWithFormat:@"%@", height];
                newHeight = [height doubleValue];
            }
            else
            {
                heightShow = [NSString stringWithFormat:@"%@", height];
                NSArray *arr = [height componentsSeparatedByString:@"'"];
                NSInteger ft = [arr[0] integerValue];
                NSInteger iN = [arr[1] integerValue];
                newHeight = (ft +  (double)iN / 12.0) / CmToFt;
            }
        }
            break;
        case 4:
        {
            isChangeOther = YES;
            NSString *weight = _arrWeigth[selectedPickIndex];
            if ([self.userInfo.unit boolValue])
            {
                weightShow = [NSString stringWithFormat:@"%@", weight];
                newWeight = [weight doubleValue];
            }
            else
            {
                weightShow = [NSString stringWithFormat:@"%@", weight];
                newWeight =  [weight doubleValue] * KgToLb;
            }
        }
            break;
        case 5:
        {
            isChangeTarget = YES;
            targetShow = _arrTarget[selectedPickIndex];
            newTarget = [_arrTarget[selectedPickIndex] integerValue];
            isChangeTarget = newTarget != [self.userInfo.user_drink_target intValue];
        }
            break;
    }
    [_tabView reloadData];
}



@end
