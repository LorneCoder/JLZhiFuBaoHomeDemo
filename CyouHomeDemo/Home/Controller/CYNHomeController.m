//
//  CYNHomeController.m
//  CyouHomeDemo
//
//  Created by gaojianlong on 2018/11/12.
//  Copyright © 2018年 gaojianlong. All rights reserved.
//

#import "CYNHomeController.h"
#import "CYNHomeCell.h"
#import "CYNHomeCellHeader.h"
#import "CYNHomeCellModel.h"
#import "CYNHomeCategoryHeader.h"
#import "JXCategoryView.h"
#import "CYNHomeSectionModel.h"
#import "CYNHomeCollectionView.h"

//菜单列数
static NSInteger ColumnNumber = 4;
//横向和纵向的间距
static CGFloat CellMarginX = 1;
static CGFloat CellMarginY = 1;

static const CGFloat VerticalListCategoryViewHeight = 60;   //悬浮categoryView的高度
static const NSUInteger VerticalListPinSectionIndex = 1;    //悬浮固定section的index

@interface CYNHomeController () <UICollectionViewDelegate, UICollectionViewDataSource, JXCategoryViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIBarButtonItem *leftBarButton;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) CYNHomeCollectionView *collectionView;
@property (nonatomic, strong) JXCategoryTitleView *pinCategoryView;//分类导航视图
@property (nonatomic, assign) BOOL edit;//列表是否在编辑状态

@property (nonatomic, strong) NSArray <NSString *> *headerTitles;//分类导航视图标题数组
@property (nonatomic, strong) NSArray <CYNHomeSectionModel *> *dataSource;//首页所有应用总数据源
@property (nonatomic, strong) NSMutableArray <CYNHomeCellModel *> *editArray;//头部可编辑的应用数组
@property (nonatomic, strong) NSMutableArray <NSString *> *editIds;//可编辑的应用ID数组

@property (nonatomic, strong) CYNHomeCategoryHeader *sectionCategoryHeaderView;
@property (nonatomic, strong) NSArray <UICollectionViewLayoutAttributes *> *sectionHeaderAttributes;

@end

@implementation CYNHomeController
{
    //被拖拽的item
    CYNHomeCell *_dragingItem;
    //正在拖拽的indexpath
    NSIndexPath *_dragingIndexPath;
    //目标位置
    NSIndexPath *_targetIndexPath;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"首页";
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;

    [self initSubviews];
    [self loadData];
}

- (void)initSubviews
{
    __weak typeof(self)weakSelf = self;
    self.collectionView.layoutSubviewsCallback = ^{
        [weakSelf updateSectionHeaderAttributes];
    };
    
    [self.view addSubview:self.collectionView];
    
    //创建pinCategoryView，但是不要被addSubview
    _pinCategoryView = [[JXCategoryTitleView alloc] init];
    self.pinCategoryView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    self.pinCategoryView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, VerticalListCategoryViewHeight);
    JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
    lineView.verticalMargin = 15;
    self.pinCategoryView.indicators = @[lineView];
    self.pinCategoryView.delegate = self;
}

