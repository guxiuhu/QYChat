//
//  MsgListCell.h
//  QYChat
//
//  Created by 古秀湖 on 2018/4/19.
//  Copyright © 2018年 古秀湖. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgItem.h"

@interface MsgListCell : UITableViewCell

-(void)resetUIWithItem:(MsgItem*)item;

@end
