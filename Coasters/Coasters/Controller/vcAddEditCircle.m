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
//  Created by 丁付德 on 16/6/1.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcAddEditCircle.h"
#import "tvcUser.h"
#import "UIViewController+GetAccess.h"
#import "Country.h"
#import "State.h"
#import "City.h"
#import "TAlertView.h"
#import "HJCActionSheet.h"
#import "NSString+Verify.h"

#pragma mark - 宏命令

@interface vcAddEditCircle ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, HJCActionSheetDelegate>
{
    UITableView *   tabView;
    UIVisualEffectView *effectView;
    UIVisualEffectView *effectViewHead;
    UIView *        _bgView;
    UIPickerView*   _pickViewAddress;
    
    NSString *      newCircleName;
    NSString *      address;               // 数据源中 地址显示
    NSString*       photoUrl;
    
    NSArray *       arrCountry;
    NSArray *       arrState;
    NSArray *       arrCity;
    
    Country *       county_S;              // 用户穿进来的对象   （ 还没有点确定之前的存放 ）
    State  *        state_S;               // 用户穿进来的对象
    City   *        city_S;                // 用户穿进来的对象
    
    int             indexCountry;
    int             indexState;
    int             indexCity;
    
    
    NSNumber *      language;
    
    BOOL isChange;                         // 是否有变动
}

@end

@implementation vcAddEditCircle

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButton:nil text: (!_group ? @"创建圈子" : @"编辑信息") ];
    [self initRightButton:@"save" text:nil];
    
    photoUrl = @"";
    language = @([DFD getLanguage]);
    
    [self refreshData];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    __block vcAddEditCircle *blockSelf = self;
    self.upLoad_Next = ^(NSString *url)
    {
        if(!url.length)
        {
            NSLog(@"图片上传失败");
            LMBShowInBlock(NONetTip);
        }else
        {
            blockSelf->photoUrl = url;
            [blockSelf saveToServer];
        }
    };
    
}


-(void)viewWillDisappear:(BOOL)animated
{
    self.upLoad_Next = nil;
    [super viewWillDisappear:animated];
}


- (void)dealloc
{
    [self.ViewEffectHead removeFromSuperview];
    [self.ViewEffectBody removeFromSuperview];
    NSLog(@"vcAddEditCircle销毁了");
}


-(void)rightButtonClick
{
    if (!newCircleName.length) {
        LMBShow(@"名称未填写");
        return;
    }
    if ([newCircleName rangeOfString:@"null"].length || [newCircleName rangeOfString:@"nil"].length || [newCircleName rangeOfString:@"NULL"].length || [NSString isHaveEmoji:newCircleName]) {
        LMBShow(@"昵称中包含了不能识别的字符");
        return;
    }
    
    if (!isChange){
        LMBShow(@"没有修改");
        return;
    }
    
    MBShowAll;
    HDDAF;
    
    if (self.image)                               // 如果用户更改了图片
        [self getTokenAndUpload];
    else
        [self saveToServer];
}

-(void)saveToServer
{
    NSString *stateID = state_S.stateID ? state_S.stateID :@"0";
    NSString *cityID  = city_S.cityID ? city_S.cityID :@"0";
    
    __block vcAddEditCircle *blockSelf = self;
    RequestCheckAfter(
          [net updateGroupInfo:blockSelf.userInfo.access
                      group_id:(blockSelf.group ? blockSelf.group.group_id:@"0")
                 group_pic_url:blockSelf->photoUrl
                    group_name:blockSelf->newCircleName
            group_country_code:blockSelf->county_S.countryID
              group_state_code:stateID
               group_city_code:cityID];
          , [blockSelf dataSuccessBack_updateGroupInfo:dic];);
}


