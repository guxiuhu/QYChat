//
//  AGEmojiKeyboardView.m
//  AGEmojiKeyboard
//
//  Created by Ayush on 09/05/13.
//  Copyright (c) 2013 Ayush. All rights reserved.
//

#import "AGEmojiKeyBoardView.h"
#import "AGEmojiPageView.h"
#import "Masonry.h"
#import "HMSegmentedControl.h"

static const CGFloat ButtonWidth = 45;
static const CGFloat ButtonHeight = 37;

#define BASIC_BACKGROUND_COLOR [UIColor colorWithRed:0.976 green:0.976 blue:0.976 alpha:1.00]
#define BASIC_COLOR [UIColor colorWithRed:0.984 green:0.984 blue:0.984 alpha:1.00]

@interface AGEmojiKeyboardView () <UIScrollViewDelegate, AGEmojiPageViewDelegate>

@property (nonatomic) HMSegmentedControl *segmentsBar;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) UIScrollView *emojiPagesScrollView;
@property (nonatomic) NSDictionary *emojis;
@property (nonatomic) NSMutableArray *pageViews;
@property (nonatomic) NSString *category;

@end

@implementation AGEmojiKeyboardView

- (NSString *)categoryNameAtIndex:(NSUInteger)index {
    NSArray *categoryList = @[@"People", @"Objects", @"Nature", @"Places", @"Symbols"];
    return categoryList[index];
}

- (AGEmojiKeyboardViewCategoryImage)defaultSelectedCategory {
    if ([self.dataSource respondsToSelector:@selector(defaultCategoryForEmojiKeyboardView:)]) {
        return [self.dataSource defaultCategoryForEmojiKeyboardView:self];
    }else{
        return AGEmojiKeyboardViewCategoryImageFace;
    }
}

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<AGEmojiKeyboardViewDataSource>)dataSource {
    self = [super initWithFrame:frame];
    if (self) {
        // initialize category
        
        [self setBackgroundColor:BASIC_BACKGROUND_COLOR];
        
        _dataSource = dataSource;
        
        self.category = [self categoryNameAtIndex:self.defaultSelectedCategory];
        
        //底部工具栏
        self.toolbar = [[UIView alloc]initWithFrame:CGRectZero];
        [self.toolbar setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:self.toolbar];
        
        //表情切换
        self.segmentsBar = [[HMSegmentedControl alloc] initWithSectionImages:@[[UIImage imageNamed:@"emoji_1"]] sectionSelectedImages:@[[UIImage imageNamed:@"emoji_1"]]];

        self.segmentsBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.segmentsBar.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
        self.segmentsBar.selectionStyle = HMSegmentedControlSelectionStyleBox;
        self.segmentsBar.selectionIndicatorColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
        [self.segmentsBar addTarget:self action:@selector(categoryChangedViaSegmentsBar:) forControlEvents:UIControlEventValueChanged];
        self.segmentsBar.selectedSegmentIndex = self.defaultSelectedCategory;
        
        [self.toolbar addSubview:self.segmentsBar];
        [self.segmentsBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.bottom.equalTo(self.toolbar);
//            make.right.equalTo(self.toolbar.mas_right).with.offset(-60);
            make.width.mas_equalTo(50);
            
        }];
        
        //工具栏
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [sendBtn setFrame:CGRectMake(CGRectGetWidth(self.bounds)-60,0,60,CGRectGetHeight(self.toolbar.bounds))];
        [sendBtn addTarget:self action:@selector(sendCurrentAction:) forControlEvents:UIControlEventTouchUpInside];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:UIColorWhite forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage qmui_imageWithColor:UI_BASE_COLOR size:CGSizeMake(60, 40) cornerRadius:0] forState:UIControlStateNormal];
        [self.toolbar addSubview:sendBtn];
        [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.top.and.bottom.equalTo(self.toolbar);
            make.width.mas_equalTo(60);
        }];
        
        //指示器
        self.pageControl = [[UIPageControl alloc] init];
        self.pageControl.hidesForSinglePage = YES;
        self.pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0.545 green:0.545 blue:0.545 alpha:1.00];
        self.pageControl.pageIndicatorTintColor = [UIColor colorWithRed:0.733 green:0.733 blue:0.733 alpha:1.00];
        self.pageControl.currentPage = 0;
        self.pageControl.backgroundColor = [UIColor clearColor];
        CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
        CGSize frameSize = CGSizeMake(CGRectGetWidth(self.bounds),
                                      CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
        NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                      inFrameSize:frameSize];
        self.pageControl.numberOfPages = numberOfPages;
        pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
        CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                             CGRectGetHeight(self.bounds) - pageControlSize.height,
                                             pageControlSize.width,
                                             pageControlSize.height);
        self.pageControl.frame = CGRectIntegral(pageControlFrame);
        [self.pageControl addTarget:self
                             action:@selector(pageControlTouched:)
                   forControlEvents:UIControlEventValueChanged];
        [self addSubview:self.pageControl];
        
        CGRect scrollViewFrame = CGRectMake(0,
                                            CGRectGetHeight(self.segmentsBar.bounds),
                                            CGRectGetWidth(self.bounds),
                                            CGRectGetHeight(self.bounds) - CGRectGetHeight(self.segmentsBar.bounds) - pageControlSize.height);
        self.emojiPagesScrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        self.emojiPagesScrollView.pagingEnabled = YES;
        self.emojiPagesScrollView.showsHorizontalScrollIndicator = NO;
        self.emojiPagesScrollView.showsVerticalScrollIndicator = NO;
        self.emojiPagesScrollView.delegate = self;
        
        [self addSubview:self.emojiPagesScrollView];
    }
    return self;
}

