//
//  MsgListItem.h
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgListItem : NSObject

///消息内容
@property (nonatomic, strong) NSString *messageContent;

///消息发送者
@property (nonatomic, strong) NSString *messageFrom;

///时间
@property (nonatomic, strong) NSString *messageTime;
@end
