//
//  tvcFriendRank.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcFriendRank.h"

@implementation tvcFriendRank

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imv.layer.cornerRadius = (self.bounds.size.height - 16 ) / 2;
    self.imv.layer.borderWidth = 1;
    self.imv.layer.borderColor = DLightGrayBlackGroundColor.CGColor;
    [self.imv.layer setMasksToBounds:YES];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setModel:(Friend *)model
{
    _model = model;
    [self.imv sd_setImageWithURL:[NSURL URLWithString:model.user_pic_url] placeholderImage:DefaultLogo_Gender([model.user_gender boolValue])];
    self.lblName.text = model.user_nick_name;
    self.lblValue.text = [NSString stringWithFormat:@"%@ml", model.waterCount];
    self.lblLikeNumber.text = [model.like_num description];
    
    int kDate = [DFD HmF2KNSDateToInt:DNow];
    if (([model.last_like_kDate intValue] == kDate)) {
        self.imvHeart.image = [UIImage imageNamed:@"like"];
    }else{
        self.imvHeart.image = [UIImage imageNamed:@"unlike"];
    }
}

-(void)setFgModel:(FriendInGlobal *)fgModel
{
    _fgModel = fgModel;
    [self.imv sd_setImageWithURL:[NSURL URLWithString:fgModel.url] placeholderImage:DefaultLogo_Gender([fgModel.user_gender boolValue])];
    
    self.lblName.text = fgModel.nick_name;
    self.lblValue.text = [fgModel.waterCount description];
    self.lblValue.text = [NSString stringWithFormat:@"%@ml", fgModel.waterCount];
    self.lblNumber.text = [fgModel.rank description];
    self.lblLikeNumber.hidden = self.imvHeart.hidden = YES;
    self.btnlike.enabled = NO;
    self.lblValueRight.constant = -10;
    if(self.isMySelf)
    {
        self.lblNameTop.hidden = self.lblNameBottom.hidden = NO;
        self.lblName.hidden = self.lblNumber.hidden = YES;
        self.lblNameTop.text = self.lblName.text;
        self.lblNameBottom.text = [DFD getLanguage] == 1 ? [NSString stringWithFormat:@"第 %@ 名", self.lblNumber.text]:[NSString stringWithFormat:@"NO.%@ ", self.lblNumber.text];
    }
}

-(void)setIsLiked:(BOOL)isLiked
{
    _isLiked = isLiked;
    self.imvHeart.layer.contents = (id)[UIImage imageNamed:@"like"].CGImage;
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(1.5)];
    k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    [self.imvHeart.layer addAnimation:k forKey:@"SHOW"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFriendRank"; // 标识符
    tvcFriendRank *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFriendRank" owner:nil options:nil] lastObject];
    }
    return cell;
}
- (IBAction)btnClick:(id)sender
{
    if (self.isLiked) return;
    self.isLiked = YES;
    
    if ([self.delegate respondsToSelector:@selector(btnClickLike:)]) {
        [self.delegate btnClickLike:self];
    }
}











@end
