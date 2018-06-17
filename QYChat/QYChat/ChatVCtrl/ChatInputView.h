//
//  ChatInputView.h
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText/YYText.h>

@protocol QYChatInputDelegate<NSObject>

///发送文字消息
-(void)chatSendText:(NSString*)text;

///点击表情按钮
-(void)clickEmotionBtn;

-(void)inputTextViewHeightChanged:(CGFloat)height;

@end

@interface ChatInputView : UIView

@property (nonatomic, weak) id<QYChatInputDelegate> delegate;

///输入控件
@property (nonatomic, strong) YYTextView *textView;

@end
