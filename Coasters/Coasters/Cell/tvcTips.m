//
//  tvcTips.m
//  Coasters
//
//  Created by 丁付德 on 15/9/5.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcTips.h"
#import "Tips.h"

@implementation tvcTips

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [_lblContent setVerticalAlignment:VerticalAlignmentTop];
    
    self.contentView.backgroundColor = DLightGrayBlackGroundColor;
    _viewMain.layer.borderColor = DLightGray.CGColor;
    _viewMain.layer.borderWidth = 1;
    _viewMain.layer.cornerRadius = 5;
    _viewMain.layer.masksToBounds = YES;
}

-(void)setModel:(Tips *)model
{
    _model = model;
    _imv.layer.cornerRadius = 10;
    _imv.layer.masksToBounds = YES;
    
    static NSDictionary *dicLoaded;
    if (!dicLoaded) dicLoaded = @{};
    if ([dicLoaded.allKeys containsObject:model.pic_url]) {
        _imv.image = dicLoaded[model.pic_url];
    }else
    {
        __block tvcTips *blockSelf = self;
        __block NSString  *url = model.pic_url;
        [_imv sd_setImageWithURL:[NSURL URLWithString:url]
                placeholderImage:LoadingImage
                         options:SDWebImageDelayPlaceholder
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             __block UIImage *blockImage = image;
             dispatch_async(dispatch_get_global_queue(0, 0), ^
            {
                float imageW = blockImage.size.width;
                float imageH = blockImage.size.height;
                float tag = imageW > imageH ? imageH : imageW;
                float posX = (imageW - tag) / 2;
                float posY = (imageH - tag) / 2;
                CGRect trimArea = CGRectMake(posX, posY, tag, tag);
                CGImageRef srcImageRef = [blockImage CGImage];
                CGImageRef trimmedImageRef = CGImageCreateWithImageInRect(srcImageRef, trimArea);
                blockImage = [UIImage imageWithCGImage:trimmedImageRef];
                blockImage = [blockImage resizedImageFitSize:CGSizeMake(100, 100)];
                dispatch_sync(dispatch_get_main_queue(), ^
                  {
                      dicLoaded = ({
                          NSMutableDictionary *dicTag = [NSMutableDictionary dictionaryWithDictionary:dicLoaded];
                          if (blockImage)  [dicTag setObject:blockImage forKey:url];
                          dicTag;
                      });
                      !blockSelf ?:[blockSelf change:blockImage];
                  });
            });
         }];
    }
    
    _lblTitle.text = model.tip_title;
    _lblTime.text = [model.datetime toString:@"YYYY-MM-dd"];
    _lblContent.text = model.tip_content;
}

-(void)change:(UIImage *)image
{
    _imv.alpha = 0;
    _imv.image = image;
    [UIView animateWithDuration:0.3 animations:^{
        _imv.alpha = 1;
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcTips"; // 标识符
    tvcTips *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcTips" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
