//
//  QMUIImagePickerViewController.m
//  qmui
//
//  Created by Kayo Lee on 15/5/2.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerViewController.h"
#import "QMUICore.h"
#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUIButton.h"
#import "QMUIAssetsManager.h"
#import "QMUIAlertController.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIImagePickerHelper.h"
#import "UICollectionView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+QMUI.h"
#import "QMUIEmptyView.h"
#import "UIControl+QMUI.h"
#import "QMUILog.h"

// 底部工具栏
#define OperationToolBarViewPaddingHorizontal 12
#define ImageCountLabelSize CGSizeMake(18, 18)

// CollectionView
#define CollectionViewInsetHorizontal PreferredVarForDevices((PixelOne * 2), 1, 2, 2)
#define CollectionViewInset UIEdgeInsetsMake(CollectionViewInsetHorizontal, CollectionViewInsetHorizontal, CollectionViewInsetHorizontal, CollectionViewInsetHorizontal)
#define CollectionViewCellMargin CollectionViewInsetHorizontal

static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";


#pragma mark - QMUIImagePickerViewController (UIAppearance)

@implementation QMUIImagePickerViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance]; // +initialize 时就先设置好默认样式
    });
}

static QMUIImagePickerViewController *imagePickerViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imagePickerViewControllerAppearance) {
            imagePickerViewControllerAppearance = [[QMUIImagePickerViewController alloc] init];
            imagePickerViewControllerAppearance.minimumImageWidth = 75;
        }
    });
    return imagePickerViewControllerAppearance;
}

@end

#pragma mark - QMUIImagePickerViewController

@interface QMUIImagePickerViewController ()

@property(nonatomic, strong) QMUIImagePickerPreviewViewController *imagePickerPreviewViewController;
@property(nonatomic, assign) BOOL isImagesAssetLoaded;// 这个属性的作用描述：https://github.com/QMUI/QMUI_iOS/issues/219
@property(nonatomic, assign) BOOL hasScrollToInitialPosition;
@property(nonatomic, assign) BOOL canScrollToInitialPosition;// 要等数据加载完才允许滚动
@end

@implementation QMUIImagePickerViewController

- (void)didInitialized {
    [super didInitialized];
    if (imagePickerViewControllerAppearance) {
        // 避免 imagePickerViewControllerAppearance init 时走到这里来，导致死循环
        self.minimumImageWidth = [QMUIImagePickerViewController appearance].minimumImageWidth;
    }
    _allowsMultipleSelection = YES;
    _maximumSelectImageCount = INT_MAX;
    _minimumSelectImageCount = 0;
    _shouldShowDefaultLoadingView = YES;
    // 为了让使用者可以在 init 完就可以直接改 UI 相关的 property，这里提前触发 loadView
    BeginIgnoreAvailabilityWarning
    [self loadViewIfNeeded];
    EndIgnoreAvailabilityWarning
}

