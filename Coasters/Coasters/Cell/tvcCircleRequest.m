//
//  tvcCircleRequest.m
//  Coasters
//
//  Created by 丁付德 on 16/6/2.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcCircleRequest.h"

@interface tvcCircleRequest()

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblNext;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UILabel *lblBtn;

@end

@implementation tvcCircleRequest

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imv.layer.cornerRadius  = (Bigger(RealHeight(100), 60) - 8) / 2;
    _imv.layer.masksToBounds = YES;
    
    
    [_btnRight setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    _lblBtn.text = kString(@"接受");
    _btnRight.layer.cornerRadius = 5;
    _btnRight.layer.borderWidth = 1;
    _btnRight.layer.borderColor = DLightGray.CGColor;
    [_btnRight setBackgroundColor:DWhite];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)setFr:(FriendRequest *)fr
{
    _fr = fr;
    [_imv sd_setImageWithURL:[NSURL URLWithString:fr.user_pic_url] placeholderImage:DefaultLogo_Gender([fr.user_gender boolValue])];
    _lblName.text = fr.friend_name;
    _lblNext.text = [NSString stringWithFormat:@"%@ %@", kString(@"申请加入"), fr.group_name];
}


- (IBAction)btnClick:(UIButton *)sender
{
    if (_acceptRequest) {
        _acceptRequest();
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcCircleRequest"; // 标识符
    tvcCircleRequest *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcCircleRequest" owner:nil options:nil] lastObject];
    }
    return cell;
}

@end
