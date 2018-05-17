//
//  ChatVCtrl.m
//  QYChat
//
//  Created by 古秀湖 on 2018/5/3.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "ChatVCtrl.h"
#import "ChatInputView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import <YYCategories/YYCategories.h>
#import <pop/pop.h>
#import "IMClientManager.h"
#import "MsgItem.h"
#import "ChatCell.h"
#import "LocalUDPDataSender.h"
#import "ClientCoreSDK.h"

@interface ChatVCtrl ()<UITableViewDataSource,UITableViewDelegate,QMUIKeyboardManagerDelegate,QYChatDelegate,QYChatInputDelegate>

@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) ChatInputView *chatInputView;
@property (nonatomic, strong) NSMutableArray *sourceAry;

@end

@implementation ChatVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sourceAry = [NSMutableArray new];
    
    [self.view setBackgroundColor:UIColorWhite];
    self.title = self.messageFrom;
    
    //消息监听
    [[IMClientManager sharedInstance].getTransDataListener setDelegate:self];
    
    //输入控件
    self.chatInputView = [[ChatInputView alloc] initWithFrame:CGRectMake(0, self.view.bottom-50, SCREEN_WIDTH, 50)];
    [self.chatInputView setDelegate:self];
    [self.view addSubview:self.chatInputView];
    
    //列表
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    self.chatTableView.estimatedRowHeight = 100;
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
    [self.view addSubview:self.chatTableView];
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
        make.bottom.equalTo(self.chatInputView.mas_top);
    }];
    
    [PublicMethods setExtraCellLineHidden:self.chatTableView];
    
    _keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
    //设置键盘只接受 self.textView 的通知事件，如果当前界面有其他 UIResponder 导致键盘产生通知事件，则不会被接受
    [self.keyboardManager addTargetResponder:self.chatInputView.inputView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ChatCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    [cell resetUIWithMsgItem:self.sourceAry[indexPath.row]];
    return cell;
}

#pragma mark - <QMUIKeyboardManagerDelegate>


/**
 *  键盘即将显示
 */
- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    
    __weak __typeof(self)weakSelf = self;
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, self.view.bottom-keyboardUserInfo.height-self.chatInputView.height, SCREEN_WIDTH, self.chatInputView.height)];
    baseAnimation.duration               = keyboardUserInfo.animationDuration; //设置动画的间隔时间 默认是0.4秒
    baseAnimation.repeatCount            = 1; //重复次数 HUGE_VALF设置为无限次重复
    baseAnimation.removedOnCompletion    = YES;
    baseAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
      
        if (finished) {
            // 自动显示最后一行
            NSInteger s = [weakSelf.chatTableView numberOfSections];
            if (s<1) return;
            NSInteger r = [weakSelf.chatTableView numberOfRowsInSection:s-1];
            if (r<1) return;
            NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
            [weakSelf.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    [self.chatInputView pop_addAnimation:baseAnimation forKey:@"showKeyboardAnimation"];
}

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    
    [self.chatInputView.inputView resignFirstResponder];
    [self.view endEditing:YES];
    
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, self.view.bottom-self.chatInputView.height, SCREEN_WIDTH, self.chatInputView.height)];
    baseAnimation.duration               = keyboardUserInfo.animationDuration; //设置动画的间隔时间 默认是0.4秒
    baseAnimation.repeatCount            = 1; //重复次数 HUGE_VALF设置为无限次重复
    baseAnimation.removedOnCompletion    = YES;
    [self.chatInputView pop_addAnimation:baseAnimation forKey:@"hideKeyboardAnimation"];
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    if (view == self.chatInputView) {
        // 输入框并非撑满 toolbarView 的，所以有可能点击到 toolbarView 里空白的地方，此时保持键盘状态不变
        return NO;
    }
    
    return YES;
}

#pragma mark - QYChatDelegate
-(void)receviedMsgWithContent:(NSString *)msgContent andFrom:(NSString *)from{
    
    MsgItem *item = [[MsgItem alloc] init];
    item.messageFrom = from;
    item.messageContent = msgContent;
    item.messageTime = [PublicMethods getCurrentTime];
    item.msgFrom = MsgFromOthers;
    
    [self.sourceAry addObject:item];
    [self.chatTableView reloadData];

    // 自动显示最后一行
    NSInteger s = [self.chatTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.chatTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

#pragma mark - QYChatInputDelegate
- (void)chatSendText:(NSString *)text{
    
    // 发送消息
    int code = [[LocalUDPDataSender sharedInstance] sendCommonDataWithStr:text toUserId:self.messageFrom qos:YES fp:nil withTypeu:-1];
    if(code == COMMON_CODE_OK){
        
        MsgItem *item = [[MsgItem alloc] init];
        item.messageFrom = [ClientCoreSDK sharedInstance].currentLoginToken;
        item.messageContent = text;
        item.messageTime = [PublicMethods getCurrentTime];
        item.msgFrom = MsgFromMe;
        
        [self.sourceAry addObject:item];
        [self.chatTableView reloadData];
        
        // 自动显示最后一行
        NSInteger s = [self.chatTableView numberOfSections];
        if (s<1) return;
        NSInteger r = [self.chatTableView numberOfRowsInSection:s-1];
        if (r<1) return;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    }else{
        
        NSString *msg = [NSString stringWithFormat:@"您的消息发送失败，错误码：%d", code];
        DDLogError(@"%@",msg);
    }
}

-(void)inputTextViewHeightChanged:(CGFloat)height{
    
    if (height == self.chatInputView.frame.size.height) {
        return;
    }
    
    if (height > 150) {
        height = 150;
    }
    
    [self.chatInputView pop_removeAllAnimations];
    
    BOOL isKeyboardVisible = [QMUIKeyboardManager isKeyboardVisible];
    CGFloat keyboardHeight = [QMUIKeyboardManager visiableKeyboardHeight];
    CGFloat y = isKeyboardVisible?(self.view.bottom-keyboardHeight-height):(self.view.bottom-height);
    
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, y, SCREEN_WIDTH, height)];
    baseAnimation.duration               = 0.1;
    baseAnimation.repeatCount            = 1; //重复次数 HUGE_VALF设置为无限次重复
    baseAnimation.removedOnCompletion    = YES;
    [self.chatInputView pop_addAnimation:baseAnimation forKey:@"textViewHeightChanged"];

}
@end
