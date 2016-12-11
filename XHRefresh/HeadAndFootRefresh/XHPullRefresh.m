//
//  XHPullRefresh.m
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/26.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import "XHPullRefresh.h"

#define kViewWidth [UIScreen mainScreen].bounds.size.width
#define kViewHeight self.frame.size.height
#define kRefreshViewHeight 50
//  刷新状态
typedef enum : NSUInteger {
    
    XHPullRefreshNormal,  // 正常状态，没有刷新
    XHPullRefreshPulling, // 释放刷新状态
    XHPullRefreshing,     // 刷新中
    
} XHPullRefreshStatus;

// 刷新的控件
@interface XHPullRefresh ()

@property(nonatomic, strong)UIImageView *animationImageView;
@property(nonatomic, strong)NSArray *images;
@property(nonatomic, strong)UILabel *statuLabel;
@property(nonatomic, strong)UIScrollView *srollView;
@property(nonatomic, assign)XHPullRefreshStatus refreshStatu;

@end

@implementation XHPullRefresh

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor lightGrayColor];
        self.frame = CGRectMake(0, -64, kViewWidth, 50);
        
        // 添加视图
        [self addSubview:self.animationImageView];
        [self addSubview:self.statuLabel];
        
        // 设置Frame
        self.animationImageView.frame = CGRectMake(kViewWidth/2 - 18/2 - 36, kViewHeight/2 - 20/2, 20, 20);
        self.statuLabel.frame = CGRectMake(self.animationImageView.frame.origin.x + 25, kViewHeight/2 - 20/2, 100, 20);
    }
    return self;
}

// 监听滚动视图的滚动 当此控件添加到某个父视图的时候第一时间会调用
- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 判断是否是滚动视图  如TableView, CollectionView...
    // 这里最好判断UIScrollView 因滚动视图都基于它为父视图
    if ([newSuperview isKindOfClass:[UIScrollView class]])
    {
        // 暂存视图
        self.srollView = (UIScrollView *)newSuperview;
        
        // 开始监听滚动 使用KVO 键值来监听滚动
        // tip: 使KVO或者是KVC都要执行 添加--移除的流程
        [self.srollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    }
}

// 使用KVO 实现父控件的滚动
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    NSLog(@"%f",self.srollView.contentOffset.y);
    // 根据刷新状态来改变statuLabel、animationImageView的值
    // 手拖动：normarl -> pulling -> normal
    // 手松开：pulling -> refreshing
    if (self.srollView.isDragging && self.srollView.contentOffset.y < 0)
    {
        // 手拖动
        CGFloat normalPullingoffset = -100;
        if (self.refreshStatu == XHPullRefreshPulling && self.srollView.contentOffset.y > normalPullingoffset)
        {
            // 设置normal状态
            self.refreshStatu = XHPullRefreshNormal;
            
        }
        else if (self.refreshStatu == XHPullRefreshNormal && self.srollView.contentOffset.y <= normalPullingoffset)
        {
            // 设置pulling状态
            self.refreshStatu = XHPullRefreshPulling;
        }
    }
    else
    {
        // 手动开
        if (self.refreshStatu == XHPullRefreshPulling)
        {
            // 设置刷新状态
            self.refreshStatu = XHPullRefreshing;
        }
    }
}

// 重写状态来更改状态值
- (void)setRefreshStatu:(XHPullRefreshStatus)refreshStatu
{
    _refreshStatu = refreshStatu;
    switch (_refreshStatu)
    {
        case XHPullRefreshNormal:
            
            [self.animationImageView stopAnimating];
            [self.animationImageView setImage:[UIImage imageNamed:@"pull"]];
            self.statuLabel.text = @"下拉刷新数据";
            
            break;
        case XHPullRefreshPulling:
            
            [self.animationImageView setImage:[UIImage imageNamed:@"up"]];
            self.statuLabel.text = @"释放刷新数据";
            
            break;
        case XHPullRefreshing:
            
            [self.animationImageView setAnimationImages:self.images];
            self.animationImageView.animationDuration = 0.1 * self.images.count;
            [self.animationImageView startAnimating];
            self.statuLabel.text = @"正在刷新数据";
            
            // 设置停顿状态
            [UIView animateWithDuration:.3 animations:^{
                self.srollView.contentInset = UIEdgeInsetsMake(self.srollView.contentInset.top + 64, self.srollView.contentInset.left, self.srollView.contentInset.bottom, self.srollView.contentInset.right);
            }];
            
            // 结束刷新 控件上移 使用Block传值
            // Block: 定义Block -> 传递Block -> 调用Block
            // 确定Block是否有值再进行,编程良好习惯
            if (self.refreshBlock)
            {
                self.refreshBlock();
            }
            break;
    }
}

// 开始刷新
- (void)starPullRefresh
{
    self.refreshStatu = XHPullRefreshing;
    NSLog(@"执行了多少次");
}

// 结束刷新 设置控件上移
- (void)endPullRefresh
{
   // refreshing -> normal
    if (self.refreshStatu == XHPullRefreshing)
    {
        // 改变状态
        self.refreshStatu = XHPullRefreshNormal;
        
        // 让滚动视图上移
        // 设置停顿状态
        [UIView animateWithDuration:.3 animations:^{
            self.srollView.contentInset = UIEdgeInsetsMake(self.srollView.contentInset.top - 64, self.srollView.contentInset.left, self.srollView.contentInset.bottom, self.srollView.contentInset.right);
        }];
    }
}

- (void)dealloc
{
    // 移除KVO 键值监听
    [self.srollView removeObserver:self forKeyPath:@"contentOffset"];
}

// 懒加载控件
- (UIImageView *)animationImageView
{
    if (_animationImageView == nil)
    {
        _animationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull"]];
    }
    return _animationImageView;
}

- (NSArray *)images
{
    if (_images == nil)
    {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 1; i < 8; i++)
        {
            NSString *imageName = [NSString stringWithFormat:@"%d",i];
            
            UIImage *image = [UIImage imageNamed:imageName];
            
            [arr addObject:image];
        }
        _images = arr;
    }
    return _images;
}

- (UILabel *)statuLabel
{
    if (_statuLabel == nil)
    {
        _statuLabel = [[UILabel alloc] init];
        _statuLabel.text = @"下拉刷新数据";
        _statuLabel.font = [UIFont systemFontOfSize:15];
        _statuLabel.textColor = [UIColor whiteColor];
    }
    return _statuLabel;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
