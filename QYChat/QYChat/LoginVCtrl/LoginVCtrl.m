//
//  LoginVCtrl.m
//  QYChat
//
//  Created by 古秀湖 on 2018/4/18.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "LoginVCtrl.h"

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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#68bbae") size:CGSizeMake(SCREEN_WIDTH-15*2-20*2, 50) cornerRadius:25] forState:UIControlStateNormal];
    }
    
    return _loginBtn;
}
@end
