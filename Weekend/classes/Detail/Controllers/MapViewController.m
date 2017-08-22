//
//  MapViewController.m
//  Weekend
//
//  Created by Jane on 16/4/19.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
//定位框架
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"
#import "MyPin.h"
#import "MapBottonView.h"
//#import ""

@interface MapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong) MKMapView *mapView;

@property (nonatomic,strong) JGProgressHUD *hud;


/** 地图顶部 显示地址信息的view */
@property (nonatomic,strong) UIView *topView;
/** 地图底部 点击大头针显示信息的view */
@property (nonatomic,strong) MapBottonView *bottonView;
/** 地图底部 bottonView 是否在视图上 */
@property (nonatomic,assign) BOOL isShow;

/** 是否是第一次定位，第一次定位将视图拉到用户位置，第二次以后就不需要了 */
@property (nonatomic,assign) BOOL notFirst;

@property (nonatomic,strong) CLLocationManager *manager;//定位管理类
/** 大头针的数据源 */
@property (nonatomic,strong) NSArray *dataArr;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUI];
    
    if (!self.lat || !self.lon)
    {
        self.lat = 30.281843;
        self.lon = 120.102193;
    }
    if (!self.locStr) {
        
        self.locStr = @"香港岛中环";
    }
    
    if (!self.allowToTransform) {// detail
        [self buildDetailMap];
        [self buildTopView];
    }else{                       // map
        [self buildUserMap];
    }
}

-(void)setUI
{
    self.title = @"地图";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"ic_nav_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    
    
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    
//    CLLocationCoordinate2D loca2D = CLLocationCoordinate2DMake(self.lat, self.lon);
//    self.mapView.centerCoordinate = loca2D;
//    
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
//    MKCoordinateRegion region = MKCoordinateRegionMake(loca2D, span);
//    self.mapView.region = region;
    
    
    // *** HUD ***
    self.hud = [JGProgressHUD showMessage:@"正在定位" inViewController:self];
    
//    //设置代理,获取定位结果
//    self.manager.delegate = self;
//    [self.manager startUpdatingLocation];
    
    
    
    
    
    
    
}

/** 显示用户位置的bigMap */
-(void)buildUserMap
{
    //允许显示用户位置.会弹框获取用户许可
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}
/** 显示detail的Map */
-(void)buildDetailMap
{
//    NSLog(@"self.lat, self.lon === %f, %f",self.lat, self.lon);
    [self.hud hides]; // *** HUD ***
    CLLocationCoordinate2D loca2D = CLLocationCoordinate2DMake(self.lat, self.lon);
    self.mapView.centerCoordinate = loca2D;
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(loca2D, span);
    self.mapView.region = region;
    
    
    if (!self.titleStr || !self.subTitleStr) {
        self.titleStr = @"test";
        self.subTitleStr = @"0-0";
    }
    MyPin *myPin = [[MyPin alloc] initWithCoordinate:loca2D AndTitle:self.titleStr AndSubTitle:self.subTitleStr AndImage:nil];
    [self.mapView addAnnotation:myPin];
}

-(void)buildPins
{
    for (int i = 0; i < self.dataArr.count; i++) {
        NSDictionary *dic = self.dataArr[i];
        CGFloat latX = [dic[@"lat"] floatValue];
        CGFloat lonY = [dic[@"lon"] floatValue];
        // 获取屏幕坐标
        CGPoint point = CGPointMake(latX, lonY);
        // 将屏幕坐标转经纬度
        CLLocationCoordinate2D cl2d = [self.mapView convertPoint:point toCoordinateFromView:self.view];
        NSString *title = dic[@"title"];
        NSString *subTitle = dic[@"subTitle"];
        NSString *imgStr = dic[@"imageUrlStr"];
        
        MyPin *myPin = [[MyPin alloc] initWithCoordinate:cl2d AndTitle:title AndSubTitle:subTitle AndImage:imgStr];
        [self.mapView addAnnotation:myPin];
    }
}

-(void)buildTopView
{
    [self.view addSubview:self.topView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, SCREENWIDTH-100, 40)];
    label.text = self.locStr;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14];
    [self.topView addSubview:label];
}

