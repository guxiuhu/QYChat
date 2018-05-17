//
//  ChatInputView.h
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYChatInputDelegate<NSObject>

-(void)chatSendText:(NSString*)text;

-(void)inputTextViewHeightChanged:(CGFloat)height;

@end

@interface ChatInputView : UIView

@property (nonatomic, weak) id<QYChatInputDelegate> delegate;

///输入控件
@property (nonatomic, strong) QMUITextView *inputView;

@end
