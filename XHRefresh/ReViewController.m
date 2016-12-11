//
//  ReViewController.m
//  XHRefresh
//
//  Created by 陈绪混 on 2016/11/26.
//  Copyright © 2016年 Chenxuhun. All rights reserved.
//

#import "ReViewController.h"
#import "XHRefresh.h"

@interface ReViewController ()<UITableViewDelegate, UITableViewDataSource>

// 刷新控件
@property(nonatomic, strong)XHPullRefresh *pullRefresh;
@property(nonatomic, strong)XHPullUPRefresh *upRefresh;
// 数据源
@property(nonatomic, strong)NSMutableArray *sourceArr;

@property(nonatomic, strong)UITableView *tableView;

@end

@implementation ReViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sourceArr = [NSMutableArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17", nil];
    
    // 加载TableView
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    UIView *footView = [[UIView alloc] init];
    self.tableView.tableFooterView = footView;
    
    __weak ReViewController *wSelf = self;
    // 下拉刷新数据  方式一
    //    [self.tableView.pullRefresh setRefreshBlock:^{
    //
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //            // 加载假数据
    //            NSArray *arr = [NSArray arrayWithObjects:@"4",@"5", nil];
    //            [wSelf.sourceArr addObjectsFromArray:arr];
    //
    //            [wSelf.tableView reloadData];
    //            [wSelf.tableView.pullRefresh endPullRefresh];
    //        });
    //    }];
    
    // 下拉刷新数据 创建方式二
    self.pullRefresh = [[XHPullRefresh alloc] init];
    [self.tableView addSubview:self.pullRefresh];
    [wSelf.pullRefresh setRefreshBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 加载假数据
            NSArray *arr = [NSArray arrayWithObjects:@"4",@"5", nil];
            [wSelf.sourceArr addObjectsFromArray:arr];
            
            [wSelf.tableView reloadData];
            [wSelf.pullRefresh endPullRefresh];
        });
        
    }];
    
    // =======================  华丽的分割线  ========================
    // 上拉刷新数据 方式一
    self.upRefresh = [[XHPullUPRefresh alloc] init];
    [self.tableView addSubview:self.upRefresh];
    [wSelf.upRefresh setRefreshEndBlock:^{
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            // 加载假数据
            NSArray *arr = [NSArray arrayWithObjects:@"4",@"5", nil];
            [wSelf.sourceArr addObjectsFromArray:arr];
            
            [wSelf.tableView reloadData];
            [wSelf.upRefresh endUPRefresh];
            
        });
        
    }];
    
    // 上拉刷新数据 方式二
    //    [wSelf.tableView.pullUPRefresh setRefreshEndBlock:^{
    //
    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //
    //            // 加载假数据
    //            NSArray *arr = [NSArray arrayWithObjects:@"4",@"5", nil];
    //            [wSelf.sourceArr addObjectsFromArray:arr];
    //
    //            [wSelf.tableView reloadData];
    //            [wSelf.tableView.pullUPRefresh endUPRefresh];
    //
    //        });
    //
    //    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.sourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identfier = @"identfier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identfier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identfier];
    }
    cell.textLabel.text = self.sourceArr[indexPath.row];
    return cell;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
