
//
//  ChatListDB.m
//  NTChat
//
//  Created by 古秀湖 on 2016/12/5.
//  Copyright © 2016年 南天. All rights reserved.
//

#import "ChatListDB.h"
#import "FMDB.h"
#import "ClientCoreSDK.h"
#import <MJExtension/MJExtension.h>

static NSString *CHAT_LIST_TABLE_NAME   = @"table_chat_list";//数据表名

static NSString *CHAT_ID                    = @"chat_id";//消息id
static NSString *CHAT_MSG_CONTENT           = @"messageContent";//最后一条消息内容
static NSString *CHAT_MSG_CHAT_FROM_ID      = @"messageFrom";//对方的id
static NSString *CHAT_MSG_CHAT_MY_ID        = @"chat_msg_chat_my_id";//我的id
static NSString *CHAT_MSG_TIME              = @"messageTime";//最后一条消息的时间

@interface ChatListDB (){
    FMDatabase *db;
}

@end

@implementation ChatListDB

///初始化
-(id)init{
    
    self = [super init];
    if (self) {
        
        NSString * database_path = [[PublicMethods getDirectoryOfDocumentFolder] stringByAppendingPathComponent:DB_NAME];
        
        db = [FMDatabase databaseWithPath:database_path];
        
        if ([db open]) {
            
            NSString *sqlCreateTable = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS '%@' (%@ INTEGER PRIMARY KEY AUTOINCREMENT, %@ TEXT, %@ TEXT UNIQUE, %@ TEXT, %@ TEXT)",CHAT_LIST_TABLE_NAME,CHAT_ID,CHAT_MSG_CONTENT,CHAT_MSG_CHAT_FROM_ID,CHAT_MSG_TIME,CHAT_MSG_CHAT_MY_ID];
            [db executeUpdate:sqlCreateTable];
            
            [db close];
            
        }else {
            DDLogError(@"数据库打开失败");
        }
    }
    
    return self;
}

///插入聊天
- (void)insertData:(MsgItem*)item{

    [db open];
    NSString *insertSql = [NSString stringWithFormat:
                           @"INSERT INTO '%@' ('%@','%@','%@','%@') VALUES ('%@','%@','%@','%@')", CHAT_LIST_TABLE_NAME,CHAT_MSG_CONTENT,CHAT_MSG_CHAT_FROM_ID,CHAT_MSG_TIME,CHAT_MSG_CHAT_MY_ID,item.messageContent,item.messageFrom,item.messageTime,[ClientCoreSDK sharedInstance].currentLoginToken];
    BOOL result = [db executeUpdate:insertSql];
    if (!result) {
        
        DDLogError(@"数据库插入消息失败");
    }
    
    [db close];
}

///查询所有的消息列表
-(NSMutableArray*)selectAllMsgList{

    NSMutableArray *ary = [[NSMutableArray alloc]init];

    NSString *userID = [ClientCoreSDK sharedInstance].currentLoginToken;
    if (!userID) {

        DDLogError(@"丢失了保存的用户id，获取数据失败");
        return ary;
    }

    if ([db open]) {
        NSString *sqlQuery = [NSString stringWithFormat:@"SELECT * FROM %@ where %@='%@' order by %@ desc",CHAT_LIST_TABLE_NAME,CHAT_MSG_CHAT_MY_ID,userID,CHAT_MSG_TIME];
        FMResultSet * rs = [db executeQuery:sqlQuery];
        while ([rs next]) {

            NSDictionary *tmpDic = [rs resultDictionary];
            [ary addObject:[MsgItem mj_objectWithKeyValues:tmpDic]];
        }
        [db close];
    }

    return ary;
}

@end
