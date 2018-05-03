//
//  LoginVCtrl.m
//  QYChat
//
//  Created by 古秀湖 on 2018/4/18.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "LoginVCtrl.h"
#import "CompletionDefine.h"
#import "IMClientManager.h"
#import "LocalUDPDataSender.h"
#import "OnLoginProgress.h"

@interface LoginVCtrl ()

///背景
@property (nonatomic, strong) UIImageView *bgImgView;

///内容区
@property (nonatomic, strong) UIView *contentView;

///版权提示
@property (nonatomic, strong) UILabel *copyRightLabel;

///用户名
@property (nonatomic, strong) UITextField *userNameField;

///密码
@property (nonatomic, strong) UITextField *pwdField;

///登录按钮
@property (nonatomic, strong) UIButton *loginBtn;


/* 登陆进度提示 */
@property (nonatomic) OnLoginProgress *onLoginProgress;

/* 收到服务端的登陆完成反馈时要通知的观察者（因登陆是异步实现，本观察者将由
 *  ChatBaseEvent 事件的处理者在收到服务端的登陆反馈后通知之）*/
@property (nonatomic, copy) ObserverCompletion onLoginSucessObserver;// block代码块一定要用copy属性，否则报错！

@end

@implementation LoginVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //背景
    [self.view addSubview:self.bgImgView];
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.and.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_centerY).with.offset(-50);
    }];

    //内容区
    [self.view addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.view).with.offset(15);
        make.right.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(290);
        make.top.equalTo(self.bgImgView.mas_bottom).with.offset(-40);
    }];
    
    //用户名
    [self.contentView addSubview:self.userNameField];
    [self.userNameField mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.contentView).with.offset(35);
        make.left.equalTo(self.contentView).with.offset(25);
        make.right.equalTo(self.contentView).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    //画条线
    UIView *lineView = [UIView new];
    [lineView setBackgroundColor:UIColorMakeWithHex(@"#58595a")];
    [self.contentView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(self.contentView).with.offset(20);
        make.right.equalTo(self.userNameField);
        make.height.mas_equalTo(PixelOne);
        make.top.equalTo(self.userNameField.mas_bottom);
    }];
    
    //密码
    [self.contentView addSubview:self.pwdField];
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.userNameField.mas_bottom).with.offset(10);
        make.left.equalTo(self.contentView).with.offset(25);
        make.right.equalTo(self.contentView).with.offset(-20);
        make.height.mas_equalTo(40);
    }];
    
    //画条线
    UIView *lineView1 = [UIView new];
    [lineView1 setBackgroundColor:UIColorMakeWithHex(@"#58595a")];
    [self.contentView addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.contentView).with.offset(20);
        make.right.equalTo(self.pwdField);
        make.height.mas_equalTo(PixelOne);
        make.top.equalTo(self.pwdField.mas_bottom);
    }];

    //登录按钮
    [self.contentView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.centerX.equalTo(self.contentView);
        make.width.mas_equalTo(SCREEN_WIDTH-15*2-20*2);
        make.height.mas_equalTo(50);
        make.top.equalTo(self.pwdField.mas_bottom).with.offset(50);
    }];
    
    //版权提示
    [self.view addSubview:self.copyRightLabel];
    [self.copyRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-15);
        make.height.mas_equalTo(15);
    }];
    
    
    __weak __typeof(self)weakSelf = self;
    
    // 实例化登陆进度提示封装类
    self.onLoginProgress = [[OnLoginProgress alloc] init];
    // 设置登陆超时回调（将在登陆进度提示封装类中使用）
    [self.onLoginProgress setOnLoginTimeoutObserver:^(id observerble ,id data) {
        
        [QMUITips hideAllTips];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"超时了" message:@"登陆超时，可能是网络故障或服务器无法连接，是否重试？" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf.onLoginProgress showProgressing:NO onParent:weakSelf.view];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"重试" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf loginAction:nil];
        }]];
        [weakSelf presentViewController:alert animated:YES completion:nil];

    }];
    // 准备好异步登陆结果回调block（将在登陆方法中使用）
    self.onLoginSucessObserver = ^(id observerble ,id data) {
        // * 已收到服务端登陆反馈则当然应立即取消显示登陆进度条
        [weakSelf.onLoginProgress showProgressing:NO onParent:weakSelf.view];
        // 服务端返回的登陆结果值
        int code = [(NSNumber *)data intValue];
        // 登陆成功
        if(code == 0)
        {
            [QMUITips hideAllTips];

            NSString *saveUserName = [PublicMethods getObjFromUserdefaultsWithKey:SAVE_LOGIN_USER_ACCOUNT];
            NSString *savePasswrod = [PublicMethods getObjFromUserdefaultsWithKey:SAVE_LOGIN_USER_PASSWORD];
            
            if (([saveUserName isEqualToString:@""]) && ([savePasswrod isEqualToString:@""])) {
                //保存用户名密码
                [PublicMethods saveToUserdefaultsWithKey:SAVE_LOGIN_USER_ACCOUNT andObj:[weakSelf.userNameField.text qmui_trim]];
                [PublicMethods saveToUserdefaultsWithKey:SAVE_LOGIN_USER_PASSWORD andObj:[weakSelf.pwdField.text qmui_trim]];
            }
            
            // 进入主界面
            [weakSelf performSegueWithIdentifier:@"showMainView" sender:nil];
        }
        // 登陆失败
        else
        {
            [QMUITips hideAllTips];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"友情提示" message:[NSString stringWithFormat:@"Sorry，登陆失败，错误码=%d", code] preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.onLoginProgress showProgressing:NO onParent:weakSelf.view];
            }]];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
        
        //## try to bug FIX ! 20160810：此observer本身执行完成才设置为nil，解决之前过早被nil而导致有时怎么也无法跳过登陆界面的问题
        // * 取消设置好服务端反馈的登陆结果观察者（当客户端收到服务端反馈过来的登陆消息时将被通知）【1】
        [[[IMClientManager sharedInstance] getBaseEventListener] setLoginOkForLaunchObserver:nil];
    };
    
    NSString *saveUserName = [PublicMethods getObjFromUserdefaultsWithKey:SAVE_LOGIN_USER_ACCOUNT];
    NSString *savePasswrod = [PublicMethods getObjFromUserdefaultsWithKey:SAVE_LOGIN_USER_PASSWORD];
    
    if ((![saveUserName isEqualToString:@""]) && (![savePasswrod isEqualToString:@""])) {
        [self handleLoginWithUserName:saveUserName andPassword:savePasswrod];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)handleLoginWithUserName:(NSString*)userName andPassword:(NSString*)password{
    [self.onLoginProgress showProgressing:YES onParent:self.view];
    // * 设置好服务端反馈的登陆结果观察者（当客户端收到服务端反馈过来的登陆消息时将被通知）【2】
    [[[IMClientManager sharedInstance] getBaseEventListener] setLoginOkForLaunchObserver:self.onLoginSucessObserver];
    
    // * 发送登陆数据包(提交登陆名和密码)
    int code = [[LocalUDPDataSender sharedInstance] sendLogin:userName withToken:password];
    if(code == COMMON_CODE_OK){
        
    }else{
        
        NSString *msg = [NSString stringWithFormat:@"登陆请求发送失败，错误码：%d", code];
        [QMUITips showInfo:msg inView:DefaultTipsParentView hideAfterDelay:2];
        
        // * 登陆信息没有成功发出时当然无条件取消显示登陆进度条
        [self.onLoginProgress showProgressing:NO onParent:self.view];
    }
}

