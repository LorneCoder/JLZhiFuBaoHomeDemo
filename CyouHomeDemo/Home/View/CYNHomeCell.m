//
//  CYNHomeCell.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeCell.h"

@interface CYNHomeCell()

@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *iconName;

@end

@implementation CYNHomeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews
{
    [self.contentView addSubview:self.editBtn];
    [self.contentView addSubview:self.iconImage];
    [self.contentView addSubview:self.iconName];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.editBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.frame) - 15, 0, 15, 15);
    self.iconImage.frame = CGRectMake(0, 0, 20, 20);
    self.iconImage.center = self.contentView.center;
    
    self.iconName.frame = CGRectMake(0, CGRectGetMaxY(self.iconImage.frame) + 10, CGRectGetWidth(self.contentView.frame), 15);
}

#pragma mark -
#pragma mark 配置方法

- (UIColor*)backgroundColor
{
    return [UIColor colorWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1];
}

- (UIColor*)textColor
{
    return [UIColor colorWithRed:40/255.0f green:40/255.0f blue:40/255.0f alpha:1];
}

- (UIColor*)lightTextColor
{
    return [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
}


#pragma mark -
#pragma mark - 交互

- (void)editBtnClicked:(UIButton *)sender
{
    if (self.editCallback) {
        self.editCallback(_isAdd);
    }
}

#pragma mark -
#pragma mark - setter && getter

- (UIButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_editBtn addTarget:self action:@selector(editBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _editBtn.hidden = YES;
    }
    return _editBtn;
}

- (UIImageView *)iconImage
{
    if (!_iconImage) {
        _iconImage = [[UIImageView alloc] init];
        _iconImage.backgroundColor = [UIColor redColor];
        _iconImage.userInteractionEnabled = YES;
    }
    return _iconImage;
}

- (UILabel *)iconName
{
    if (!_iconName) {
        _iconName = [[UILabel alloc] init];
        _iconName.font = [UIFont systemFontOfSize:14];
        _iconName.textColor = [UIColor blackColor];
        _iconName.textAlignment = NSTextAlignmentCenter;
    }
    return _iconName;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.iconName.text = title;
}

- (void)setIsMoving:(BOOL)isMoving
{
    _isMoving = isMoving;
    if (_isMoving) {
        self.backgroundColor = [UIColor clearColor];
        //_borderLayer.hidden = false;
    } else {
        self.backgroundColor = [UIColor whiteColor];
        //_borderLayer.hidden = true;
    }
}

- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
    if (_isEdit) {
        self.editBtn.hidden = NO;
    } else {
        self.editBtn.hidden = YES;
    }
}

- (void)setIsAdd:(BOOL)isAdd
{
    _isAdd = isAdd;
    if (_isAdd) {
        [self.editBtn setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    } else {
        [self.editBtn setImage:[UIImage imageNamed:@"icon_delete"] forState:UIControlStateNormal];
    }
}

- (void)setIsFixed:(BOOL)isFixed
{
    _isFixed = isFixed;
    if (isFixed) {
        _iconName.textColor = [self lightTextColor];
    } else {
        _iconName.textColor = [self textColor];
    }
}

@end
