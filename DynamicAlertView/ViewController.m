//
//  ViewController.m
//  DynamicAlertView
//
//  Created by 邱豪 on 2018/3/31.
//  Copyright © 2018年 邱豪. All rights reserved.
//

#import "ViewController.h"
#import "DynamicAlertView.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_dataSource;
}
@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ViewController

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        if (@available(iOS 11.0,*)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAlways;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
        }
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSource = @[@"AppearStyle", @"SnapStyle"];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DynamicAlertStyleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [DynamicAlertView instanceAlertView].showStyle = DynamicAlertViewShowStyleAppear;
    }else if(indexPath.row == 1){
        [DynamicAlertView instanceAlertView].showStyle = DynamicAlertViewShowStyleSnap;
    }
    [[DynamicAlertView instanceAlertView] showAlertViewWithDescription:@"自定义弹出视图" withAction:^(NSInteger index) {
        if (index == 0) {
            NSLog(@"点击了确定");
        }else if (index == 1) {
            NSLog(@"点击了取消");
        }
    } WithTitles:@"确定", @"取消", nil];
}

@end