// 初始化数据
- (void)refreshData
{
    NSString *country_ID = _group?_group.group_country_code:self.userInfo.countryID;
    NSString *state_ID   = _group?_group.group_state_code:self.userInfo.stateID;
    NSString *city_ID    = _group?_group.group_city_code:self.userInfo.cityID;
    
    county_S = [Country findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and countryID == %@", language, country_ID] inContext:DBefaultContext];
    NSLog(@"国家:%@ %@", county_S.countryName, county_S.countryID);
    
    state_S = [State findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and country == %@ and stateID == %@", language, county_S, state_ID] inContext:DBefaultContext];
    
    NSLog(@"地区:%@ %@", state_S.stateName, state_S.stateID);
    city_S = [City findFirstWithPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@ and cityID == %@", language, state_S, city_ID] inContext:DBefaultContext];
    NSLog(@"城市:%@ %@", city_S.cityName, city_S.cityID);
    
    arrCountry = [Country MR_findAllSortedBy:@"countryID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@", language] inContext:DBefaultContext];
    
    arrState = [State MR_findAllSortedBy:@"stateID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and country == %@",language, county_S] inContext:DBefaultContext];
    arrCity = [City MR_findAllSortedBy:@"cityID" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"language == %@ and state == %@",language, state_S] inContext:DBefaultContext];
    
    
    indexCountry = 0;
    indexState   = 11;
    indexCity    = -1;
    
    indexCountry     = (int)[arrCountry indexOfObject:county_S];
    if(state_S)
        indexState   = (int)[arrState indexOfObject:state_S];
    if(city_S)
        indexCity    = (int)[arrCity indexOfObject:city_S];
    
    photoUrl = _group ? _group.group_pic_url : @"";
    newCircleName = _group.group_name;
    [self refreshAddress];
}

// 初始化布局控件
- (void)initView
{
    tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    tabView.dataSource = self;
    tabView.delegate = self;
    tabView.showsVerticalScrollIndicator = NO;
    tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.view addSubview:tabView];
    tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        view.backgroundColor = tabView.backgroundColor;
        view;
    });
    
    __block vcAddEditCircle *blockSelf = self;
    NextWaitInMain(
           [blockSelf initViewCover:300];
           [blockSelf initPickerView];);
}

#pragma mark - ------------------------------------- api实现

#pragma mark - ------------------------------------- 数据变更事件
#pragma mark 1 notification                     通知

#pragma mark 2 KVO                              KVO

#pragma mark - ------------------------------------- UI视图事件
#pragma mark 1 target-action                    普通

