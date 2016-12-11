//
//  UIScrollView+UPullRefresh.m
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/27.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import "UIScrollView+UPullRefresh.h"
#import <objc/runtime.h>

static const char *upPullkey = "key";
@implementation UIScrollView (UPullRefresh)

#pragma mark
#pragma mark  上拉刷新
- (XHPullUPRefresh *)pullUPRefresh
{
    XHPullUPRefresh *upRefesh = objc_getAssociatedObject(self, upPullkey);
    if (upRefesh == nil)
    {
        // 将上拉刷新添加到视图
        upRefesh = [[XHPullUPRefresh alloc] init];
        [self addSubview:upRefesh];
        
        // 储存XHPullUPRefresh对象
        self.pullUPRefresh = upRefesh;
    }
    return upRefesh;
}

- (void)setPullUPRefresh:(XHPullUPRefresh *)pullUPRefresh
{
    objc_setAssociatedObject(self, upPullkey, pullUPRefresh, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