- (void)dealloc {
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

- (void)initSubviews {
    [super initSubviews];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.sectionInset = CollectionViewInset;
    self.collectionViewLayout.minimumLineSpacing = CollectionViewCellMargin;
    self.collectionViewLayout.minimumInteritemSpacing = CollectionViewCellMargin;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.backgroundColor = UIColorClear;
    [self.collectionView registerClass:[QMUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
    [self.collectionView registerClass:[QMUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
    [self.view addSubview:self.collectionView];
    
    // 只有允许多选时，才显示底部工具
    if (self.allowsMultipleSelection) {
        
        _operationToolBarView = [[UIView alloc] init];
        self.operationToolBarView.backgroundColor = UIColorWhite;
        self.operationToolBarView.qmui_borderPosition = QMUIBorderViewPositionTop;
        [self.view addSubview:self.operationToolBarView];
        
        _sendButton = [[QMUIButton alloc] init];
        self.sendButton.enabled = NO;
        self.sendButton.titleLabel.font = UIFontMake(16);
        self.sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.sendButton setTitleColor:UIColorMake(124, 124, 124) forState:UIControlStateNormal];
        [self.sendButton setTitleColor:UIColorGray forState:UIControlStateDisabled];
        [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
        self.sendButton.qmui_outsideEdge = UIEdgeInsetsMake(-12, -20, -12, -20);
        [self.sendButton sizeToFit];
        [self.sendButton addTarget:self action:@selector(handleSendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.operationToolBarView addSubview:self.sendButton];
    
        _previewButton = [[QMUIButton alloc] init];
        self.previewButton.enabled = NO;
        self.previewButton.titleLabel.font = self.sendButton.titleLabel.font;
        [self.previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [self.previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
        [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
        self.previewButton.qmui_outsideEdge = UIEdgeInsetsMake(-12, -20, -12, -20);
        [self.previewButton sizeToFit];
        [self.previewButton addTarget:self action:@selector(handlePreviewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.operationToolBarView addSubview:self.previewButton];
        
        _imageCountLabel = [[UILabel alloc] init];
        self.imageCountLabel.userInteractionEnabled = NO;// 不要影响 sendButton 的事件
        self.imageCountLabel.backgroundColor = ButtonTintColor;
        self.imageCountLabel.textColor = UIColorWhite;
        self.imageCountLabel.font = UIFontMake(12);
        self.imageCountLabel.textAlignment = NSTextAlignmentCenter;
        self.imageCountLabel.lineBreakMode = NSLineBreakByCharWrapping;
        self.imageCountLabel.layer.masksToBounds = YES;
        self.imageCountLabel.layer.cornerRadius = ImageCountLabelSize.width / 2;
        self.imageCountLabel.hidden = YES;
        [self.operationToolBarView addSubview:self.imageCountLabel];
    }
    
    _selectedImageAssetArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorWhite;
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    self.navigationItem.rightBarButtonItem = [QMUINavigationButton barButtonItemWithType:QMUINavigationButtonTypeNormal title:@"取消" position:QMUINavigationButtonPositionRight target:self action:@selector(handleCancelPickerImage:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 由于被选中的图片 selectedImageAssetArray 是 property，所以可以由外部改变，
    // 因此 viewWillAppear 时检查一下图片被选中的情况，并刷新 collectionView
    if (self.allowsMultipleSelection) {
        // 只有允许多选，即底部工具栏显示时，需要重新设置底部工具栏的元素
        NSInteger selectedImageCount = [_selectedImageAssetArray count];
        if (selectedImageCount > 0) {
            // 如果有图片被选择，则预览按钮和发送按钮可点击，并刷新当前被选中的图片数量
            self.previewButton.enabled = YES;
            self.sendButton.enabled = YES;
            self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
            self.imageCountLabel.hidden = NO;
        } else {
            // 如果没有任何图片被选择，则预览和发送按钮不可点击，并且隐藏显示图片数量的 Label
            self.previewButton.enabled = NO;
            self.sendButton.enabled = NO;
            self.imageCountLabel.hidden = YES;
        }
    }
    [self.collectionView reloadData];
}

- (void)showEmptyView {
    [super showEmptyView];
    self.emptyView.backgroundColor = self.view.backgroundColor; // 为了盖住背后的 collectionView，这里加个背景色（不盖住的话会看到 collectionView 先滚到列表顶部然后跳到列表底部）
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!CGSizeEqualToSize(self.collectionView.frame.size, self.view.bounds.size)) {
        self.collectionView.frame = self.view.bounds;
    }
    CGFloat operationToolBarViewHeight = 0;
    if (self.allowsMultipleSelection) {
        operationToolBarViewHeight = ToolBarHeight;
        self.operationToolBarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - operationToolBarViewHeight, CGRectGetWidth(self.view.bounds), operationToolBarViewHeight);
        self.previewButton.frame = CGRectSetXY(self.previewButton.frame, OperationToolBarViewPaddingHorizontal, CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.frame) - IPhoneXSafeAreaInsets.bottom, CGRectGetHeight(self.previewButton.frame)));
        self.sendButton.frame = CGRectMake(CGRectGetWidth(self.operationToolBarView.frame) - OperationToolBarViewPaddingHorizontal - CGRectGetWidth(self.sendButton.frame), CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.frame) - IPhoneXSafeAreaInsets.bottom, CGRectGetHeight(self.sendButton.frame)), CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.sendButton.frame));
        self.imageCountLabel.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - ImageCountLabelSize.width - 5, CGRectGetMinY(self.sendButton.frame) + CGFloatGetCenter(CGRectGetHeight(self.sendButton.frame), ImageCountLabelSize.height), ImageCountLabelSize.width, ImageCountLabelSize.height);
        operationToolBarViewHeight = CGRectGetHeight(self.operationToolBarView.frame);
    }
    if (self.collectionView.contentInset.bottom != operationToolBarViewHeight) {
        self.collectionView.contentInset = UIEdgeInsetsSetBottom(self.collectionView.contentInset, operationToolBarViewHeight);
        self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset;
        // 放在这里是因为有时候会先走完 refreshWithAssetsGroup 里的 completion 再走到这里，此时前者不会导致 scollToInitialPosition 的滚动，所以在这里再调用一次保证一定会滚
        [self scrollToInitialPositionIfNeeded];
    }
}

- (void)refreshWithImagesArray:(NSMutableArray<QMUIAsset *> *)imagesArray {
    _imagesAssetArray = imagesArray;
    [self.collectionView reloadData];
}

- (void)refreshWithAssetsGroup:(QMUIAssetsGroup *)assetsGroup {
    _assetsGroup = assetsGroup;
    if (!self.imagesAssetArray) {
        _imagesAssetArray = [[NSMutableArray alloc] init];
    } else {
        [self.imagesAssetArray removeAllObjects];
    }
    // 通过 QMUIAssetsGroup 获取该相册所有的图片 QMUIAsset，并且储存到数组中
    QMUIAlbumSortType albumSortType = QMUIAlbumSortTypePositive;
    // 从 delegate 中获取相册内容的排序方式，如果没有实现这个 delegate，则使用 QMUIAlbumSortType 的默认值，即最新的内容排在最后面
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)]) {
        albumSortType = [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self];
    }
    // 遍历相册内的资源较为耗时，交给子线程去处理，因此这里需要显示 Loading
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerWillStartLoading:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewControllerWillStartLoading:self];
    }
    if (self.shouldShowDefaultLoadingView) {
        [self showEmptyViewWithLoading];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [assetsGroup enumerateAssetsWithOptions:albumSortType usingBlock:^(QMUIAsset *resultAsset) {
            // 这里需要对 UI 进行操作，因此放回主线程处理
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultAsset) {
                    self.isImagesAssetLoaded = NO;
                    [self.imagesAssetArray addObject:resultAsset];
                } else {
                    // result 为 nil，即遍历相片或视频完毕
                    self.isImagesAssetLoaded = YES;// 这个属性的作用描述： https://github.com/QMUI/QMUI_iOS/issues/219
                    [self.collectionView reloadData];
                    [self.collectionView performBatchUpdates:NULL completion:^(BOOL finished) {
                        [self scrollToInitialPositionIfNeeded];
                        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerWillFinishLoading:)]) {
                          [self.imagePickerViewControllerDelegate imagePickerViewControllerWillFinishLoading:self];
                        }
                        if (self.shouldShowDefaultLoadingView) {
                          [self hideEmptyView];
                        }
                    }];
                }
            });
        }];
    });
}

