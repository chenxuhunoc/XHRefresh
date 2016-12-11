//
//  XHPullUPRefresh.h
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/26.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XHPullUPRefresh : UIView

// BLock传值
@property(nonatomic, copy) void(^refreshEndBlock)();

// 结束刷新
- (void)endUPRefresh;
@end
