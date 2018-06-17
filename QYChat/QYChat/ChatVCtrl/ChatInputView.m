//
//  ChatInputView.m
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "ChatInputView.h"
#import <YYCategories/YYCategories.h>

@interface ChatInputView()<YYTextViewDelegate>

@property (nonatomic, strong) UIButton *faceBtn;

@property (nonatomic, strong) UIButton *moreBtn;

@property (nonatomic, strong) UIButton *voiceBtn;

@end

@implementation ChatInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UI_BASE_COLOR;
        
        //更多
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreBtn setImage:[UIImage imageNamed:@"input_more"] forState:UIControlStateNormal];
        [self addSubview:self.moreBtn];
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.right.equalTo(self).with.offset(-10);
            make.width.and.height.mas_equalTo(30);
            make.bottom.equalTo(self).with.offset(-10);
        }];
        
        //表情
        self.faceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.faceBtn addTarget:self action:@selector(emotionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.faceBtn setImage:[UIImage imageNamed:@"input_face"] forState:UIControlStateNormal];
        [self addSubview:self.faceBtn];
        [self.faceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.moreBtn.mas_left).with.offset(-10);
            make.width.and.height.mas_equalTo(30);
            make.centerY.equalTo(self.moreBtn);
        }];
 
        //语音
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.voiceBtn setImage:[UIImage imageNamed:@"input_voice"] forState:UIControlStateNormal];
        [self addSubview:self.voiceBtn];
        [self.voiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.centerY.equalTo(self.moreBtn);
            make.width.and.height.mas_equalTo(30);
            make.left.equalTo(self).with.offset(10);
        }];
        
        //表情
        NSMutableDictionary *mapper = [NSMutableDictionary new];
        for (int i = 1; i <= 80; i ++) {
            mapper[[NSString stringWithFormat:@"[face%02d]",i]] = [UIImage imageNamed:[NSString stringWithFormat:@"[face%02d]",i]];
        }
        YYTextSimpleEmoticonParser *parser = [[YYTextSimpleEmoticonParser alloc] init];
        parser.emoticonMapper = mapper;
        
        //输入框
        self.textView = [[YYTextView alloc] initWithFrame:CGRectMake(10+30+5, 5, SCREEN_WIDTH-10-30-5-10-30-10-30-10, 40)];
        [self.textView setBackgroundColor:UI_BASE_COLOR];
        [self.textView setPlaceholderFont:UIFontMake(18)];
        [self.textView setPlaceholderTextColor:UIColorMakeWithHex(@"#fafafa")];
        [self.textView setPlaceholderText:@"请输入..."];
        [self.textView setFont:UIFontMake(18)];
        [self.textView setTintColor:UIColorWhite];
        [self.textView setDelegate:self];
        [self.textView setTextColor:UIColorWhite];
        self.textView.textParser = parser;
        [self addSubview:self.textView];
        
        //画条线
        UIView *lineView = [UIView new];
        [lineView setBackgroundColor:UIColorWhite];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.bottom.equalTo(self.textView);
            make.height.mas_equalTo(PixelOne);
        }];
    }
    return self;
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    if ([text isEqualToString:@"\n"]) {
        if (![textView.text isEqualToString:@""]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatSendText:)]) {
                [self.delegate chatSendText:textView.text];
            }
        }

        return NO;
    } else {
        return YES;
    }
}

///点击表情按钮
-(void)emotionAction:(id)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickEmotionBtn)]) {
        [self.delegate clickEmotionBtn];
    }
}
@end