- (void)initPreviewViewControllerIfNeeded {
    if (!self.imagePickerPreviewViewController) {
        self.imagePickerPreviewViewController = [self.imagePickerViewControllerDelegate imagePickerPreviewViewControllerForImagePickerViewController:self];
        self.imagePickerPreviewViewController.maximumSelectImageCount = self.maximumSelectImageCount;
        self.imagePickerPreviewViewController.minimumSelectImageCount = self.minimumSelectImageCount;
    }
}

- (CGSize)referenceImageSize {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat collectionViewContentSpacing = collectionViewWidth - UIEdgeInsetsGetHorizontalValue(self.collectionView.contentInset);
    NSInteger columnCount = floor(collectionViewContentSpacing / self.minimumImageWidth);
    CGFloat referenceImageWidth = self.minimumImageWidth;
    BOOL isSpacingEnoughWhenDisplayInMinImageSize = UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset) + (self.minimumImageWidth + self.collectionViewLayout.minimumInteritemSpacing) * columnCount - self.collectionViewLayout.minimumInteritemSpacing <= collectionViewContentSpacing;
    if (!isSpacingEnoughWhenDisplayInMinImageSize) {
        // 算上图片之间的间隙后发现其实还是放不下啦，所以得把列数减少，然后放大图片以撑满剩余空间
        columnCount -= 1;
    }
    referenceImageWidth = (collectionViewContentSpacing - UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset) - self.collectionViewLayout.minimumInteritemSpacing * (columnCount - 1)) / columnCount;
    return CGSizeMake(referenceImageWidth, referenceImageWidth);
}

