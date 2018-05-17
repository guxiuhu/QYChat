//
//  MsgListCell.m
//  QYChat
//
//  Created by 古秀湖 on 2018/4/19.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "MsgListCell.h"
#import "UIImageView+WebCache.h"

@interface MsgListCell()

///头像
@property (nonatomic, strong) UIImageView *photoImgView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation MsgListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //背景View
        UIView *bgView = [UIView new];
        [bgView setBackgroundColor:UIColorWhite];
        bgView.layer.cornerRadius = 5;
        bgView.layer.shadowColor = UIColorGrayLighten.CGColor;
        bgView.layer.shadowOffset = CGSizeZero;
        bgView.layer.shadowOpacity = 0.5;
        bgView.layer.shadowRadius = 2;
        [self.contentView addSubview:bgView];
        [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.contentView).with.offset(20+26);
            make.right.equalTo(self.contentView).with.offset(-20);
            make.top.equalTo(self.contentView).with.offset(5);
            make.bottom.equalTo(self.contentView).with.offset(-5);
        }];
        
        //头像
        self.photoImgView= [[UIImageView alloc] init];
        self.photoImgView.clipsToBounds = YES;
        self.photoImgView.layer.cornerRadius = 26;
        [self.photoImgView sd_setImageWithURL:[NSURL URLWithString:@"https://pic4.zhimg.com/80/a6f1bd1489bfbf4246798db2f14e211e_hd.jpg"]];
        [self.contentView addSubview:self.photoImgView];
        [self.photoImgView mas_makeConstraints:^(MASConstraintMaker *make) {

            make.width.and.height.mas_equalTo(52);
            make.centerX.equalTo(bgView.mas_left);
            make.centerY.equalTo(bgView);
        }];
        
        //姓名
        self.nameLabel = [UILabel new];
        [self.nameLabel setFont:UIFontMake(15)];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.photoImgView.mas_right).with.offset(10);
            make.right.equalTo(bgView.mas_centerX);
            make.bottom.equalTo(self.photoImgView.mas_centerY);
            make.height.mas_equalTo(18);
        }];
        
        //内容
        self.contentLabel = [UILabel new];
        [self.contentLabel setFont:UIFontMake(13)];
        [self.contentLabel setTextColor:[UIColor colorWithRed:0.584 green:0.588 blue:0.596 alpha:1.00]];
        [self.contentView addSubview:self.contentLabel];
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom).with.offset(3);
            make.height.mas_equalTo(15);
            make.right.equalTo(bgView.mas_right).with.offset(-10);
        }];
    }
    return self;
}

-(void)resetUIWithItem:(MsgItem*)item{

    [self.nameLabel setText:item.messageFrom];
    [self.contentLabel setText:item.messageContent];
}

@end
