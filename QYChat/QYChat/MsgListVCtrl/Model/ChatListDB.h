//
//  ChatListDB.h
//  NTChat
//
//  Created by 古秀湖 on 2016/12/5.
//  Copyright © 2016年 南天. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgItem.h"

@interface ChatListDB : NSObject

///初始化
-(id)init;

///插入聊天
- (void)insertData:(MsgItem*)item;

///查询所有的消息列表
-(NSMutableArray*)selectAllMsgList;

@end