- (void)loadData
{
    NSString *homeDataPath = [[NSBundle mainBundle] pathForResource:@"HomeData" ofType:@"plist"];
    NSArray *homeArr = [NSArray arrayWithContentsOfFile:homeDataPath];
    
    NSMutableArray *dataSource = [NSMutableArray array];
    NSMutableArray *sectionTitles = [NSMutableArray arrayWithCapacity:homeArr.count];
    [homeArr enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
        CYNHomeSectionModel *sectionModel = [[CYNHomeSectionModel alloc] init];
        sectionModel.sectionTitle = dict[@"sectionTitle"];
        [sectionTitles addObject:dict[@"sectionTitle"]];
        
        NSMutableArray *cellModels = [NSMutableArray array];
        for (NSDictionary *subDict in dict[@"apps"]) {
            CYNHomeCellModel *cellModel = [[CYNHomeCellModel alloc] init];
            cellModel.appId = subDict[@"appId"];
            cellModel.name = subDict[@"name"];
            [cellModels addObject:cellModel];
        }
        
        sectionModel.apps = cellModels;
        [dataSource addObject:sectionModel];
    }];
    
    self.headerTitles = [NSArray arrayWithArray:sectionTitles];
    [sectionTitles removeObjectAtIndex:0];
    self.pinCategoryView.titles = [NSArray arrayWithArray:sectionTitles];
    
    self.dataSource = dataSource;
    CYNHomeSectionModel *headerModel = dataSource.firstObject;
    self.editArray = [NSMutableArray arrayWithArray:headerModel.apps];
    self.editIds = [NSMutableArray array];

    for (CYNHomeCellModel *cellModel in self.editArray) {
        [self.editIds addObject:cellModel.appId];
    }
    
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CYNHomeSectionModel *sectionModel = self.dataSource[section];
    return section == 0 ? self.editArray.count : sectionModel.apps.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == VerticalListPinSectionIndex) {
            CYNHomeCategoryHeader *categoryHeader = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCategoryHeader" forIndexPath:indexPath];
            self.sectionCategoryHeaderView = categoryHeader;
            
            if (self.pinCategoryView.superview == nil) {
                //首次使用VerticalSectionCategoryHeaderView的时候，把pinCategoryView添加到它上面。
                [categoryHeader addSubview:self.pinCategoryView];
            }
            
            return categoryHeader;
            
        } else {
            CYNHomeCellHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader" forIndexPath:indexPath];
            CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
            
            if (indexPath.section == 0) {
                [header setHeaderTitle:sectionModel.sectionTitle subTitle:@"(长按可拖动排序)"];
            } else {
                [header setHeaderTitle:sectionModel.sectionTitle subTitle:@""];
            }
            
            return header;
        }
    }
    
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CYNHomeCell" forIndexPath:indexPath];
    CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
    CYNHomeCellModel *model = (indexPath.section == 0 ? self.editArray[indexPath.row] : sectionModel.apps[indexPath.row]);
    cell.title = model.name;
    
    if (self.edit) {
        cell.isEdit = YES;
        if ([self.editIds containsObject:model.appId]) {
            //设置编辑符合为减号
            cell.isAdd = NO;
        } else {
            cell.isAdd = YES;
        }
    } else {
        cell.isEdit = NO;
    }
    
    [cell setEditCallback:^(BOOL isAdd) {
        [self setEditResult:isAdd model:model indexPath:indexPath];
    }];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CYNHomeSectionModel *sectionModel = self.dataSource[indexPath.section];
    CYNHomeCellModel *model = (indexPath.section == 0 ? self.editArray[indexPath.row] : sectionModel.apps[indexPath.row]);
    NSLog(@"点击了：%@", model.name);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UICollectionViewLayoutAttributes *attri = self.sectionHeaderAttributes[VerticalListPinSectionIndex];
    if (scrollView.contentOffset.y >= attri.frame.origin.y) {
        //当滚动的contentOffset.y大于了指定sectionHeader的y值，且还没有被添加到self.view上的时候，就需要切换superView
        if (self.pinCategoryView.superview != self.view) {
            [self.view addSubview:self.pinCategoryView];
        }
    } else if (self.pinCategoryView.superview != self.sectionCategoryHeaderView) {
        //当滚动的contentOffset.y小于了指定sectionHeader的y值，且还没有被添加到sectionCategoryHeaderView上的时候，就需要切换superView
        [self.sectionCategoryHeaderView addSubview:self.pinCategoryView];
    }
    
    if (!(scrollView.isTracking || scrollView.isDecelerating)) {
        //不是用户滚动的，比如setContentOffset等方法，引起的滚动不需要处理。
        return;
    }
    
    //用户滚动的才处理
    //获取categoryView下面一点的所有布局信息，用于知道，当前最上方是显示的哪个section
    CGRect topRect = CGRectMake(0, scrollView.contentOffset.y + VerticalListCategoryViewHeight + 1, self.view.bounds.size.width, 1);
    UICollectionViewLayoutAttributes *topAttributes = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:topRect].firstObject;
    NSUInteger topSection = topAttributes.indexPath.section;
    
    if (topAttributes != nil && topSection >= VerticalListPinSectionIndex) {
        if (self.pinCategoryView.selectedIndex != topSection - VerticalListPinSectionIndex) {
            //不相同才切换
            [self.pinCategoryView selectItemAtIndex:topSection - VerticalListPinSectionIndex];
        }
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == VerticalListPinSectionIndex) {
        //categoryView所在的headerView要高一些
        return CGSizeMake(self.view.bounds.size.width, VerticalListCategoryViewHeight);
    }
    return CGSizeMake(self.view.bounds.size.width, 40);
}


#pragma mark - JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didClickSelectedItemAtIndex:(NSInteger)index
{
    //这里关心点击选中的回调！！！
    UICollectionViewLayoutAttributes *targetAttri = self.sectionHeaderAttributes[index + VerticalListPinSectionIndex];
    if (index == 0) {
        //选中了第一个，特殊处理一下，滚动到sectionHeaer的最上面
        [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y) animated:YES];
    }else {
        //不是第一个，需要滚动到categoryView下面
        [self.collectionView setContentOffset:CGPointMake(0, targetAttri.frame.origin.y - VerticalListCategoryViewHeight) animated:YES];
    }
}

