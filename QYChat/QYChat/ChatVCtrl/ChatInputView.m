//
//  ChatInputView.m
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "ChatInputView.h"

@interface ChatInputView()

@end

@implementation ChatInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UI_BASE_COLOR;
 
        //输入框
        self.inputField = [[UITextField alloc] init];
        [self addSubview:self.inputField];
        [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.left.and.right.and.top.and.bottom.equalTo(self);
        }];
        
    }
    return self;
}

@end