- (void)setMinimumImageWidth:(CGFloat)minimumImageWidth {
    _minimumImageWidth = minimumImageWidth;
    [self referenceImageSize];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)scrollToInitialPositionIfNeeded {
    if (self.collectionView.window && self.isImagesAssetLoaded && !self.hasScrollToInitialPosition) {
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)] && [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self] == QMUIAlbumSortTypeReverse) {
            [self.collectionView qmui_scrollToTop];
        } else {
            [self.collectionView qmui_scrollToBottom];
        }
        self.hasScrollToInitialPosition = YES;
    }
}

- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated {
    self.hasScrollToInitialPosition = NO;
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesAssetArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self referenceImageSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = kImageOrUnknownCellIdentifier;
    // 获取需要显示的资源
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    if (imageAsset.assetType == QMUIAssetTypeVideo) {
        identifier = kVideoCellIdentifier;
    }
    QMUIImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // 异步请求资源对应的缩略图
    [imageAsset requestThumbnailImageWithSize:[self referenceImageSize] completion:^(UIImage *result, NSDictionary *info) {
        if (!info || [[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            // 模糊，此时为同步调用
            cell.contentImageView.image = result;
        } else if ([collectionView qmui_itemVisibleAtIndexPath:indexPath]) {
            // 清晰，此时为异步调用
            QMUIImagePickerCollectionViewCell *anotherCell = (QMUIImagePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
            anotherCell.contentImageView.image = result;
        }
    }];
    
    if (imageAsset.assetType == QMUIAssetTypeVideo) {
        cell.videoDurationLabel.text = [NSString qmui_timeStringWithMinsAndSecsFromSecs:imageAsset.duration];
    }
    
    [cell.checkboxButton addTarget:self action:@selector(handleCheckBoxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.selectable = self.allowsMultipleSelection;
    if (cell.selectable) {
        // 如果该图片的 QMUIAsset 被包含在已选择图片的数组中，则控制该图片被选中
        cell.checked = [QMUIImagePickerHelper imageAssetArray:_selectedImageAssetArray containsImageAsset:imageAsset];
    }
    [cell setNeedsLayout];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didSelectImageWithImagesAsset:afterImagePickerPreviewViewControllerUpdate:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self didSelectImageWithImagesAsset:imageAsset afterImagePickerPreviewViewControllerUpdate:self.imagePickerPreviewViewController];
    }
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerPreviewViewControllerForImagePickerViewController:)]) {
        [self initPreviewViewControllerIfNeeded];
        if (!self.allowsMultipleSelection) {
            // 单选的情况下
            [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:@[imageAsset]
                                                                        selectedImageAssetArray:nil
                                                                              currentImageIndex:0
                                                                                singleCheckMode:YES];
        } else {
            // cell 处于编辑状态，即图片允许多选
            [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:self.imagesAssetArray
                                                                        selectedImageAssetArray:_selectedImageAssetArray
                                                                              currentImageIndex:indexPath.item
                                                                                singleCheckMode:NO];
        }
        [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
    }
}

#pragma mark - 按钮点击回调

- (void)handleSendButtonClick:(id)sender {
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImagesAssetArray:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self didFinishPickingImageWithImagesAssetArray:_selectedImageAssetArray];
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handlePreviewButtonClick:(id)sender {
    [self initPreviewViewControllerIfNeeded];
    // 手工更新图片预览界面
    [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:[_selectedImageAssetArray copy]
                                                                selectedImageAssetArray:_selectedImageAssetArray
                                                                      currentImageIndex:0
                                                                        singleCheckMode:NO];
    [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
}

- (void)handleCancelPickerImage:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^() {
        if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerDidCancel:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewControllerDidCancel:self];
        }
    }];
}

