//
//  tvcCircle.m
//  Coasters
//
//  Created by 丁付德 on 16/6/1.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "tvcCircle.h"

@interface tvcCircle()
{
    __weak IBOutlet UIImageView *imvLogo;
    __weak IBOutlet UILabel *lblTitle;
    __weak IBOutlet UILabel *lblNumber;
    __weak IBOutlet UIButton *btnEdit;
    
}

@end

@implementation tvcCircle


//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    btnEdit.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 0, -25);
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


-(void)setEditClick:(void (^)())editClick
{
    _editClick = editClick;
    if (!editClick){
        btnEdit.hidden = YES;
    }
}


-(void)setGroup:(Group *)group
{
    _group = group;
    [imvLogo sd_setImageWithURL:[NSURL URLWithString:group.group_pic_url] placeholderImage:DefaultCircleLogoImage];
        imvLogo.layer.cornerRadius = (Bigger(RealHeight(115), 70) - 16) / 2;
    imvLogo.layer.masksToBounds = YES;
    lblTitle.text = group.group_name;
    lblNumber.text = [NSString stringWithFormat:@"%@%@", group.group_member_num, kString(@"人")];
    btnEdit.hidden = ![group.is_admin boolValue];
    
}

- (IBAction)btnEditClick:(id)sender {
    if (self.editClick) {
        self.editClick();
    }
}


+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcCircle"; // 这里需要同时设置xib的identifier
    tvcCircle *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcCircle" owner:nil options:nil] lastObject];
    }
    return cell;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
