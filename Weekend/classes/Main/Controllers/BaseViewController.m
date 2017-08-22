//
//  BaseViewController.m
//  Weekend
//
//  Created by Jane on 16/3/29.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchViewController.h"
#import "MJRefresh.h"
#import "MyRefreshHeader.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"cat_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickLeftBtn)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(clickRightBtn)];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    dic[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    [self.navigationController.navigationBar setTitleTextAttributes:dic];
    
    
    //设置下拉刷新
//    [self setHeadRefresh];
}

//-(void)setHeadRefresh
//{
//    //
//    MyRefreshHeader *myHeader = [MyRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNewData)];
//    
//    // 进入刷新状态
//    [myHeader beginRefreshing];
//    
//}
//
////下拉加载数据
//-(void)reloadNewData
//{
//    //模拟3秒后刷新表格UI
//}

-(void)clickLeftBtn//抽屉点击
{
    //添加遮盖,拦截用户操作
//    [self.view addSubview:self.vcCoverBtn];
    [self.navigationController.view addSubview:self.vcCoverBtn];
    
    //X最终偏移距离
    CGFloat maxX = SCREENWIDTH * ( 1 - ScaleToRight);
    [UIView animateWithDuration:0.2 animations:^{
        CGAffineTransform transform2 = CGAffineTransformMakeScale((1-ScaleToRight), (1-ScaleToRight));
        self.navigationController.view.transform = CGAffineTransformTranslate(transform2, maxX, 0);
        
    } completion:^(BOOL finished) {
        
        self.isScale = YES;
    }];
}

-(void)clickRightBtn//搜索
{
    SearchViewController *vc = [[SearchViewController alloc] init];
//    [vc setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
//    [self presentViewController:vc animated:YES completion:nil];
//    //禁止手势冲突
//    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
//    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)vcCoverBtnClick
{
    [UIView animateWithDuration:0.2 animations:^{
        
        self.navigationController.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        self.isScale = NO;
        [self.vcCoverBtn removeFromSuperview];
    }];
}

#pragma mark - setter and getter
-(UIButton *)vcCoverBtn
{
    if (_vcCoverBtn == nil) {
        
        _vcCoverBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _vcCoverBtn.frame = self.navigationController.view.bounds;
        [_vcCoverBtn addTarget:self action:@selector(vcCoverBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vcCoverBtn;
}


@end