- (void)layoutSubviews {
    
    self.toolbar.frame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - 40,
                                    CGRectGetWidth(self.bounds),
                                    40);
    
    CGSize pageControlSize = [self.pageControl sizeForNumberOfPages:3];
    NSUInteger numberOfPages = [self numberOfPagesForCategory:self.category
                                                  inFrameSize:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - CGRectGetHeight(self.toolbar.bounds) - pageControlSize.height)];
    
    NSInteger currentPage = (self.pageControl.currentPage > numberOfPages) ? numberOfPages : self.pageControl.currentPage;
    
    // if (currentPage > numberOfPages) it is set implicitly to max pageNumber available
    self.pageControl.numberOfPages = numberOfPages;
    pageControlSize = [self.pageControl sizeForNumberOfPages:numberOfPages];
    CGRect pageControlFrame = CGRectMake((CGRectGetWidth(self.bounds) - pageControlSize.width) / 2,
                                         CGRectGetHeight(self.bounds) - pageControlSize.height - CGRectGetHeight(self.segmentsBar.bounds),
                                         pageControlSize.width,
                                         pageControlSize.height);
    self.pageControl.frame = CGRectIntegral(pageControlFrame);
    
    self.emojiPagesScrollView.frame = CGRectMake(0,
                                                 10,
                                                 CGRectGetWidth(self.bounds),
                                                 CGRectGetHeight(self.bounds) - CGRectGetHeight(self.toolbar.bounds) - pageControlSize.height);
    [self.emojiPagesScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.emojiPagesScrollView.contentOffset = CGPointMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * currentPage, 0);
    self.emojiPagesScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.emojiPagesScrollView.bounds) * numberOfPages,
                                                       CGRectGetHeight(self.emojiPagesScrollView.bounds));
    [self purgePageViews];
    self.pageViews = [NSMutableArray array];
    [self setPage:currentPage];
}

#pragma mark event handlers

- (void)categoryChangedViaSegmentsBar:(UISegmentedControl *)sender {
    // recalculate number of pages for new category and recreate emoji pages
    self.category = [self categoryNameAtIndex:sender.selectedSegmentIndex];
    
    self.pageControl.currentPage = 0;
    [self setNeedsLayout];
}

- (void)pageControlTouched:(UIPageControl *)sender {
    CGRect bounds = self.emojiPagesScrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * sender.currentPage;
    bounds.origin.y = 0;
    // scrollViewDidScroll is called here. Page set at that time.
    [self.emojiPagesScrollView scrollRectToVisible:bounds animated:YES];
}

// Track the contentOffset of the scroll view, and when it passes the mid
// point of the current view’s width, the views are reconfigured.
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = CGRectGetWidth(scrollView.frame);
    NSInteger newPageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.pageControl.currentPage == newPageNumber) {
        return;
    }
    self.pageControl.currentPage = newPageNumber;
    [self setPage:self.pageControl.currentPage];
}

#pragma mark change a page on scrollView

// Check if setting pageView for an index is required
- (BOOL)requireToSetPageViewForIndex:(NSUInteger)index {
    if (index >= self.pageControl.numberOfPages) {
        return NO;
    }
    for (AGEmojiPageView *page in self.pageViews) {
        if ((page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds)) == index) {
            return NO;
        }
    }
    return YES;
}

// Create a pageView and add it to the scroll view.
- (AGEmojiPageView *)synthesizeEmojiPageView {
    NSUInteger rows = [self numberOfRowsForFrameSize:self.emojiPagesScrollView.bounds.size];
    NSUInteger columns = [self numberOfColumnsForFrameSize:self.emojiPagesScrollView.bounds.size];
    CGRect pageViewFrame = CGRectMake(0,
                                      0,
                                      CGRectGetWidth(self.emojiPagesScrollView.bounds),
                                      CGRectGetHeight(self.emojiPagesScrollView.bounds));
    AGEmojiPageView *pageView = [[AGEmojiPageView alloc] initWithFrame: pageViewFrame
                                                  backSpaceButtonImage:[self.dataSource backSpaceButtonImageForEmojiKeyboardView:self]
                                                            buttonSize:CGSizeMake(ButtonWidth, ButtonHeight)
                                                                  rows:rows
                                                               columns:columns];
    pageView.delegate = self;
    [self.pageViews addObject:pageView];
    [self.emojiPagesScrollView addSubview:pageView];
    return pageView;
}

