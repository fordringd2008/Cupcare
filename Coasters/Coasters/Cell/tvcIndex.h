//
//  tvcIndex.h
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "DFDAnimationCell.h"
#import "MdIndex.h"
#import "VerticalAlignmentLabel.h"

@class tvcIndex;

@protocol tvcIndexDelegate <NSObject>

-(void)btnClick:(tvcIndex *)sender;

@end

@interface tvcIndex : DFDAnimationCell

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) VerticalAlignmentLabel *lblPrompt;
@property (strong, nonatomic) UILabel *lblPrompt_lbl;
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvTop;
@property (weak, nonatomic) IBOutlet UIImageView *imvRight;


@property (weak, nonatomic) IBOutlet UILabel *lbl2Title;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnRight;  // 右侧按钮的右距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTimeWidth;



@property (assign, nonatomic) BOOL  isNotComeOn;                   // 不含有再接再厉  默认是 nil  如果要求不含有 设置为YES

@property (assign, nonatomic) id<tvcIndexDelegate> delegate;

@property (nonatomic, strong) MdIndex *model;
@property (nonatomic, copy) NSString  *title2;
- (IBAction)btnClick:(id)sender;

- (void)hightLight;


+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