-(void)loginAction:(id)sender{
    
    if ([[self.userNameField.text qmui_trim] isEqualToString:@""]) {
        [QMUITips showInfo:@"用户名不能为空" inView:DefaultTipsParentView hideAfterDelay:2];
        return;
    }
    
    if ([[self.pwdField.text qmui_trim] isEqualToString:@""]) {
        [QMUITips showInfo:@"用户名不能为空" inView:DefaultTipsParentView hideAfterDelay:2];
        return;
    }
    
    // * 立即显示登陆处理进度提示（并将同时启动超时检查线程）
    [self handleLoginWithUserName:[self.userNameField.text qmui_trim] andPassword:[self.pwdField.text qmui_trim]];
}

#pragma mark - getter and setter

- (UIImageView *)bgImgView{
    
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithImage:UIImageMake(@"login_bg")];
        [_bgImgView setContentMode:UIViewContentModeScaleAspectFill];
    }
    
    return _bgImgView;
}

-(UIView *)contentView{
    
    if (!_contentView) {
        _contentView = [UIView new];
        [_contentView.layer setCornerRadius:8];
        [_contentView setBackgroundColor:UIColorWhite];
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;//阴影的颜色
        _contentView.layer.shadowOpacity = 0.6f;//阴影的透明度
        _contentView.layer.shadowRadius = 8.f;//阴影的圆角
        _contentView.layer.shadowOffset = CGSizeMake(0,0);//阴影偏移量
    }
    
    return _contentView;
}

- (UILabel *)copyRightLabel{
    
    if (!_copyRightLabel) {
        _copyRightLabel = [[UILabel alloc] init];
        [_copyRightLabel setText:@"©广州南天电脑系统有限公司"];
        [_copyRightLabel setTextColor:UIColorMakeWithHex(@"#8a8a8a")];
        [_copyRightLabel setFont:UIFontMake(12)];
        [_copyRightLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return _copyRightLabel;
}

-(UITextField *)userNameField{
    
    if (!_userNameField) {
        _userNameField = [[UITextField alloc] init];
        [_userNameField setPlaceholder:@"用户名"];
        [_userNameField setFont:UIFontMake(16)];
        [_userNameField setTextColor:UIColorMakeWithHex(@"#8a8a8a")];
        [_userNameField setClearButtonMode:UITextFieldViewModeWhileEditing];

        UIImageView *imageViewPwd = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 30, 20)];
        imageViewPwd.image = [UIImage imageNamed:@"login_account"];
        _userNameField.leftView = imageViewPwd;
        _userNameField.leftViewMode = UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    }
    
    return _userNameField;
}

-(UITextField *)pwdField{
    
    if (!_pwdField) {
        _pwdField = [[UITextField alloc] init];
        [_pwdField setPlaceholder:@"密码"];
        [_pwdField setFont:UIFontMake(16)];
        [_pwdField setTextColor:UIColorMakeWithHex(@"#8a8a8a")];
        [_pwdField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_pwdField setSecureTextEntry:YES];

        UIImageView *imageViewPwd = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 30, 20)];
        imageViewPwd.image = [UIImage imageNamed:@"login_password"];
        _pwdField.leftView = imageViewPwd;
        _pwdField.leftViewMode = UITextFieldViewModeAlways; //此处用来设置leftview现实时机
    }
    
    return _pwdField;
}

-(UIButton *)loginBtn{
    
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage qmui_imageWithColor:UI_BASE_COLOR size:CGSizeMake(SCREEN_WIDTH-15*2-20*2, 50) cornerRadius:25] forState:UIControlStateNormal];
    }
    
    return _loginBtn;
}

@end