#pragma mark -
#pragma mark - 用户交互

- (void)longPressMethod:(UILongPressGestureRecognizer*)gesture
{
    CGPoint point = [gesture locationInView:_collectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            NSLog(@"长按开始");
            [self setEditStateConfigs];
            [self dragBegin:point];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragChanged:point];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragEnd];
            break;
        default:
            break;
    }
}

//拖拽开始 找到被拖拽的item
- (void)dragBegin:(CGPoint)point
{
    _dragingIndexPath = [self getDragingIndexPathWithPoint:point];
    if (!_dragingIndexPath) {
        return;
    }
    [_collectionView bringSubviewToFront:_dragingItem];

    CYNHomeCell *item = (CYNHomeCell *)[_collectionView cellForItemAtIndexPath:_dragingIndexPath];
    item.isMoving = YES;
    //更新被拖拽的item
    _dragingItem.hidden = NO;
    _dragingItem.frame = item.frame;
    _dragingItem.title = item.title;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.1, 1.1)];
}

//正在被拖拽
- (void)dragChanged:(CGPoint)point
{
    if (!_dragingIndexPath) {
        return;
    }
    _dragingItem.center = point;
    _targetIndexPath = [self getTargetIndexPathWithPoint:point];
    //交换位置 如果没有找到_targetIndexPath则不交换位置
    if (_dragingIndexPath && _targetIndexPath) {
        //更新数据源
        [self rearrangeInUseTitles];
        //更新item位置
        [_collectionView moveItemAtIndexPath:_dragingIndexPath toIndexPath:_targetIndexPath];
        _dragingIndexPath = _targetIndexPath;
    }
}

//拖拽结束
- (void)dragEnd
{
    if (!_dragingIndexPath) {
        return;
    }
    CGRect endFrame = [_collectionView cellForItemAtIndexPath:_dragingIndexPath].frame;
    [_dragingItem setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_dragingItem.frame = endFrame;
    }completion:^(BOOL finished) {
        self->_dragingItem.hidden = true;
        CYNHomeCell *item = (CYNHomeCell *)[self.collectionView cellForItemAtIndexPath:self->_dragingIndexPath];
        item.isMoving = NO;
    }];
}

- (void)cancelClicked
{
    [self setNormalStateConfig];
}

- (void)saveClicked
{
    [self setNormalStateConfig];
}

#pragma mark -
#pragma mark - private method

/**获取被拖动IndexPath的方法*/
- (NSIndexPath*)getDragingIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *dragIndexPath = nil;
    //最后剩一个不可以排序
    if ([_collectionView numberOfItemsInSection:0] == 1) {
        return dragIndexPath;
    }
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //下半部分不需要排序
        if (indexPath.section > 0) {continue;}
        //在上半部分中找出相对应的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            dragIndexPath = indexPath;
            break;
        }
    }
    return dragIndexPath;
}

/**获取目标IndexPath的方法*/
- (NSIndexPath*)getTargetIndexPathWithPoint:(CGPoint)point
{
    NSIndexPath *targetIndexPath = nil;
    for (NSIndexPath *indexPath in _collectionView.indexPathsForVisibleItems) {
        //如果是自己不需要排序
        if ([indexPath isEqual:_dragingIndexPath]) {continue;}
        //第二组不需要排序
        if (indexPath.section > 0) {continue;}
        //在第一组中找出将被替换位置的Item
        if (CGRectContainsPoint([_collectionView cellForItemAtIndexPath:indexPath].frame, point)) {
            targetIndexPath = indexPath;
        }
    }
    return targetIndexPath;
}

/**拖拽排序后需要重新排序数据源*/
-(void)rearrangeInUseTitles
{
    CYNHomeCellModel *model = [self.editArray objectAtIndex:_dragingIndexPath.row];
    [self.editArray removeObject:model];
    [self.editArray insertObject:model atIndex:_targetIndexPath.row];
}

