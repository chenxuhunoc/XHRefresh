//
//  XHPullRefresh.h
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/26.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHPullRefresh : UIView

// 定义Block
@property(nonatomic, copy) void(^refreshBlock)();

// 开始刷新
- (void)starPullRefresh;

// 结束刷新
- (void)endPullRefresh;
@end
