//
//  tvcFriendRequest.m
//  Coasters
//
//  Created by 丁付德 on 15/9/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcFriendRequest.h"

@interface tvcFriendRequest()
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UILabel *lblBtn;

- (IBAction)btnClick:(UIButton *)sender;

@end

@implementation tvcFriendRequest

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setModel:(RequestFr *)model
{
    _model = model;
    self.imv.layer.cornerRadius = (Bigger(RealHeight(100), 55) - 16) / 2 ;
    self.imv.layer.borderWidth = 1;
    self.imv.layer.borderColor = DLightGrayBlackGroundColor.CGColor;
    [self.imv.layer setMasksToBounds:YES];
    [self.imv sd_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:DefaultLogo_Gender([model.user_gender boolValue])];
    self.lblName.text = model.name;
    [self.btnRight setBackgroundImage:[UIImage imageFromColor:DLightGray] forState:UIControlStateHighlighted];
    if (!model.isOver)
    {
        self.lblBtn.text = kString(@"接受");
        self.btnRight.layer.cornerRadius = 5;
        self.btnRight.layer.borderWidth = 1;
        self.btnRight.layer.borderColor = DLightGray.CGColor;
        [self.btnRight setBackgroundColor:DWhite];
    }
    else
    {
        self.lblBtn.text = kString(@"已接受");
        self.btnRight.hidden = YES;
        self.btnRight.enabled = NO;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFriendRequest"; // 标识符
    tvcFriendRequest *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFriendRequest" owner:nil options:nil] lastObject];
    }
    return cell;
}
- (IBAction)btnClick:(UIButton *)sender
{
    if (!self.model.isOver) {
        [self.delegateA accept:self.model];
        sender.enabled = NO;
    }
}









@end
