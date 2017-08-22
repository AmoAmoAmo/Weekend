//
//  TopicViewController.m
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "TopicViewController.h"
#import "HomeCell.h"
#import "DetailViewController.h"
//#import "TopicModel.h"
#import "HomeModel.h"
#import "MJRefresh.h"
#import "MyRefreshHeader.h"

#define QKURL @"http://appsrv.flyxer.com/api/digest/collection/%@?s2=VJlbqF&amp;amp;s1=d4c0bf4a5fda796a7dd0bb0247d92c5f&amp;amp;v=3&amp;amp;page=1"  //  http://appsrv.flyxer.com/api/digest/collection/153?s2=VJlbqF&amp;amp;s1=d4c0bf4a5fda796a7dd0bb0247d92c5f&amp;amp;v=3&amp;amp;page=1

@interface TopicViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *table;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation TopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    //设置下拉刷新
    [self setHeadRefresh];
    
    
    
    
    if (!self.qkID) {  // 懒人周末
        [self getSourceData];
    }else
        [self observeNetStatus];
    
    [self.view addSubview:self.table];
    //    //cell注册方式
    [self.table registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}


#pragma mark - 设置下拉刷新
-(void)setHeadRefresh
{
    //
    MyRefreshHeader *myHeader = [MyRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadNewData)];
    
    // 进入刷新状态
    [myHeader beginRefreshing];
    
    self.table.header = myHeader;
}

//下拉加载数据
-(void)reloadNewData
{
    //模拟4.5秒后刷新表格UI
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.table.header endRefreshing];
    });
}





- (void)observeNetStatus
{
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
//            NSLog(@"无网络连接");
        }else
        {
            [self getDataFromNet];
        }
    }];
}

- (void)getDataFromNet
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    manager.requestSerializer.timeoutInterval = 30;
    NSString *urlStr;
    urlStr = [NSString stringWithFormat:QKURL,self.qkID];
    NSLog(@"urlStr === %@",urlStr);
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *arr = responseObject[@"recomms"];
        for (NSDictionary *dic in arr) {
            
            HomeModel *model = [[HomeModel alloc] init];
            model.imgUrlStr = dic[@"bg_pic"][0];
            model.idStr = [NSString stringWithFormat:@"%@",dic[@"id"]];
            model.titleStr = dic[@"title"];
            model.subTitleStr = dic[@"sub_title"];
            model.collectedNum = [NSString stringWithFormat:@"%@",dic[@"like_count"]];
            model.timeInfoStr = [NSString stringWithFormat:@"%@至%@",dic[@"start_date"],dic[@"end_date"]];
            model.farStr = dic[@"destination"];
            model.type = dic[@"type"]; // Recomm
            
            [self.dataArray addObject:model];
            
        }

        [self.table reloadData];//刷表
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        NSLog(@"获取网络数据失败,error==%@",error);
        [self getSourceData]; // 周末 数据

    }];
}


-(void)getSourceData  /** 周末 */
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WeekTopic361" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray *arr = dic[@"result"];
    
    for (NSDictionary *tempDic in arr) {
        
        HomeModel *model = [[HomeModel alloc] init];
        
        model.idStr = tempDic[@"leo_id"];
        model.imgUrlStr = tempDic[@"front_cover_image_list"][0];
        model.titleStr = tempDic[@"title"];
        model.subTitleStr = tempDic[@"poi"];
        NSInteger distance = [tempDic[@"distance"] integerValue];
        model.farStr = [NSString stringWithFormat:@"%ldkm",distance/1000];
        //        NSLog(@"%@",model.farStr);
        model.timeInfoStr = tempDic[@"time_info"];
        model.collectedNum = [NSString stringWithFormat:@"%@",tempDic[@"collected_num"]];
        model.type = @"leo";
        
        [self.dataArray addObject:model];
        
        
    }
    //    NSLog(@"%ld",self.dataArray.count);
    
    [self.table reloadData];//刷表

}


#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArray[indexPath.row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArray[indexPath.row];
  
    return [HomeCell cellWithTable:tableView andModel:model];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArray[indexPath.row];
    DetailViewController *vc = [[DetailViewController alloc] init];
    if ([model.type isEqualToString:@"leo"]) {
        vc.leoID = model.idStr;   // 1355235801
    }else{
        vc.secondID = model.idStr;
    }
    vc.titleStr = model.titleStr;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Methord
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}










#pragma mark - setter and getter
//懒加载
-(UITableView *)table
{
    if (_table == nil)
    {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];//style:UITableViewStylePlain(默认 设置分组有悬浮)
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;//把table的线去掉
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}

-(NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

@end
