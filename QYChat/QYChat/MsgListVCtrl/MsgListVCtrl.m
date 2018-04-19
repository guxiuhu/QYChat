//
//  MsgListVCtrl.m
//  QYChat
//
//  Created by 古秀湖 on 2018/4/18.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import "MsgListVCtrl.h"

@interface MsgListVCtrl ()

@end

@implementation MsgListVCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"消息";
    
    [self showEmptyViewWithImage:nil text:@"没有会话" detailText:nil buttonTitle:@"重试" buttonAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