- (void)handleCheckBoxButtonClick:(id)sender {
    UIButton *checkBoxButton = sender;
    NSIndexPath *indexPath = [self.collectionView qmui_indexPathForItemAtView:checkBoxButton];
    
    QMUIImagePickerCollectionViewCell *cell = (QMUIImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    if (cell.checked) {
        // 移除选中状态
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willUncheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self willUncheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = NO;
        [QMUIImagePickerHelper imageAssetArray:_selectedImageAssetArray removeImageAsset:imageAsset];
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didUncheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self didUncheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
    } else {
        // 选中该资源
        if ([_selectedImageAssetArray count] >= _maximumSelectImageCount) {
            if (!_alertTitleWhenExceedMaxSelectImageCount) {
                _alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(_maximumSelectImageCount)];
            }
            if (!_alertButtonTitleWhenExceedMaxSelectImageCount) {
                _alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:_alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:[QMUIAlertAction actionWithTitle:_alertButtonTitleWhenExceedMaxSelectImageCount style:QMUIAlertActionStyleCancel handler:nil]];
            [alertController showWithAnimated:YES];
            return;
        }
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willCheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self willCheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = YES;
        [_selectedImageAssetArray addObject:imageAsset];
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didCheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self didCheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
        
        // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
        [self requestImageWithIndexPath:indexPath];
    }
}

- (void)updateImageCountAndCheckLimited {
    NSInteger selectedImageCount = [_selectedImageAssetArray count];
    if (selectedImageCount > 0 && selectedImageCount >= _minimumSelectImageCount) {
        self.previewButton.enabled = YES;
        self.sendButton.enabled = YES;
        self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
        self.imageCountLabel.hidden = NO;
        [QMUIImagePickerHelper springAnimationOfImageSelectedCountChangeWithCountLabel:self.imageCountLabel];
    } else {
        self.previewButton.enabled = NO;
        self.sendButton.enabled = NO;
        self.imageCountLabel.hidden = YES;
    }
}

#pragma mark - Request Image

- (void)requestImageWithIndexPath:(NSIndexPath *)indexPath {
    // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    QMUIImagePickerCollectionViewCell *cell = (QMUIImagePickerCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    imageAsset.requestID = [imageAsset requestPreviewImageWithCompletion:^(UIImage *result, NSDictionary *info) {
        
        BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadSucceed) {
            // 资源资源已经在本地或下载成功
            [imageAsset updateDownloadStatusWithDownloadResult:YES];
            cell.downloadStatus = QMUIAssetDownloadStatusSucceed;
            
        } else if ([info objectForKey:PHImageErrorKey] ) {
            // 下载错误
            [imageAsset updateDownloadStatusWithDownloadResult:NO];
            cell.downloadStatus = QMUIAssetDownloadStatusFailed;
        }
        
    } withProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.collectionView qmui_itemVisibleAtIndexPath:indexPath]) {
                
                QMUILogInfo(@"QMUIImagePickerLibrary", @"Download iCloud image, current progress is : %f", progress);
                
                if (cell.downloadStatus != QMUIAssetDownloadStatusDownloading) {
                    cell.downloadStatus = QMUIAssetDownloadStatusDownloading;
                    // 预先设置预览界面的下载状态
                    self.imagePickerPreviewViewController.downloadStatus = QMUIAssetDownloadStatusDownloading;
                }
                if (error) {
                    QMUILog(@"QMUIImagePickerLibrary", @"Download iCloud image Failed, current progress is: %f", progress);
                    cell.downloadStatus = QMUIAssetDownloadStatusFailed;
                }
            }
        });
    }];
}

@end