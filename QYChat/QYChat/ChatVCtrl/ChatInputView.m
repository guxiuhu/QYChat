//
//  ChatInputView.m
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "ChatInputView.h"

@interface ChatInputView()<QMUITextViewDelegate>

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
        
        //输入框
        self.inputView = [[QMUITextView alloc] init];
        [self.inputView setBackgroundColor:UI_BASE_COLOR];
        [self.inputView setPlaceholderColor:UIColorMakeWithHex(@"#fafafa")];
        [self.inputView setPlaceholder:@"请输入..."];
        [self.inputView setFont:UIFontMake(18)];
        [self.inputView setTintColor:UIColorWhite];
        [self.inputView setReturnKeyType:UIReturnKeySend];
        [self.inputView setDelegate:self];
        self.inputView.autoResizable = YES;
        [self.inputView setTextColor:UIColorWhite];
        [self.inputView setShowsVerticalScrollIndicator:NO];
        [self.inputView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:self.inputView];
        [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.equalTo(self).with.offset(5);
            make.bottom.equalTo(self).with.offset(-5);
            make.left.equalTo(self.voiceBtn.mas_right).with.offset(5);
            make.right.equalTo(self.faceBtn.mas_left).with.offset(-10);
        }];
        
        //画条线
        UIView *lineView = [UIView new];
        [lineView setBackgroundColor:UIColorWhite];
        [self addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.bottom.equalTo(self.inputView);
            make.height.mas_equalTo(PixelOne);
        }];
    }
    return self;
}

-(BOOL)textViewShouldReturn:(QMUITextView *)textView{
    
    if (![textView.text isEqualToString:@""]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatSendText:)]) {
            [self.delegate chatSendText:textView.text];
        }
        
        [textView setText:@""];
    }
    
    return YES;
}

-(void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputTextViewHeightChanged:)]) {
        [self.delegate inputTextViewHeightChanged:height+10];
    }
}

///点击表情按钮
-(void)emotionAction:(id)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickEmotionBtn)]) {
        [self.delegate clickEmotionBtn];
    }
}
@end
