//
//  UIScrollView+ScrollView.h
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/27.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHPullRefresh.h"
#import "XHPullUPRefresh.h"

@interface UIScrollView (ScrollView)

@property(nonatomic, strong)XHPullRefresh *pullRefresh;

@end
