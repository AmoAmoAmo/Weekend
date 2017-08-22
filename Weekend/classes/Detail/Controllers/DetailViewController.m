//
//  DetailViewController.m
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "DetailViewController.h"
#import "TextCell.h"
#import "PicCell.h"
#import "CellModel.h"
#import "MapInfoView.h"
#import "HeadScroll.h"
#import "MJRefresh.h"
#import "MyRefreshHeader.h"
#import "MapViewController.h"
//地图框架
#import <MapKit/MapKit.h>
// 友盟分享
#import "UMSocial.h"


#define ScrollHeight 200
#define titleHeight 100
#define PoiHeight 50
#define MapHeight 80



#define URL @"http://api.lanrenzhoumo.com/wh/common/leo_detail?leo_id=%@&amp;session_id=000042c67110e63c14fb93c55167fa67347b0c&amp;v=3"

/** 轻刻top详情页 */
#define SecURL @"http://appsrv.flyxer.com/api/digest/recomm/%@?s2=3wtvQX&amp;amp;s1=e0681d061a68efbd59bdc5c3f106b296&amp;amp;v=3"

@interface DetailViewController ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,UMSocialUIDelegate,UIActionSheetDelegate>
{
    // mapView上的label 地址信息
    UILabel *_mapLabel;
}
@property (nonatomic, strong) UITableView       *table;
@property (nonatomic, strong) NSMutableArray    *dataDesArray;
@property (nonatomic, strong) NSDictionary    *dataBigDic;


/** head的scroll，装循环滚动的图片 */
@property (nonatomic, strong) HeadScroll *headScroll;
/** head的title，装标题的view */
@property (nonatomic, strong) UIView *titleView;
/** head的view，装地址信息的view */
@property (nonatomic, strong) MapInfoView *poiView;
/** foot 地图视图 */
@property (nonatomic,strong) MKMapView *mapView;
/** foot 的分享和收藏view */
@property (nonatomic,strong) UIView *shareView;
/** 定位管理类 */
//@property (nonatomic,strong) CLLocationManager *manager;

/** table的head */
@property (nonatomic, strong) UIView *headView;
/** table的foot */
@property (nonatomic, strong) UIView *footView;


@property (nonatomic, strong) UIActionSheet *sheet;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = self.titleStr;
    
    [self setUI];
    
    // 数据源
    if (self.leoID) {
        [self getSourceData];
    }else
        [self observeNetStatus];

}


-(void)setUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_share_black"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(cilckShare)];
    
    
    [self.view addSubview:self.table];
    self.table.tableHeaderView = self.headView;
    self.table.tableFooterView = self.footView;
    
    
    [self buildTopView];
    [self buildFootView];
}



-(void)buildTopView
{
    [self.headView addSubview:self.headScroll];
    [self.headView addSubview:self.titleView];
    [self.headView addSubview:self.poiView];
    

    /**  KVO */
    [self.table addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)buildFootView
{
    [self.footView addSubview:self.mapView];
    
    //设置地图的中心点
    CLLocationCoordinate2D loc2D = CLLocationCoordinate2DMake(22.557455, 113.939132);// lat,lon
    self.mapView.centerCoordinate = loc2D;
    //显示精度,范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion region = MKCoordinateRegionMake(loc2D, span);
    self.mapView.region = region;
    //添加自定义图片
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = loc2D;
    [self.mapView addAnnotation:point];
    
    // mapView上的label 地址信息
    _mapLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, MapHeight-40, SCREENWIDTH-100, 40)];
    _mapLabel.text = @"香港岛中环";
    _mapLabel.textColor = [UIColor whiteColor];
    _mapLabel.font = [UIFont systemFontOfSize:14];
    [self.mapView addSubview:_mapLabel];
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    //大头针复用
    static NSString *reusedID = @"ID";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reusedID];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusedID];
    }
    annotationView.canShowCallout = YES;
    annotationView.image= [UIImage imageNamed:@"icon_mapmarker_small"];
//    annotationView.animatesDrop = YES;
    //设置中⼼心点偏移，使得标注底部中间点成为经纬度对应点
    annotationView.centerOffset = CGPointMake(0, -10);
    return annotationView;
}


#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat y = self.table.contentOffset.y;
    CGFloat tempY = y ;