/**设置编辑结果*/
- (void)setEditResult:(BOOL)isAdd model:(CYNHomeCellModel *)model indexPath:(NSIndexPath *)indexPath
{
    NSLog(@"isAdd : %d, name : %@", isAdd, model.name);
    
    if (isAdd) {
        //添加
        if ([self.editIds containsObject:model.appId]) {
            return;
        }
        
        //最多可以添加8个
        if (self.editArray.count >= 8) {
            NSLog(@"最多可以添加8个应用");
            return;
        }
        
        [self.editIds addObject:model.appId];
        [self.editArray addObject:model];
        [self.collectionView reloadData];
        
    } else {
        //删除
        if (![self.editIds containsObject:model.appId]) {
            return;
        }
        
        //最少要留一个应用
        if (self.editArray.count <= 1) {
            NSLog(@"最少要留一个应用");
            return;
        }
        
        [self.editIds removeObject:model.appId];
        [self.editArray enumerateObjectsUsingBlock:^(CYNHomeCellModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.appId isEqualToString:model.appId]) {
                [self.editArray removeObject:obj];
                
                [self.collectionView reloadData];
                *stop = YES;
            }
        }];
    }
    
    //每次添加或删除应用，会影响sectionHeaderAttributes，这时将sectionHeaderAttributes置空，重新获取；
    self.sectionHeaderAttributes = nil;
}

/**编辑状态下的配置*/
- (void)setEditStateConfigs
{
    if (!self.edit) {
        self.edit = YES;
        [self.collectionView reloadData];
        self.navigationItem.leftBarButtonItem = self.leftBarButton;
        self.navigationItem.rightBarButtonItem = self.rightBarButton;
        
        //设置滚动到顶部
        [self.collectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        //固定【我的应用】区域
        
        
    }
}

/**常规状态下的配置*/
- (void)setNormalStateConfig
{
    if (self.edit) {
        self.edit = NO;
        [self.collectionView reloadData];
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - 垂直列表滚动相关

- (void)updateSectionHeaderAttributes
{
    if (self.sectionHeaderAttributes == nil) {
        NSLog(@"编辑完，重新获取最新的sectionHeaderAtrributes");
        
        //获取到所有的sectionHeaderAtrributes，用于后续的点击，滚动到指定contentOffset.y使用
        NSMutableArray *attributes = [NSMutableArray array];
        UICollectionViewLayoutAttributes *lastHeaderAttri = nil;
     
        for (int i = 0; i < self.headerTitles.count; i++) {
            UICollectionViewLayoutAttributes *attri = [self.collectionView.collectionViewLayout layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:0 inSection:i]];
            if (attri) {
                [attributes addObject:attri];
            }
            if (i == self.headerTitles.count - 1) {
                lastHeaderAttri = attri;
            }
        }
        
        if (attributes.count == 0) {
            return;
        }
        self.sectionHeaderAttributes = attributes;
        
        //如果最后一个section条目太少了，会导致滚动最底部，但是却不能触发categoryView选中最后一个item。而且点击最后一个滚动的contentOffset.y也不要弄。所以添加contentInset，让最后一个section滚到最下面能显示完整个屏幕。
        UICollectionViewLayoutAttributes *lastCellAttri = [self.collectionView.collectionViewLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataSource[self.headerTitles.count - 1].apps.count - 1 inSection:self.headerTitles.count - 1]];
        CGFloat lastSectionHeight = CGRectGetMaxY(lastCellAttri.frame) - CGRectGetMinY(lastHeaderAttri.frame);
        CGFloat value = (self.view.bounds.size.height - VerticalListCategoryViewHeight) - lastSectionHeight;
        if (value > 0) {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, value, 0);
        }
    }
}

#pragma mark -
#pragma mark - setting && getting

- (CYNHomeCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat superWidth = CGRectGetWidth(self.view.bounds);
        
        CGFloat cellWidth = (superWidth - (ColumnNumber - 1) * CellMarginX) / ColumnNumber;
        flowLayout.itemSize = CGSizeMake(cellWidth , cellWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(1, 0, 0, 0);
        flowLayout.minimumLineSpacing = CellMarginY;
        flowLayout.minimumInteritemSpacing = CellMarginX;
        
        _collectionView = [[CYNHomeCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        _collectionView.showsHorizontalScrollIndicator = false;
        _collectionView.backgroundColor = [UIColor grayColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[CYNHomeCell class] forCellWithReuseIdentifier:@"CYNHomeCell"];
        [_collectionView registerClass:[CYNHomeCellHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCellHeader"];
        [_collectionView registerClass:[CYNHomeCategoryHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CYNHomeCategoryHeader"];

        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
        longPress.minimumPressDuration = 0.3f;
        [_collectionView addGestureRecognizer:longPress];
        
        _dragingItem = [[CYNHomeCell alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellWidth)];
        _dragingItem.hidden = YES;
        [_collectionView addSubview:_dragingItem];
    }
    return _collectionView;
}

- (UIBarButtonItem *)leftBarButton
{
    if (!_leftBarButton) {
        _leftBarButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelClicked)];
    }
    return _leftBarButton;
}

- (UIBarButtonItem *)rightBarButton
{
    if (!_rightBarButton) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveClicked)];
    }
    return _rightBarButton;
}

@end
