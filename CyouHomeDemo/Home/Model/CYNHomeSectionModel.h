//
//  CYNHomeSectionModel.h
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/13.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CYNHomeCellModel.h"

@interface CYNHomeSectionModel : NSObject

@property (nonatomic, copy) NSString *sectionTitle;

@property (nonatomic, copy) NSArray <CYNHomeCellModel *> *apps;

@end
