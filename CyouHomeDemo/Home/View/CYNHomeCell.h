//
//  CYNHomeCell.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EditCallback)(BOOL isAdd);

@interface CYNHomeCell : UICollectionViewCell

/**标题*/
@property (nonatomic, copy) NSString *title;
/**是否正在移动状态*/
@property (nonatomic, assign) BOOL isMoving;
/**是否在编辑状态*/
@property (nonatomic, assign) BOOL isEdit;
/**编辑状态是否为添加*/
@property (nonatomic, assign) BOOL isAdd;
/**是否被固定*/
@property (nonatomic, assign) BOOL isFixed;

/**点击编辑按钮的回调*/
@property (nonatomic, copy) EditCallback editCallback;

@end