// return a pageView that can be used in the current scrollView.
// look for an available pageView in current pageView-s on scrollView.
// If all are in use i.e. are of current page or neighbours
// of current page, we create a new one

- (AGEmojiPageView *)usableEmojiPageView {
    AGEmojiPageView *pageView = nil;
    for (AGEmojiPageView *page in self.pageViews) {
        NSUInteger pageNumber = page.frame.origin.x / CGRectGetWidth(self.emojiPagesScrollView.bounds);
        if (abs((int)(pageNumber - self.pageControl.currentPage)) > 1) {
            pageView = page;
            break;
        }
    }
    if (!pageView) {
        pageView = [self synthesizeEmojiPageView];
    }
    return pageView;
}

// Set emoji page view for given index.
- (void)setEmojiPageViewInScrollView:(UIScrollView *)scrollView atIndex:(NSUInteger)index {
    
    if (![self requireToSetPageViewForIndex:index]) {
        return;
    }
    
    AGEmojiPageView *pageView = [self usableEmojiPageView];
    
    NSUInteger rows = [self numberOfRowsForFrameSize:scrollView.bounds.size];
    NSUInteger columns = [self numberOfColumnsForFrameSize:scrollView.bounds.size];
    NSUInteger startingIndex = index * (rows * columns - 1);
    NSUInteger endingIndex = (index + 1) * (rows * columns - 1);
    NSMutableArray *buttonTexts = [self emojiTextsForCategory:self.category
                                                    fromIndex:startingIndex
                                                      toIndex:endingIndex];
    [pageView setButtonTexts:buttonTexts];
    pageView.frame = CGRectMake(index * CGRectGetWidth(scrollView.bounds),
                                0,
                                CGRectGetWidth(scrollView.bounds),
                                CGRectGetHeight(scrollView.bounds));
}

// Set the current page.
// sets neightbouring pages too, as they are viewable by part scrolling.
- (void)setPage:(NSInteger)page {
    [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page - 1];
    [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page];
    [self setEmojiPageViewInScrollView:self.emojiPagesScrollView atIndex:page + 1];
}

- (void)purgePageViews {
    for (AGEmojiPageView *page in self.pageViews) {
        page.delegate = nil;
    }
    self.pageViews = nil;
}

#pragma mark data methods

- (NSUInteger)numberOfColumnsForFrameSize:(CGSize)frameSize {
    return (NSUInteger)floor(frameSize.width / ButtonWidth);
}

- (NSUInteger)numberOfRowsForFrameSize:(CGSize)frameSize {
    return (NSUInteger)floor(frameSize.height / ButtonHeight);
}

- (NSArray *)emojiListForCategory:(NSString *)category {

    NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:80];
    for (int i = 1; i <= 80; i++) {
        [ary addObject:[NSString stringWithFormat:@"%02d",i]];
    }
    
    return ary;
}

// for a given frame size of scroll view, return the number of pages
// required to show all the emojis for a category
- (NSUInteger)numberOfPagesForCategory:(NSString *)category inFrameSize:(CGSize)frameSize {
    
    NSUInteger emojiCount = [[self emojiListForCategory:category] count];
    NSUInteger numberOfRows = [self numberOfRowsForFrameSize:frameSize];
    NSUInteger numberOfColumns = [self numberOfColumnsForFrameSize:frameSize];
    NSUInteger numberOfEmojisOnAPage = (numberOfRows * numberOfColumns) - 1;
    
    NSUInteger numberOfPages = (NSUInteger)ceil((float)emojiCount / numberOfEmojisOnAPage);
    return numberOfPages;
}

// return the emojis for a category, given a staring and an ending index
- (NSMutableArray *)emojiTextsForCategory:(NSString *)category
                                fromIndex:(NSUInteger)start
                                  toIndex:(NSUInteger)end {
    NSArray *emojis = [self emojiListForCategory:category];
    end = ([emojis count] > end)? end : [emojis count];
    NSIndexSet *index = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(start, end-start)];
    return [[emojis objectsAtIndexes:index] mutableCopy];
}

#pragma mark EmojiPageViewDelegate

// add the emoji to recents
- (void)emojiPageView:(AGEmojiPageView *)emojiPageView didUseEmoji:(NSString *)emoji {
    [self.delegate emojiKeyBoardView:self didUseEmoji:emoji];
}

- (void)emojiPageViewDidPressBackSpace:(AGEmojiPageView *)emojiPageView {
    if ([self.delegate respondsToSelector:@selector(emojiKeyBoardViewDidPressBackSpace:)]) {
        [self.delegate emojiKeyBoardViewDidPressBackSpace:self];
    }
}

-(void)sendCurrentAction:(id)sender{
    
    if ([self.delegate respondsToSelector:@selector(emojiKeyBoardViewDidPressSend:)]) {
        [self.delegate emojiKeyBoardViewDidPressSend:self];
    }
}
@end
