//
//  XHPullUPRefresh.m
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/26.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import "XHPullUPRefresh.h"

#define kViewWidth [UIScreen mainScreen].bounds.size.width
#define kViewHeight self.frame.size.height

typedef enum : NSUInteger {
    
    XHPullUPRefreshNormal,  // 正常状态，无刷新
    XHPullUPRefreshPulling, // 上拉刷新
    XHPullUPRefreshing,     // 刷新中
    
} XHPullUPRefreshStatus;
@interface XHPullUPRefresh ()

@property(nonatomic, strong)UIImageView *animationImageView;
@property(nonatomic, strong)NSArray *images;
@property(nonatomic, strong)UILabel *statuLable;

// 储存父视图
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, assign)XHPullUPRefreshStatus refreshStatu;

@end

@implementation XHPullUPRefresh

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor lightGrayColor];
        self.frame = CGRectMake(0, 0, kViewWidth, 50);
        
        // 添加控件
        [self addSubview:self.animationImageView];
        [self addSubview:self.statuLable];
        
        // 设置Frame
        self.animationImageView.frame = CGRectMake(kViewWidth/2 - 18/2 - 36, kViewHeight/2 - 20/2, 20, 20);
        self.statuLable.frame = CGRectMake(self.animationImageView.frame.origin.x + 25, kViewHeight/2 - 20/2, 100, 20);
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
        self.scrollView = (UIScrollView *)newSuperview;
        
        // 开始监听滚动 使用KVO 键值来监听滚动
        // tip: 使KVO或者是KVC都要执行 添加--移除的流程
        [self.scrollView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
        // 监听contentOffset
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:NULL];
    }
}

// 开始监听frame改变
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 判断是否是父视图的contentSize
    if ([keyPath isEqualToString:@"contentSize"])
    {
        // 更新刷新控件的Frame
        [UIView animateWithDuration:.3 animations:^{
            
            CGRect frame = self.frame;
            frame.origin.y = self.scrollView.contentSize.height;
            self.frame = frame;
            
        }];
    }
    else if ([keyPath isEqualToString:@"contentOffset"])
    {
        //NSLog(@"yy === %f",self.scrollView.contentOffset.y);
        if (self.scrollView.isDragging && self.scrollView.contentOffset.y > 0)
        {
            // 手拖动
            //CGFloat normalPullingoffset = 128;
            if (self.refreshStatu == XHPullUPRefreshPulling && self.scrollView.contentOffset.y + self.scrollView.frame.size.height < self.scrollView.contentSize.height + 64)
            {
                // 设置normal状态
                self.refreshStatu = XHPullUPRefreshNormal;
                
                NSLog(@"正常状态");
                
            }
            else if (self.refreshStatu == XHPullUPRefreshNormal && self.scrollView.contentOffset.y + self.scrollView.frame.size.height >= self.scrollView.contentSize.height + 64)
            {
                // 设置pulling状态
                self.refreshStatu = XHPullUPRefreshPulling;
                
                NSLog(@"拖拽状态");
            }
        }
        else
        {
            // 手动开
            if (self.refreshStatu == XHPullUPRefreshPulling)
            {
                // 设置刷新状态
                self.refreshStatu = XHPullUPRefreshing;
                
                NSLog(@"刷新状态");
            }
        }
    }
}

// 重写状态来更改状态值
- (void)setRefreshStatu:(XHPullUPRefreshStatus)refreshStatu
{
    _refreshStatu = refreshStatu;
    switch (_refreshStatu)
    {
        case XHPullUPRefreshNormal:
            
            [self.animationImageView stopAnimating];
            [self.animationImageView setImage:[UIImage imageNamed:@"up"]];
            self.statuLable.text = @"上拉刷新数据";
            
            break;
        case XHPullUPRefreshPulling:
            
            [self.animationImageView setImage:[UIImage imageNamed:@"pull"]];
            self.statuLable.text = @"释放刷新数据";
            
            break;
        case XHPullUPRefreshing:
            
            self.statuLable.text = @"正在刷新数据";
            [self.animationImageView setAnimationImages:self.images];
            self.animationImageView.animationDuration = 0.1 * self.images.count;
            [self.animationImageView startAnimating];
            
            // 设置停顿状态
            UIEdgeInsets inset = self.scrollView.contentInset;
            inset.bottom = inset.bottom + 50;
            [UIView animateWithDuration:.2 animations:^{
                
                self.scrollView.contentInset = inset;
                
            } completion:^(BOOL finished) {
                
                // 结束刷新 控件上移 使用Block传值
                // Block: 定义Block -> 传递Block -> 调用Block
                // 确定Block是否有值再进行,编程良好习惯
                if (self.refreshEndBlock)
                {
                    self.refreshEndBlock();
                }
            }];
            break;
    }
}

- (void)endUPRefresh
{
    // refreshing -> normal
    if (self.refreshStatu == XHPullUPRefreshing)
    {
        // 设置停顿状态
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.bottom = inset.bottom - 50;
        self.scrollView.contentInset = inset;
        
        // 改变状态
        self.refreshStatu = XHPullUPRefreshNormal;
    }
}

// 移除KVO
- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}


- (UIImageView *)animationImageView
{
    if (_animationImageView == nil)
    {
        _animationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"up"]];
    }
    return _animationImageView;
}

- (UILabel *)statuLable
{
    if (_statuLable == nil)
    {
        _statuLable = [[UILabel alloc] init];
        _statuLable.text = @"上拉刷新数据";
        _statuLable.font = [UIFont systemFontOfSize:15];
    }
    return _statuLable;
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


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
