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
#import "QDUIHelper.h"

@interface ChatVCtrl ()<UITableViewDataSource,UITableViewDelegate,QMUIKeyboardManagerDelegate,QYChatDelegate,QYChatInputDelegate>

@property(nonatomic, strong) QMUIKeyboardManager *keyboardManager;

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) ChatInputView *chatInputView;
@property (nonatomic, strong) NSMutableArray *sourceAry;

//表情
@property(nonatomic, strong) QMUIEmotionInputManager *emotionInputManager;
@property BOOL emotionViewIsShowing;

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
    
    //表情
    self.emotionInputManager = [[QMUIEmotionInputManager alloc] init];
    self.emotionInputManager.emotionView.emotions = [QDUIHelper qmuiEmotions];
    self.emotionInputManager.emotionView.qmui_borderPosition = QMUIBorderViewPositionTop;
    self.emotionInputManager.boundTextView = self.chatInputView.inputView;
    [self.view addSubview:self.emotionInputManager.emotionView];
    self.emotionInputManager.emotionView.frame = CGRectMake(0, self.view.bottom, SCREEN_WIDTH, 232);
    self.emotionViewIsShowing = NO;
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

    if (self.emotionViewIsShowing) {
        [self hideEmotionView];
    }

    [self handleInputViewWithHeight:self.chatInputView.height];
}

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    
    if (self.emotionViewIsShowing) {
        return;
    }
    
    [self handleInputViewWithHeight:self.chatInputView.height];
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    if (view == self.chatInputView) {
        // 输入框并非撑满 toolbarView 的，所以有可能点击到 toolbarView 里空白的地方，此时保持键盘状态不变
        return NO;
    }
    
    return YES;
}

#pragma mark - QYChatDelegate
- (void)tableViewScrollToBottom {
    
    // 自动显示最后一行
    NSInteger s = [self.chatTableView numberOfSections];
    if (s<1) return;
    NSInteger r = [self.chatTableView numberOfRowsInSection:s-1];
    if (r<1) return;
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:s-1];
    
    //先判断是不是在最后
    if (![self.chatTableView qmui_cellVisibleAtIndexPath:ip]) {
        [self.chatTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)receviedMsgWithContent:(NSString *)msgContent andFrom:(NSString *)from{
    
    MsgItem *item = [[MsgItem alloc] init];
    item.messageFrom = from;
    item.messageContent = msgContent;
    item.messageTime = [PublicMethods getCurrentTime];
    item.msgFrom = MsgFromOthers;
    
    [self.sourceAry addObject:item];
    
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
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
        
        [self tableViewScrollToBottom];
    }else{
        
        NSString *msg = [NSString stringWithFormat:@"您的消息发送失败，错误码：%d", code];
        DDLogError(@"%@",msg);
    }
}

-(void)inputTextViewHeightChanged:(CGFloat)height{
    
    if (height == self.chatInputView.frame.size.height) {
        return;
    }
    
    //最高100
    if (height > 100) {
        height = 100;
    }
    
    //最低50
    if (height < 50) {
        height = 50;
    }

    [self handleInputViewWithHeight:height];
}

- (void)clickEmotionBtn{
    
    if (self.emotionViewIsShowing) {
        [self hideEmotionView];
    } else {
        [self showEmotionView];
    }
    
    [self handleInputViewWithHeight:self.chatInputView.height];
}

///显示表情面板
-(void)showEmotionView{
    
    self.emotionViewIsShowing = YES;
    [self.chatInputView.inputView resignFirstResponder];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.emotionInputManager.emotionView.frame = CGRectMake(0, self.view.bottom-232, SCREEN_WIDTH, 232);
    }];
}

///隐藏表情面板
-(void)hideEmotionView{
    
    self.emotionViewIsShowing = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.emotionInputManager.emotionView.frame = CGRectMake(0, self.view.bottom, SCREEN_WIDTH, 232);
    }];
}

-(void)handleInputViewWithHeight:(CGFloat)height{
    
    [self.chatInputView pop_removeAllAnimations];
    
    __weak __typeof(self)weakSelf = self;
    BOOL isKeyboardVisible = [QMUIKeyboardManager isKeyboardVisible];
    CGFloat keyboardHeight = [QMUIKeyboardManager visiableKeyboardHeight];
    CGFloat y = isKeyboardVisible?(self.view.bottom-keyboardHeight-height):(self.emotionViewIsShowing?(self.view.bottom-232-height):(self.view.bottom-height));
    
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, y, SCREEN_WIDTH, height)];
    baseAnimation.duration               = 0.2;
    baseAnimation.repeatCount            = 1; //重复次数 HUGE_VALF设置为无限次重复
    baseAnimation.removedOnCompletion    = YES;
    baseAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        
        [weakSelf tableViewScrollToBottom];
    };
    [self.chatInputView pop_addAnimation:baseAnimation forKey:@"textViewHeightChanged"];
}
@end
