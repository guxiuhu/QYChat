//
//  MsgListVCtrl.m
//  QYChat
//
//  Created by 古秀湖 on 2018/4/18.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "MsgListVCtrl.h"
#import "MsgListCell.h"
#import "IMClientManager.h"
#import "ChatTransDataEvent.h"
#import "MsgListItem.h"
#import "ChatVCtrl.h"
#import "ChatListDB.h"

@interface MsgListVCtrl ()<UITableViewDelegate,UITableViewDataSource,QYChatDelegate>

///列表
@property (nonatomic, strong) UITableView *tableView;

///数据源
@property (nonatomic, strong) NSMutableArray *sourceAry;

@end

@implementation MsgListVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"消息";

    self.sourceAry = [NSMutableArray new];
    self.hidesBottomBarWhenPushed = NO;
    
    //列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom).with.offset(5);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    
    [PublicMethods setExtraCellLineHidden:self.tableView];
    
    //消息监听
    [[IMClientManager sharedInstance].getTransDataListener setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.sourceAry removeAllObjects];
    
    ChatListDB *chatListDB = [[ChatListDB alloc] init];
    [self.sourceAry addObjectsFromArray:[chatListDB selectAllMsgList]];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"MsgListCell";
    MsgListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    MsgListItem *item = [self.sourceAry objectAtIndex:indexPath.row];
    [cell resetUIWithItem:item];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MsgListItem *item = [self.sourceAry objectAtIndex:indexPath.row];

    ChatVCtrl *chat = [[ChatVCtrl alloc] init];
    chat.messageFrom = item.messageFrom;
    [self.navigationController pushViewController:chat animated:YES];
}

-(void)receviedMsgWithContent:(NSString *)msgContent andFrom:(NSString *)from{
    
    MsgListItem *item = [[MsgListItem alloc] init];
    item.messageFrom = from;
    item.messageContent = msgContent;
    item.messageTime = @"2012-1-1";
    
    //入库
    ChatListDB *chatListDB = [[ChatListDB alloc] init];
    [chatListDB insertData:item];
    
    for (int i = 0; i < self.sourceAry.count; i ++) {
        
        MsgListItem *item = [self.sourceAry objectAtIndex:i];
        if ([item.messageFrom isEqualToString:from]) {
            
            [self.sourceAry removeObjectAtIndex:i];
            break;
        }
    }
    
    [self.sourceAry insertObject:item atIndex:0];
    [self.tableView reloadData];
}
@end
