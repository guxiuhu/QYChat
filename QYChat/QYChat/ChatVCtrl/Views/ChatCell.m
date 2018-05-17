//
//  ChatCell.m
//  QYChat
//
//  Created by 古秀湖 on 2018/5/13.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "ChatCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <YYText/YYText.h>

@interface ChatCell()

///头像
@property (nonatomic, strong) UIImageView *photoImgView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) YYLabel *contentLabel;

@end

@implementation ChatCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        //时间
        self.timeLabel = [UILabel new];
        [self.timeLabel setTextAlignment:NSTextAlignmentCenter];
        [self.timeLabel setFont:UIFontMake(13)];
        [self.timeLabel setTextColor:UIColorGrayLighten];
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self.contentView).with.offset(10);
            make.left.and.right.equalTo(self.contentView);
            make.height.mas_equalTo(15);
        }];
        
        //背景
        self.bgView = [UIView new];
        self.bgView.layer.cornerRadius = 5;
        self.bgView.layer.shadowColor = UIColorGrayLighten.CGColor;
        self.bgView.layer.shadowOffset = CGSizeZero;
        self.bgView.layer.shadowOpacity = 0.5;
        self.bgView.layer.shadowRadius = 2;
        [self.bgView setBackgroundColor:UIColorWhite];
        [self.contentView addSubview:self.bgView];
        
        //头像
        self.photoImgView= [[UIImageView alloc] init];
        self.photoImgView.clipsToBounds = YES;
        self.photoImgView.layer.cornerRadius = 20;
        [self.photoImgView sd_setImageWithURL:[NSURL URLWithString:@"https://pic4.zhimg.com/80/a6f1bd1489bfbf4246798db2f14e211e_hd.jpg"]];
        [self.contentView addSubview:self.photoImgView];
        
        //内容区
        self.contentLabel = [YYLabel new];
        [self.contentLabel setNumberOfLines:0];
        [self.contentLabel setTextColor:UIColorMakeWithHex(@"#353535")];
        [self.contentLabel setText:@"Hello World"];
        [self.contentView addSubview:self.contentLabel];
    }
    return self;
}

-(void)resetUIWithMsgItem:(MsgItem*)item{
    
    self.contentLabel.attributedText = [[NSAttributedString alloc] initWithString:item.messageContent attributes:@{NSFontAttributeName:UIFontMake(15),NSForegroundColorAttributeName:UIColorMakeWithHex(@"#353535")}];;
    [self.timeLabel setText:item.messageTime];
    
    CGSize size = CGSizeMake(SCREEN_WIDTH-15-40-10-10-30, CGFLOAT_MAX);
    YYTextLayout *layout = [YYTextLayout layoutWithContainerSize:size text:self.contentLabel.attributedText];
    CGFloat textHeight = layout.textBoundingSize.height;
    if (textHeight < 30) {
        textHeight = 30;
    }
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        if (item.msgFrom == MsgFromOthers) {
            make.left.equalTo(self.contentView).with.offset(15+40+10);
        } else {
            make.right.equalTo(self.contentView).with.offset(-(15+40+10));
        }
        make.top.equalTo(self.contentView).with.offset(35+10);;
        make.height.mas_equalTo(textHeight);
        make.width.mas_equalTo(layout.textBoundingSize.width);
    }];
    
    //背景
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        if (item.msgFrom == MsgFromOthers) {
            make.left.equalTo(self.contentView).with.offset(30);
            make.right.equalTo(self.contentLabel).with.offset(10);
        } else {
            make.right.equalTo(self.contentView).with.offset(-30);
            make.left.equalTo(self.contentLabel).with.offset(-10);
        }

        make.top.equalTo(self.contentView).with.offset(35);;
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-10);
        make.height.mas_equalTo(textHeight+20);
    }];

    //头像
    [self.photoImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
        if (item.msgFrom == MsgFromOthers) {
            make.left.equalTo(self.contentView).with.offset(15);
        } else {
            make.right.equalTo(self.contentView).with.offset(-15);
        }

        make.width.and.height.mas_equalTo(40);
        make.bottom.equalTo(self.contentView).with.offset(-8);
    }];
}

@end
