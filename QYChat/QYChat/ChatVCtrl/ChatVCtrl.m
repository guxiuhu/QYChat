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

@interface ChatVCtrl ()<UITableViewDataSource,UITableViewDelegate,QMUIKeyboardManagerDelegate>

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
    
    //输入控件
    self.chatInputView = [[ChatInputView alloc] initWithFrame:CGRectMake(0, self.view.bottom-50, SCREEN_WIDTH, 50)];
    [self.view addSubview:self.chatInputView];
    
    //列表
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.delegate = self;
    self.chatTableView.dataSource = self;
    [self.view addSubview:self.chatTableView];
    [self.chatTableView mas_makeConstraints:^(MASConstraintMaker *make) {

        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuideBottom).with.offset(0);
        make.bottom.equalTo(self.chatInputView.mas_top);
    }];
    
    [PublicMethods setExtraCellLineHidden:self.chatTableView];
    
    _keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
    //设置键盘只接受 self.textView 的通知事件，如果当前界面有其他 UIResponder 导致键盘产生通知事件，则不会被接受
    [self.keyboardManager addTargetResponder:self.chatInputView.inputField];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    return cell;
}

#pragma mark - <QMUIKeyboardManagerDelegate>


/**
 *  键盘即将显示
 */
- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, self.view.bottom-keyboardUserInfo.height-50, SCREEN_WIDTH, 50)];
    baseAnimation.duration               = keyboardUserInfo.animationDuration; //设置动画的间隔时间 默认是0.4秒
    baseAnimation.repeatCount            = 1; //重复次数 HUGE_VALF设置为无限次重复
    baseAnimation.removedOnCompletion    = YES;
    [self.chatInputView pop_addAnimation:baseAnimation forKey:@"showKeyboardAnimation"];
}

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo{
    
    POPBasicAnimation *baseAnimation     = [POPBasicAnimation animationWithPropertyNamed:kPOPViewFrame];
    baseAnimation.fromValue              = [NSValue valueWithCGRect:self.chatInputView.frame];
    baseAnimation.toValue                = [NSValue valueWithCGRect:CGRectMake(0, self.view.bottom-50, SCREEN_WIDTH, 50)];
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

@end