-(void)backClick
{
    if (self.allowToTransform) {
        //1.创建CATransition对象
        CATransition *transition = [CATransition animation];
        //2.设置动画类型
        transition.type = @"cube";
        //3.设置子类型
        transition.subtype = kCATransitionFromLeft;
        //4.设置动画时间
        transition.duration = 1.0;
        //5.动画添加到指定层上
        //CATransition必须加到层上
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - MKMapViewDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
//    NSLog(@"class == %@",[annotation class]);
    if ([annotation isKindOfClass:NSClassFromString(@"MKUserLocation")]) {
        return nil;
    }else{
        
        //大头针复用
        MyAnnotation *myAnnotation = [MyAnnotation createAnnotationViewWithMapView:mapView andAnnotation:annotation];// annotation-->MyPin
        
        
        return myAnnotation;
    }
}
#pragma mark -MKMapViewDelegate
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    NSLog(@"map********%@",userLocation.location);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.hud hides]; // *** HUD ***
    if (!_notFirst) {
        CLLocationCoordinate2D loc = [userLocation coordinate];
        //放大地图到自身的经纬度位置。
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 400, 400);
        [self.mapView setRegion:region animated:YES];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self buildPins];
        });
        
    }
    _notFirst = YES;

}



-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
    // 点击大头针
    MyPin *myPin = (MyPin*)view.annotation;
//    NSLog(@"%f   ---- %@",myPin.coordinate.latitude, myPin.title);
    [self.mapView setCenterCoordinate:myPin.coordinate animated:YES];
    
    self.bottonView.titleLabel.text = myPin.title;
    self.bottonView.subTitleLabel.text = myPin.subtitle;
    [self.bottonView.imgView sd_setImageWithURL:[NSURL URLWithString:myPin.imgStr]];
    if (!self.isShow) {
        // 不在视图上
        [self.view addSubview:self.bottonView];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.bottonView.frame = CGRectMake(0, SCREENHEIGHT-110, SCREENWIDTH, 110);
        } completion:^(BOOL finished) {
            
            self.isShow = YES;
        }];
    }else{
        // 在视图上
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
//    NSLog(@"touch.view == %@",touch.view.class);
    NSString *tempStr = [NSString stringWithFormat:@"%@",touch.view.class];
    if (self.isShow && ![tempStr isEqualToString:@"MyAnnotation"]) {
        // 在视图上  -》 移除
        [UIView animateWithDuration:0.5 animations:^{
            
            self.bottonView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 110);
        } completion:^(BOOL finished) {
            [self.bottonView removeFromSuperview];
            self.isShow = NO;
        }];
    }
}


#pragma mark -CLLocationManagerDelegate     manager的代理

//定位成功
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"定位成功");
    
    //locations数组只有一个成员
    CLLocation *location = [locations firstObject];
    
    //包含经纬度,海拔,时间等信息
    NSLog(@"location==%@",location);
    
    //获取定位成功后的经纬度
    CLLocationCoordinate2D cl2d = location.coordinate;
    
    //将视角(地图的中心点)拉倒定位成功的地方
    self.mapView.centerCoordinate = cl2d;
    
    //定位成功后,结束定位
    [manager stopUpdatingLocation];
    
    [self buildPins];
}

//定位失败
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"定位失败,error==%@",error);
}








#pragma mark - setter and getter
-(UIView *)topView
{
    if (!_topView) {
        
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, 80)];
        _topView.backgroundColor = [UIColor blackColor];
        _topView.alpha = 0.6;
    }
    return _topView;
}
-(MapBottonView *)bottonView
{
    if (!_bottonView) {
        _bottonView = [[NSBundle mainBundle] loadNibNamed:@"MapBottonView" owner:self options:nil][0];
        _bottonView.frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 100);
    }
    return _bottonView;
}
-(NSArray *)dataArr
{
    if (!_dataArr) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MapBottonViewData" ofType:@"plist"];
        _dataArr = [NSArray arrayWithContentsOfFile:path];
    }
    return _dataArr;
}

//-(CLLocationManager *)manager
//{
//    if (!_manager) {
//        //实例化定位管理类
//        _manager = [[CLLocationManager alloc]init];
//        //设置代理,获取定位结果
////        _manager.delegate = self;
//        //ios8以后,修改了定位策略.
//        //永久支持定位
//        [_manager requestAlwaysAuthorization];  //   定位授权认证
//        
//        //开始定位
//        [_manager startUpdatingLocation];
//    }
//    return _manager;
//}

@end