//    NSLog(@"%f",tempY);
    if (tempY < 0) {// 下滑 图片放大效果
        
        self.headScroll.frame = CGRectMake(0, tempY, SCREENWIDTH , 200+(-tempY));//宽度不变->为了里面的控件着想
        self.headScroll.bgImgView.frame = CGRectMake(tempY, 0, SCREENWIDTH + (-tempY)*2, 200+(-tempY));
//        self.headBGView.bgScroll.contentSize = CGSizeMake(SCREENWIDTH + (-tempY)*2, 200+(-tempY));
    }
}
-(void)dealloc
{
    [_table removeObserver:self forKeyPath:@"contentOffset"];
}

-(void)getSourceData  /** 周末 */
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WeekDetail1355235801" ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *Dic = dic[@"result"];
    self.dataBigDic = Dic;
    NSArray *arr = Dic[@"description"];
    
    for (NSDictionary *tempDic in arr) {
        CellModel *cellModel = [CellModel createCellModelWithDic:tempDic];
        [self.dataDesArray addObject:cellModel];
    }
    
//    NSLog(@"%ld",self.dataDesArray.count);
    
    
    
    
    
    // 设置数据
    [self.headScroll.bgImgView sd_setImageWithURL:[NSURL URLWithString:self.dataBigDic[@"images"][0]] placeholderImage:PLACEIMAGE];
    self.poiView.poiLabel.text = self.dataBigDic[@"poi"];
    CGFloat lat = [self.dataBigDic[@"location"][@"lat"] floatValue];
    CGFloat lon = [self.dataBigDic[@"location"][@"lon"] floatValue];
    //设置地图的中心点
    CLLocationCoordinate2D loc2D = CLLocationCoordinate2DMake(lat, lon);// lat,lon
    self.mapView.centerCoordinate = loc2D;
    _mapLabel.text = self.dataBigDic[@"address"];
    
    
    [self.table reloadData];//刷表
}



- (void)observeNetStatus
{
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            NSLog(@"无网络连接");
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
    
    // 判断是哪个界面传过来的URL字符串
    NSString *urlStr = nil;

    urlStr = [NSString stringWithFormat:SecURL,self.secondID];

    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.dataDesArray removeAllObjects];
        
        NSArray *arr = responseObject[@"details"];
        for (NSDictionary *dic in arr) {
            
            CellModel *cellModel = [[CellModel alloc] init];
            if (![dic[@"type"] isEqualToString:@"head"]) {
                
                if ([dic[@"type"] isEqualToString:@"text"]) {
                    
                    cellModel.content = dic[@"content"][@"text"];
                    cellModel.type = dic[@"type"];
                }
                else if ([dic[@"type"] isEqualToString:@"pic"]){
                    
                    cellModel.content = dic[@"content"][@"url"];
                    NSString *width = [NSString stringWithFormat:@"%@",dic[@"content"][@"width"]];
                    NSString *height = [NSString stringWithFormat:@"%@",dic[@"content"][@"height"]];
                    
                    NSArray *tempArr = @[width,height];
                    cellModel.size = tempArr;
                    cellModel.type = dic[@"type"];
                }
                [self.dataDesArray addObject:cellModel];
            }
            
        }
        
        
        [self.table reloadData];//刷表
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"获取网络数据失败,error==%@",error);
    }];
}

-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 分享按钮
-(void)cilckShare
{
    
//    [self.sheet showInView:self.view];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:nil
                                      shareText:@"今天天气不错"
                                     shareImage:[UIImage imageNamed:@"1-1.png"]
                                shareToSnsNames:@[UMShareToSina,UMShareToWechatSession,UMShareToQQ,UMShareToTencent,UMShareToWechatTimeline,UMShareToQzone,UMShareToRenren,UMShareToDouban,UMShareToEmail,UMShareToSms,UMShareToFacebook,UMShareToTwitter]
                                       delegate:self];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"%ld",buttonIndex) ;
}

#pragma mark - UMSocialUIDelegate
//弹出列表方法presentSnsIconSheetView需要设置delegate为self
-(BOOL)isDirectShareInIconActionSheet
{
    return YES;
}
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //分享完成的回调
    if (response.responseCode == 200)
    {
        NSLog(@"分享成功");
    }else
    {
        NSLog(@"分享失败,原因==%@",response.message);
    }
    
}

