//
//  tvcIndex.m
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcIndex.h"

@implementation tvcIndex

- (void)awakeFromNib {
    [super awakeFromNib];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (![DFD isSysTime24]) {
        self.lblTimeWidth.constant = 60;
    }
}

-(void)setModel:(MdIndex *)model
{
    [self.lbl2Title setHidden:YES];
    [self.imvRight setHidden:YES];
    self.btn.hidden = YES;
    _imvTop.constant = (Bigger(RealHeight(100), 50) - 20) / 2;  // 20 为图片的高度
    _model = model;
    
    
    self.lblTime.text = [DFD getTimeStringFromDate:model.date];
    switch (model.type) {
        case 1:
            self.imv.image = [UIImage imageNamed:MDIndexType1];
            break;
        case 2:
            self.imv.image = [UIImage imageNamed:MDIndexType2];
            break;
        case 3:
            self.imv.image = [UIImage imageNamed:MDIndexType3];
            break;
        case 4:
            self.imv.image = [UIImage imageNamed:MDIndexType4];
            break;
        case 5:
            self.imv.image = [UIImage imageNamed:MDIndexType5];
            break;
        case 6:
            self.imv.image = [UIImage imageNamed:MDIndexType6];
            break;
            
        default:
            break;
    }
    
    
    
    /*
     // 1: 最近喝水
     // 2: 喝水
     // 3: 江华提醒你该喝水了 (知道了)                  这个是好友提醒的（推送）
     // 4: 你今天喝水已经达到目标了（的一半） 你已经多久没喝水了
     // 5: 江华加你为好友    （确定）                   这个是好友提醒的（推送）
     // 6: 江华已经接受了你的好友申请
     // 7:
     // 8:
     */
    
    
    CGFloat titleHeight;
    CGFloat left = [DFD isSysTime24] ? 90:([DFD getLanguage] == 1 ? 102:98);
    CGFloat titleTop = (Bigger(RealHeight(100), 50) - 21) / 2 + 2;
    if (model.type == 3 || model.type == 4 || model.type == 5|| model.type == 6)  // 这里是多行显示 多行，不代表有按钮
    {
        self.lblPrompt = [[VerticalAlignmentLabel alloc] init];
        self.lblPrompt.lineBreakMode = NSLineBreakByCharWrapping;
        [self.lblPrompt setVerticalAlignment:VerticalAlignmentTop];
        self.lblPrompt.numberOfLines = 0;
        self.lblPrompt.font = [UIFont systemFontOfSize:14];
        
        self.lblPrompt.text = model.msg;
        CGFloat tag = (model.type == 3 || model.type == 5) ? 160 : 105;   // 3. 5 有按钮
        titleHeight = [DFD getTextSizeWith:model.msg fontNumber:14 biggestWidth:(ScreenWidth - tag)].height;
        self.lblPrompt.frame = CGRectMake(left, titleTop, ScreenWidth - tag, titleHeight);
        [self.contentView addSubview:self.lblPrompt];
    }
    else  // 因为没有按钮 ，可以继续右伸
    {
        self.lblPrompt_lbl = [[UILabel alloc] initWithFrame:CGRectMake(left, titleTop-2, ScreenWidth - left - 5, 21)];
        self.lblPrompt_lbl.font = [UIFont systemFontOfSize:14];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", model.msg, model.msgML ? model.msgML : @""]];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(model.msg.length, str.length - model.msg.length)];
        self.lblPrompt_lbl.attributedText = str;
        if([model.msgML intValue] > 100 && !self.isNotComeOn)
        {
            NSMutableAttributedString *newStr = [[NSMutableAttributedString alloc] initWithAttributedString:str];
            [newStr appendAttributedString:[[NSMutableAttributedString alloc] initWithString: kString(@" 再接再厉吧 !")]];
            self.lblPrompt_lbl.attributedText = newStr;
        }
        [self.contentView addSubview:self.lblPrompt_lbl];
    }
    
    if (model.type == 3) //  || model.type == 6
    {
        self.btn.hidden = NO;
        if (model.isOver)
        {
            [self.btn setTitle:kString(@"已知道") forState:UIControlStateNormal];
            [self.btn setBackgroundImage:[UIImage imageFromColor:DWhite] forState:UIControlStateNormal];
            [self.btn setBackgroundColor:DWhite];
            self.btn.enabled = NO;
        }
        else
        {
            [self.btn setTitle:kString(@"知道了") forState:UIControlStateNormal];
            [self.btn setBackgroundImage:[UIImage imageNamed:@"btn_yellow"] forState:UIControlStateNormal];
            self.btn.enabled = YES;
        }
    }
    else if (model.type == 5)
    {
        self.btn.hidden = NO;
        if (model.isOver)
        {
            [self.btn setTitle:kString(@"已接受") forState:UIControlStateNormal];
            [self.btn setBackgroundImage:[UIImage imageFromColor:DWhite] forState:UIControlStateNormal];
            [self.btn setBackgroundColor:DWhite];
            self.btn.enabled = NO;
        }
        else
        {
            [self.btn setTitle:kString(@"接受") forState:UIControlStateNormal];
            [self.btn setBackgroundImage:[UIImage imageNamed:@"btn_yellow"] forState:UIControlStateNormal];
            self.btn.enabled = YES;
        }
    }
    else
    {
        [self.btn setHidden:YES];
    }
    
    if (!self.btn.hidden && [DFD getLanguage] != 1)
    {
        self.btnRight.constant = 5;
        [self.btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, -10)];
    }else
    {
        self.btnRight.constant = 10;
        [self.btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    
//    Border(self.btn, DRed);
    
}

-(void)setTitle2:(NSString *)title2
{
    self.lbl2Title.text = title2;
    [self.imv setHidden:YES];
    [self.lblTime setHidden: YES];
    [self.btn setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)btnClick:(id)sender
{
    [self.delegate btnClick:self];
}

- (void)hightLight
{
    self.contentView.backgroundColor = RGB(247, 109, 32);
    [UIView transitionWithView:self.contentView duration:2 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.contentView setBackgroundColor:DWhite];
    } completion:^(BOOL finished) {}];
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcIndex"; // 标识符
    tvcIndex *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcIndex" owner:nil options:nil] lastObject];
    }
    return cell;
}




@end
