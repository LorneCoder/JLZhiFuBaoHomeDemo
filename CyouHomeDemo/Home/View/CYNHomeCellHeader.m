//
//  CYNHomeCellHeader.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeCellHeader.h"

@interface CYNHomeCellHeader()

@property (nonatomic, strong) UIView *spaceView;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *subTitle;

@end

@implementation CYNHomeCellHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    [self addSubview:self.spaceView];
    [self addSubview:self.title];
    [self addSubview:self.subTitle];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.spaceView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 10);
    self.title.frame = CGRectMake(20, 10, 80, 30);
    self.subTitle.frame = CGRectMake(100, 10, 150, 30);
}

#pragma mark -
#pragma mark - setter && getter

- (UIView *)spaceView
{
    if (!_spaceView) {
        _spaceView = [[UIView alloc] init];
        _spaceView.backgroundColor = [UIColor grayColor];
    }
    return _spaceView;
}

- (UILabel *)title
{
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:13];
        _title.textColor = [UIColor grayColor];
        _title.textAlignment = NSTextAlignmentLeft;
    }
    return _title;
}

- (UILabel *)subTitle
{
    if (!_subTitle) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.font = [UIFont systemFontOfSize:13];
        _subTitle.textColor = [UIColor grayColor];
        _subTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _subTitle;
}

- (void)setHeaderTitle:(NSString *)title subTitle:(NSString *)subTitle
{
    self.title.text = title;
    self.subTitle.text = subTitle;
}

@end
