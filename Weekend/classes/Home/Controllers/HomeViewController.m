//
//  HomeViewController.m
//  Weekend
//
//  Created by Jane on 16/3/28.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "DetailViewController.h"
#import "FMDBmanager.h"
#import "HomeCell.h"
#import "HomeModel.h"
#import "HomeViewController.h"
#import "MJRefresh.h"
#import "MapViewController.h"
#import "MyRefreshHeader.h"
#import "TopicCell.h"
#import "TopicViewController.h"

#define URL @"http://api.lanrenzhoumo.com/main/recommend/index/?city_id=0&amp;lat=22.58708&amp;lon=113.9648&amp;page=1&amp;session_id=000042c67110e63c14fb93c55167fa67347b0c&amp;v=3"
#define QKURL @"http://appsrv.flyxer.com/api/digest/recomm/tag/%@?did=59419&amp;amp;s2=gB8HsJ&amp;amp;s1=4d23709b1b52d3d69028755ff8c557d4&amp;amp;v=3&amp;amp;page=1"// http://appsrv.flyxer.com/api/digest/recomm/tag/5?did=59419&amp;amp;s2=gB8HsJ&amp;amp;s1=4d23709b1b52d3d69028755ff8c557d4&amp;amp;v=3&amp;amp;page=1

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

/*!
 * @brief test test test *****。
 */
@property (nonatomic, strong) FMDBmanager *manager;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UITableView *table;

//@property (nonatomic, strong) UIButton *rightBtn;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addNotification];
    
    if (!self.qkId) {
        // 获取数据源
        self.title = @"首页";
        [self getSourceDataWithIdStr:nil];
    }else{
        [self observeNetStatus];
        self.title = self.titleStr;
    }
    [self setUI];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.table reloadData];
}


-(void)setUI
{
    // 如果当前控制器的Nav的栈顶不是根视图控制器
    if (self.navigationController.topViewController != [self.navigationController.childViewControllers firstObject]) {//self.navigationController.topViewController != self也可以
        // 设置左按钮为返回按钮
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
        self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    }else
    {
//        self.title = @"首页";
    }
    
    [self.view addSubview:self.table];
//    //cell注册方式
    [self.table registerNib:[UINib nibWithNibName:@"TopicCell" bundle:nil] forCellReuseIdentifier:@"cell1"];
    
    
    //设置下拉刷新
    [self setHeadRefresh];
    
    
    
    
    if (!self.qkId) {
        // map
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(clickMapBtn)];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
        [self.navigationItem.rightBarButtonItem setTitleTextAttributes:dic forState:UIControlStateNormal];
    }
}


#pragma mark - Notification
-(void)addNotification
{
    /** NSNotificationCenter */
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LikeTableNeedToReload) name:@"LikeTableNeedToReload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectACityToReloadData:) name:@"didSelectACityToReloadData" object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)LikeTableNeedToReload
{
    [self.table reloadData];
}
-(void)didSelectACityToReloadData:(NSNotification *)noti
{
    self.table.frame = CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64);
    [self setHeadRefresh];
//    NSLog(@"city_id === %@",noti.userInfo[@"city_id"]);
    NSString *idStr = noti.userInfo[@"city_id"];
    [self getSourceDataWithIdStr:idStr];
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
            [self getSourceDataWithIdStr:nil];
        }else
        {
            [self getDataFromNet];
        }
        
    }];
}

- (void)getDataFromNet
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *urlStr = nil;
    if (!self.qkId)
    {
        urlStr = URL;
    }else
    {
        urlStr = [NSString stringWithFormat:QKURL,self.qkId];
    }
//    NSLog(@"urlStr ==== %@",urlStr);
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.dataArray removeAllObjects];
        
        if (!self.qkId) // 懒人周末
        {
            NSArray *dataArr = responseObject[@"result"];
            for (NSDictionary *dic in dataArr) {
                [self.dataArray addObject:dic];
            }
            
        }else
        {
            NSArray *arr = responseObject;
            for (NSDictionary *tempDic in arr) {
                
                HomeModel *model = [[HomeModel alloc] init];
                model.type = tempDic[@"type"];  // Recomm
                if (tempDic[@"collections"])            //TopicCell data
                {
                    NSArray *arr = tempDic[@"collections"];
                    NSDictionary *Dic = arr[0];
                    model.imgUrlStr = Dic[@"bg_pic"][0];
                    model.titleStr = Dic[@"title"];
                    model.idStr = [NSString stringWithFormat:@"%@",Dic[@"id"]];
                    
                }else                                   //HomeCell data   需要收藏的
                {
                    model.idStr = [NSString stringWithFormat:@"%@",tempDic[@"id"]];
                    
                    model.titleStr = tempDic[@"title"];
                    model.imgUrlStr = tempDic[@"bg_pic"][0];
                    model.subTitleStr = tempDic[@"sub_title"];
                    model.collectedNum = [NSString stringWithFormat:@"%@",tempDic[@"like_count"]];
                    model.timeInfoStr = [NSString stringWithFormat:@"%@至%@",tempDic[@"start_date"],tempDic[@"end_date"]];
                    model.farStr = tempDic[@"destination"];
                }
                [self.dataArray addObject:model];
            }
        }
        
        [self.table reloadData];//刷表
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"获取网络数据失败,error==%@",error);
        //获取网络数据失败 则从数据源文件加载数据
        [self getSourceDataWithIdStr:nil];
        
    }];
}

