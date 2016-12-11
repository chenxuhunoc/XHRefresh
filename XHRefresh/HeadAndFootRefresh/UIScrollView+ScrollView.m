//
//  UIScrollView+ScrollView.m
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/27.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import "UIScrollView+ScrollView.h"
#import <objc/runtime.h>

@interface UIScrollView ()

@end

static const char *pullkey = "key";

@implementation UIScrollView (ScrollView)

#pragma mark
#pragma mark 下拉刷新
- (XHPullRefresh *)pullRefresh
{
    // 读取XHPullRefresh
    XHPullRefresh *pRefresh = objc_getAssociatedObject(self, pullkey);
    if (pRefresh == nil)
    {
        // 将刷新控件添加视图
        pRefresh = [[XHPullRefresh alloc] init];
        [self addSubview:pRefresh];
        
        // 储存XHPullRefresh对象
        self.pullRefresh = pRefresh;
    }
    return pRefresh;
}

- (void)setPullRefresh:(XHPullRefresh *)pullRefresh
{
    // id object 那个对象需要储存数据
    // key 储存数据需要的名称
    // id value 要储存的数据
    // objc_AssociationPolicy 引用
    objc_setAssociatedObject(self, pullkey, pullRefresh, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