#pragma mark 2 delegate dataSource protocol     代理协议、
#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 3;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcUser *cell = [tvcUser cellWithTableView:tableView];
    if (indexPath.row == 0) {
        cell.imvBig.hidden = NO;
        cell.lblTitle.text = kString(@"圈子头像");
        cell.imvBig.layer.borderWidth = 1;
        cell.imvBig.layer.borderColor = DLightGray.CGColor;
        cell.imvBigHeight.constant = Bigger(RealHeight(120), 70) * 0.8;
        cell.imvBig.layer.cornerRadius = cell.imvBigHeight.constant / 2;
        [cell.imvBig.layer setMasksToBounds:YES];
        if (self.image)
            cell.imvBig.image = self.image;
        else
            [cell.imvBig sd_setImageWithURL:[NSURL URLWithString:_group.group_pic_url] placeholderImage:DefaultCircleLogoImage];
        
    }else if (indexPath.row == 1){
        cell.imvBig.hidden = YES;
        cell.lblTitle.text = kString(@"圈子名称");
        cell.lblValue.text = newCircleName;
    }else{
        cell.imvBig.hidden = YES;
        cell.lblTitle.text = kString(@"所在城市");
        cell.lblValue.text = address;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !indexPath.row ? Bigger(RealHeight(120), 70) : Bigger(RealHeight(90), 60);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            HJCActionSheet *sheet = [[HJCActionSheet alloc] initWithDelegate:self CancelTitle:kString(@"取消") OtherTitles:kString(@"拍照"), kString(@"从手机相册中选择"), nil];
            [sheet show];
            
//            TAlertView *alter = [[TAlertView alloc] initWithTitle:@"修改头像" message:@""];
//            [alter showActionCamera:^{
//                [DFD getPictureFormPhotosOrCamera:NO
//                                               vc:self
//                                checekBeforeBlock:^{[self getAccessNext:CameraAccess block:^{}];}];
//            } photoA:^{
//                [DFD getPictureFormPhotosOrCamera:YES
//                                               vc:self
//                                checekBeforeBlock:^{ [self getAccessNext:PhotosAccess block:^{}];}];
//            }];
        }
            break;
        case 1:
        {
            TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入新名称" message:@""];
            alterAccount.strOriginal = newCircleName;
            [alterAccount showWithTXFActionSure:^(id str) {
                isChange = YES;
                newCircleName = str;
                newCircleName = newCircleName.length > 20 ? [newCircleName substringToIndex:20] : newCircleName;
                [tabView reloadData];
            } cancel:^{} keyboardType:UIKeyboardTypeDefault];
        }
            break;
        case 2:
            _pickViewAddress.delegate = self;
            _pickViewAddress.dataSource = self;
            if (indexCountry >= 0) [_pickViewAddress selectRow:indexCountry inComponent:0 animated:NO];
            if (indexState >= 0)   [_pickViewAddress selectRow:indexState inComponent:1 animated:NO];
            if (indexCity >= 0)    [_pickViewAddress selectRow:indexCity inComponent:2 animated:NO];
            [_pickViewAddress reloadAllComponents];
            [self showViewCover];
            
            break;
    }
}

#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return arrCountry.count;
        case 1:
            return arrState.count;
        case 2:
            return arrCity.count;
    }
    return 0;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
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

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
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
    isChange = YES;
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.image = image;
    [tabView reloadData];
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark - ------------------------------------- 私有方法
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
-(void)initPickerView
{
    _pickViewAddress = [[UIPickerView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 256, ScreenWidth, ((IPhone4 || (int)SystemVersion < 9) ? 286 : 256) - NavBarHeight)];
    _pickViewAddress.backgroundColor = DWhite;
    [self.ViewCover addSubview:_pickViewAddress];
}


-(void)toolOKBtnClickAnimation
{
    isChange = YES;
    [self refreshAddress];
    [tabView reloadData];
}

-(void)toolCancelBtnClickCompleted
{
    _pickViewAddress.delegate = nil;
    _pickViewAddress.delegate = nil;
}


-(void)dataSuccessBack_updateGroupInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK)
    {
        NSString *strMessage = @"更新成功";
        if (!_group)
        {
            strMessage = @"创建成功";
            _group                      = [Group MR_createEntityInContext:DBefaultContext];
            _group.access               = self.userInfo.access;
            _group.is_admin             = @YES;
            _group.is_around            = @NO;
            _group.admin_userid         = [self.userInfo.user_id description];
            _group.admin_user_pic_url   = self.userInfo.logo;
            _group.admin_user_nick_name = self.userInfo.user_nick_name;
            _group.group_pic_url        = photoUrl;
        }
        
        _group.group_id           = dic[@"group_id"];
        _group.update_time        = @([dic[@"update_time"] longLongValue]);
        _group.group_name         = newCircleName;
        _group.group_pic_url      = photoUrl;
        _group.group_country_code = county_S.countryID;
        _group.group_state_code   = state_S.stateID;
        _group.group_city_code    = city_S.cityID;
        
        DBSave;
        
        if (self.editOKBlock) {
            _editOKBlock(_group);
        }
        LMBShow(strMessage);
        __block vcAddEditCircle *blockSelf = self;
        NextWaitInMainAfter([blockSelf back];, 1);
    }
}

#pragma mark - ------------------------------------- 属性实现

#pragma mark -





































@end
