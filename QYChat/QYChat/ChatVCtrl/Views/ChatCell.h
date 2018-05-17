//
//  ChatCell.h
//  QYChat
//
//  Created by 古秀湖 on 2018/5/13.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

@interface ChatCell : UITableViewCell

-(void)resetUIWithMsgItem:(MsgItem*)item;

@end