-(void)getSourceDataWithIdStr:(NSString *)idStr//reloadSourceData
{
    [self.dataArray removeAllObjects];
    NSString *path = nil;
    if (!idStr) { // idStr = nil
        path = [[NSBundle mainBundle] pathForResource:@"Home" ofType:nil];
    }else{
        NSString *resourceStr = [NSString stringWithFormat:@"Home%@",idStr];
        path = [[NSBundle mainBundle] pathForResource:resourceStr ofType:nil];
//        NSLog(@"path == %@",path);
        if (!path) {
            path = [[NSBundle mainBundle] pathForResource:@"Home" ofType:nil];
        }
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray *arr = dic[@"result"];
    
    for (NSDictionary *tempDic in arr) {
        
        HomeModel *model = [[HomeModel alloc] init];
        model.type = tempDic[@"item_type"];
        if ([tempDic[@"item_type"] isEqualToString:@"event"]) {
            model.idStr = tempDic[@"jump_data"];
        }else{
            model.idStr = tempDic[@"leo_id"];
        }
        model.imgUrlStr = tempDic[@"front_cover_image_list"][0];
        model.titleStr = tempDic[@"title"];
        model.subTitleStr = tempDic[@"poi"];
        NSInteger distance = [tempDic[@"distance"] integerValue];
        model.farStr = [NSString stringWithFormat:@"%ldkm",distance/1000];
//        NSLog(@"%@",model.farStr);
        model.timeInfoStr = tempDic[@"time_info"];
        model.collectedNum = [NSString stringWithFormat:@"%@",tempDic[@"collected_num"]];
        
        [self.dataArray addObject:model];
    }
    [self.table reloadData];//刷表
}



#pragma mark - Methord
-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)clickMapBtn
{
    MapViewController *vc= [[MapViewController alloc] init];
    vc.allowToTransform = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
    /**
     转场动画类
     */
    //1.创建CATransition对象
    CATransition *transition = [CATransition animation];
    //2.设置动画类型
    transition.type = @"cube";
    //3.设置子类型
    transition.subtype = kCATransitionFromRight;
    //4.设置动画时间
    transition.duration = 1.0;
    //5.动画添加到指定层上
    //CATransition必须加到层上
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//返回每个cell的高度，这里高度是固定的，可以直接写死, 如果高度是不固定的需要先调用estimatedHeightForRowAtIndexPath:方法给个预计高度
//等网络请求完毕后根据cell内容算出高度 再调用heightForRowAtIndexPath：设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArray[indexPath.row];
    if ([model.type isEqualToString:@"event"] || [model.type isEqualToString:@"Collection"])
    {
        return 230;  // topic 高度是固定的
    }else
        return model.cellHeight;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArray[indexPath.row];
    
    if ([model.type isEqualToString:@"event"] || [model.type isEqualToString:@"Collection"]) {//TopicCell
        
        TopicCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;//去掉cell选中效果
        [cell1.imgView sd_setImageWithURL:[NSURL URLWithString:model.imgUrlStr] placeholderImage:PLACEIMAGE];
        [cell1.titleLabel setText:model.titleStr];
        
        return cell1;
    }else{ //HomeCell
        HomeCell *cell = [HomeCell cellWithTable:tableView andModel:model];
//        if (model.isCollectioned) {
////            cell.likeBtn.selected = YES;
//        }
//        cell.delegate = self;
        return cell;
    }
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicViewController *vc = [[TopicViewController alloc] init];
    DetailViewController *detailVC = [[DetailViewController alloc] init];

    HomeModel *model = self.dataArray[indexPath.row];
    
    if ([model.type isEqualToString:@"event"] || [model.type isEqualToString:@"Collection"])//TopicCell
    {
        if (!self.qkId)
        {
            vc.idStr = model.idStr;
        }else
        {
            vc.qkID = model.idStr;
        }
        
        vc.navigationItem.title = model.titleStr;
        [self.navigationController pushViewController:vc animated:YES];
    }else
    {
        if (!self.qkId) // 懒人周末
        {
            detailVC.leoID = model.idStr;
        }else
        {
            detailVC.secondID = model.idStr;
        }

        detailVC.titleStr = model.titleStr;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
}







#pragma mark - setter and getter
//懒加载
-(UITableView *)table
{
    if (_table == nil)
    {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, SCREENHEIGHT-64) style:UITableViewStylePlain];//style:UITableViewStylePlain(默认 设置分组有悬浮)
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

-(FMDBmanager *)manager
{
    if (!_manager) {
        
        _manager = [FMDBmanager shareInstance];
    }
    return _manager;
}

@end
