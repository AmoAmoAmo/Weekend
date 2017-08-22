//
//  CollectionViewController.m
//  Weekend
//
//  Created by Jane on 16/3/30.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "CollectionViewController.h"
#import "HomeModel.h"
#import "HomeCell.h"
#import "UMSocial.h"

@interface CollectionViewController ()<UMSocialUIDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *table;

@property (nonatomic,strong) NSMutableArray *dataArr;

@property (nonatomic,strong) UIView *emptyView;

@end

@implementation CollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收藏";
    
    [self addNotification];
    [self buildUI];
    [self loadDataFromDB];
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.table reloadData];
}


-(void)loadDataFromDB
{
    [self.dataArr removeAllObjects];
    
    FMDBmanager *manager = [FMDBmanager shareInstance];
    NSString *sqlStr = [NSString stringWithFormat:@"select * from Like"];
    FMResultSet *rs = [manager.dataBase executeQuery:sqlStr];
    while ([rs next]) {
        HomeModel *model = [[HomeModel alloc] init];
        model.idStr = [rs stringForColumn:@"idStr"];
        model.imgUrlStr = [rs stringForColumn:@"imgUrlStr"];
        model.type = [rs stringForColumn:@"type"];
        model.titleStr = [rs stringForColumn:@"titleStr"];
        model.subTitleStr = [rs stringForColumn:@"subTitleStr"];
        model.farStr = [rs stringForColumn:@"farStr"];
        model.timeInfoStr = [rs stringForColumn:@"timeInfoStr"];
        model.collectedNum = [rs stringForColumn:@"collectedNum"];
        [self.dataArr addObject:model];
        
    }
    /**
     idStr ,type ,imgUrlStr ,titleStr ,subTitleStr ,farStr ,timeInfoStr ,collectedNum
     
     
     @property (nonatomic, copy) NSString *idStr;
     @property (nonatomic, copy) NSString *type;
     
     @property (nonatomic, copy) NSString *imgUrlStr;
     @property (nonatomic, copy) NSString *titleStr;
     @property (nonatomic, copy) NSString *subTitleStr;
     @property (nonatomic, copy) NSString *farStr;
     @property (nonatomic, copy) NSString *timeInfoStr;
     @property (nonatomic, copy) NSString *collectedNum; +1
     */
    [self.table reloadData];
    
    if (!self.dataArr.count) {
        // 为空，创建相应的界面
        //        NSLog(@"*****  %ld",self.dataArr.count);
        [self showEmptyUI];
    }else
    {
        //
        [self.emptyView removeFromSuperview];
        [self buildUI];
    }
    
}

-(void)buildUI
{
    [self.view addSubview:self.table];
}

-(void)showEmptyUI
{
    [self.view addSubview:self.emptyView];
}





#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

//返回每个cell的高度，这里高度是固定的，可以直接写死, 如果高度是不固定的需要先调用estimatedHeightForRowAtIndexPath:方法给个预计高度
//等网络请求完毕后根据cell内容算出高度 再调用heightForRowAtIndexPath：设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArr[indexPath.row];
    return model.cellHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HomeModel *model = self.dataArr[indexPath.row];
    
    return [HomeCell cellWithTable:tableView andModel:model];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    HomeModel *model = self.dataArr[indexPath.row];
//    DetailViewController *vc = [[DetailViewController alloc] init];
//    if ([model.type isEqualToString:@"week"]) {
//        vc.leoID = model.idStr;   // 1355235801
//    }else{
//        vc.secondID = model.idStr;
//    }
//    
//    [self.navigationController pushViewController:vc animated:YES];
}







#pragma mark - Notification
-(void)addNotification
{
    /** NSNotificationCenter */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyNumisChangedWithNotic:) name:@"buyNum_isChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataFromDB) name:@"LikeTableNeedToReload" object:nil];
    
    // 数据库更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataFromDB) name:@"LikeTableDidChanged" object:nil];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)buyNumisChangedWithNotic:(NSNotification*)noti
{
    [self.table reloadData];
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
-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
        
    }
    return _dataArr;
}

-(UIView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT)];
        _emptyView.backgroundColor = AUTOCOLOR;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH-200)*0.5, (SCREENHEIGHT-100)*0.5-50, 200, 100)];
        label.text = @"暂时没有喜欢的收藏噢~";
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:17];
        label.textAlignment = NSTextAlignmentCenter;
        
        [_emptyView addSubview:label];
    }
    return _emptyView;
}
@end