#pragma mark - 点击foot的mapView
-(void)clickMapView
{
    MapViewController *mapVC = [[MapViewController alloc] init];
    
    [self.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataDesArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellModel *model = self.dataDesArray[indexPath.row];
    return model.cellHeight;    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellModel *model = self.dataDesArray[indexPath.row];
    
    if ([model.type isEqualToString:@"text"])
    {
        return [TextCell cellWithTableView:tableView andCellModel:model];
    }else
    {
        return [PicCell cellWithTableView:tableView andCellModel:model];
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
        //预设cell高度
        _table.estimatedRowHeight = 44.0;
//        _table.rowHeight = 44.0;
        _table.backgroundColor = [UIColor clearColor];
        _table.userInteractionEnabled = YES;
        _table.delegate = self;
        _table.dataSource = self;
//        _table.contentInset = UIEdgeInsetsMake(TopHeight, 0, 0, 0);
    }
    return _table;
}

-(NSMutableArray *)dataDesArray
{
    if (_dataDesArray == nil)
    {
        _dataDesArray = [[NSMutableArray alloc] init];
    }
    return _dataDesArray;
}
-(NSDictionary *)dataBigDic
{
    if (!_dataBigDic) {
        _dataBigDic = [NSDictionary dictionary];
    }
    return _dataBigDic;
}




-(HeadScroll *)headScroll
{
    if (!_headScroll) {
        
        _headScroll = [[HeadScroll alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, ScrollHeight)];
    }
    return _headScroll;
}

-(UIView *)titleView
{
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, ScrollHeight, SCREENWIDTH, titleHeight)];
//        _titleView.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *lab = [[UILabel alloc] initWithFrame:_titleView.bounds];
        lab.text = self.titleStr;
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:16 weight:5];
        lab.textColor = [UIColor blackColor];
        lab.numberOfLines = 0;
        [_titleView addSubview:lab];
    }
    return _titleView;
}

-(MapInfoView *)poiView
{
    if (!_poiView) {
        
        _poiView = [[NSBundle mainBundle] loadNibNamed:@"MapInfoView" owner:self options:nil][0];
        _poiView.frame = CGRectMake(0, ScrollHeight + titleHeight, SCREENWIDTH, PoiHeight);
        
        UIView *lineV1 = [[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREENWIDTH-40, 0.6)];
        lineV1.backgroundColor = [UIColor lightGrayColor];
        
        UIView *lineV2 = [[UIView alloc] initWithFrame:CGRectMake(20, PoiHeight-1, SCREENWIDTH-40, 0.6)];
        lineV2.backgroundColor = [UIColor lightGrayColor];
        
        [_poiView addSubview:lineV1];
        [_poiView addSubview:lineV2];
    }
    return _poiView;
}


-(UIView *)headView
{
    if (!_headView) {
        
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, ScrollHeight + titleHeight + PoiHeight)];
        _headView.backgroundColor = [UIColor clearColor];
    }
    return _headView;
}

-(UIView *)footView
{
    if (!_footView) {
        
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, MapHeight + 20)];
        _footView.backgroundColor = [UIColor clearColor];
    }
    return _footView;
}
-(MKMapView *)mapView
{
    if (!_mapView) {
        
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, MapHeight)];
        //允许显示用户位置.会弹框获取用户许可
        _mapView.showsUserLocation = YES;
        //设置mapview的代理,用来进行大头针复用
        _mapView.delegate = self;
        
        // 地图上的黑色蒙版
        UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, MapHeight/2-10, SCREENWIDTH, MapHeight/2+10)];
        bgImgView.image = [UIImage imageNamed:@"EXP_firstView_coverImage_image_6"];
        bgImgView.alpha = 0.6;
        [_mapView addSubview:bgImgView];
        
        // 添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMapView)];
        [_mapView addGestureRecognizer:tap];
    }
    return _mapView;
}


-(UIActionSheet *)sheet
{
    if (!_sheet) {
        
        _sheet = [[UIActionSheet alloc] initWithTitle:@"分享到..." delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"微信",@"朋友圈",@"新浪", nil];
    }
    return _sheet;
}

@end
