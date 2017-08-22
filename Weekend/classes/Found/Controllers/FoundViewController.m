//
//  FoundViewController.m
//  Weekend
//
//  Created by Jane on 16/3/28.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "FoundViewController.h"
#import "TagsCell.h"
#import "TopCell.h"
#import "DetailViewController.h"
#import "HomeViewController.h"


#define URL @"http://appsrv.flyxer.com/api/digest/discovery?s2=R7p6Bm&amp;s1=d8eeccd4993ef0a9fb1fc275fdcb7a95&amp;did=59419"

@interface FoundViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UICollectionView *collection;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic,strong) JGProgressHUD *hud;

/** 组头内容 */
@property (nonatomic, strong) NSArray *sectionHeadTitleArr;

/** 广告页 ->scrollView */
//@property (nonatomic, strong) UIScrollView *scroll;

/** collection 的 head // 类似于TableView的TableHeaderView */
//@property (nonatomic, strong) UIView *viewHead;
@property (nonatomic, strong) UIImageView *topImgView;
/**
 *保存图片的数组
 */
@property(nonatomic,strong)NSArray* imageArray;
/**
 *图片的当前下标索引
 */
@property(nonatomic,assign)NSInteger currentIndex;
/**
 *图片总数
 */
@property(nonatomic,assign)NSInteger imageCount;

/** 计时器 */
@property (nonatomic,strong) NSTimer *myTimer;
/**
 *页码指示视图的控件
 */
@property(nonatomic,strong)UIPageControl* pageControl;

@end

@implementation FoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor redColor];
    
    
    
    [self setUI];
    // *** HUD ***
    self.hud = [JGProgressHUD showMessage:@"正在加载" inViewController:self];
    [self observeNetStatus];
    
}

- (void)observeNetStatus
{
    
    [[AFNetworkReachabilityManager sharedManager]startMonitoring];
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (status == AFNetworkReachabilityStatusNotReachable) {
            self.hud = [JGProgressHUD showMessage:@"无网络连接" inViewController:self];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.hud hides];
            });
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
    
    [manager GET:URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        
        [self.dataArr addObject:responseObject[@"articles"]];
        [self.dataArr addObject:responseObject[@"tags"]];// 兴趣
        [self.dataArr addObject:responseObject[@"top_selections"]];
        
        [self.hud hides];
        [_collection reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"*****获取网络数据失败,error==%@",error);
    }];
}

-(void)setUI
{
    self.title = @"发现";
    //    collection
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    _collection.backgroundColor = [UIColor whiteColor];
    _collection.delegate = self;
    _collection.dataSource = self;
    _collection.userInteractionEnabled = YES;
    [self.view addSubview:_collection];
    //cell的复用
    [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];//默认
    // 代码+xib方法，一定要用下面的方法！否则cell无法加载
    [_collection registerNib:[UINib nibWithNibName:@"TagsCell" bundle:nil] forCellWithReuseIdentifier:@"tagsCell"];
    [_collection registerNib:[UINib nibWithNibName:@"TopCell" bundle:nil] forCellWithReuseIdentifier:@"topCell"];
    
    //collection 的 head // 类似于TableView的TableHeaderView
    _collection.contentInset = UIEdgeInsetsMake(200+64, 0, 0, 0);//重要，整个collection的inset
    
    [self loadImage];
    self.currentIndex=0;
    [self addGesture];
    [_collection addSubview:self.topImgView];
    [self createPageControl];
    [self createTimer];
    
    
    
    
    //section headView复用
    //    UICollectionElementKindSectionHeader   :用了判断是headView还是footView
    [_collection registerClass:[UICollectionReusableView class]
    forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
           withReuseIdentifier:@"head"];
    
    //section footView复用
    [_collection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"foot"];
    
}






/** 启动计时器 (线程) */
-(void)createTimer
{
    /**
     * 参数一：  时间间隔：多少秒
     *    二：  目标对象 self
     *    三：  SEL
     *    四：  nil
     *    五：  YES(重复)
     每两秒 调用一次self对象里面的 timeUpDate 方法
     */
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(timeUpDate) userInfo:nil repeats:YES];
}

-(void)timeUpDate
{
    // mmei向左
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    //设置从右向左滑
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self handleSwipe:leftSwipeGesture];
}


/**
 *以下是循环轮播图片UI界面的方法
 */
-(void)loadImage
{
//    self.imageArray = [NSMutableArray array];
//    NSArray *arr = self.dataArr[0];
//    for (NSDictionary *dic in arr) {
//        [self.imageArray addObject:dic[@"bg_pic"]];
//    }
//    NSLog(@"imageArray.count===%ld",self.imageArray.count);
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.imageArray=@[@"11.jpg",@"22.jpg",@"33.jpg",@"44.jpg"];
        self.imageCount=self.imageArray.count;
//    });
}
-(void)createPageControl
{
    [_collection addSubview:self.pageControl];
}

/**
 *  添加手势
 */
- (void)addGesture
{
    //每个轻扫手势对象只支持一个方向
    //向右
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    //设置从左向右滑
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.topImgView addGestureRecognizer:rightSwipeGesture];
    
    //向左
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    //设置从右向左滑
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.topImgView addGestureRecognizer:leftSwipeGesture];

    leftSwipeGesture.delegate = self;
    rightSwipeGesture.delegate = self;
}

/**
 *  轻扫切换图片
 *
 *  @param swipeGesture <#swipeGesture description#>
 */
- (void)handleSwipe:(UISwipeGestureRecognizer *)swipeGesture
{
    NSString *subType;
    
    //判断方向
    if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight)
    {
        //        NSLog(@"向右滑");
        //上张图片
        
        //        index--;
        self.currentIndex=((self.currentIndex-1+self.imageCount)%self.imageCount);
        
        subType = kCATransitionFromLeft;
    }
    else
    {
        //        NSLog(@"向左滑");
        //下张图片
        
        //        index++;
        self.currentIndex=((self.currentIndex+1)%self.imageCount);
        
        subType = kCATransitionFromRight;
    }
    
    
    
    //添加动画
    CATransition *transition = [CATransition animation];
    //动画类型
    transition.type = @"cube";//立体翻转    rippleEffect:水波// suckEffect
    //动画时间
    transition.duration = 1;
    //子类型
    transition.subtype = subType;
    //添加动画
    [self.topImgView.layer addAnimation:transition forKey:nil];
    
    
    //切换图片
    self.topImgView.image = [UIImage imageNamed:self.imageArray[self.currentIndex]];
//    [self.topImgView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[self.currentIndex]]];
    
    // 切换page  -- 延时动画的1s 为了跟图片同步
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.pageControl.currentPage = self.currentIndex;
//    });
    [UIView animateWithDuration:1 animations:^{
        self.pageControl.currentPage = self.currentIndex;
    }];
}

-(void)clickTopImageView
{
    NSLog(@"***********************");
}





#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArr.count-1; // -1 有一组是广告页
}
//每个section有几个cell
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //取到每个_dataArray的元素,并返回元素个数
    //    NSArray *array = [_dataArray objectAtIndex:section];
    //    return array.count;
    
    NSArray *arr1 = self.dataArr[1];
    NSArray *arr2 = self.dataArr[2];
    
    if (section == 0) {
        return arr1.count;
    }else
        return arr2.count;
}
//cell复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {  // 兴趣
        
        
        NSArray *arr0 = self.dataArr[1];
        NSDictionary *dic0 = arr0[indexPath.row];

        TagsCell *tagsCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"tagsCell" forIndexPath:indexPath];
        [tagsCell.imgView sd_setImageWithURL:dic0[@"icon"]];
        [tagsCell.textLabel setText:dic0[@"name"]];
//        [tagsCell.textLabel setTextColor:[UIColor yellowColor]];
//        tagsCell.backgroundColor = [UIColor yellowColor];
        return tagsCell;
        
    }else                         // 一周最热
    {
        NSArray *arr1 = self.dataArr[2];
        NSDictionary *dic1 = arr1[indexPath.row];
        NSDictionary *tempDic = dic1[@"selection"];
        
        TopCell *topCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"topCell" forIndexPath:indexPath];
        [topCell.leftImgView sd_setImageWithURL:tempDic[@"bg_pic"] placeholderImage:PLACEIMAGE];
        [topCell.hotnessLab setText:[NSString stringWithFormat:@"%@%%",dic1[@"hotness"]]];//hotnessLab服务器传过来的不是一个字符串
        [topCell.desLabel setText:[NSString stringWithFormat:@"%@ - %@",tempDic[@"title"],tempDic[@"sub_title"]]];
        return topCell;
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
//定义每个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    return CGSizeMake(SCREENWIDTH/2-15, (190.0/145.0)*(SCREENWIDTH/2-15));//
    if (indexPath.section == 0) // 兴趣
    {
        return CGSizeMake(SCREENWIDTH/3-15, SCREENWIDTH/3-15 + 25);
    }else                       // 一周最热
        return CGSizeMake(SCREENWIDTH-20, 100);
    
}
//定义每个UICollectionView 的 inset
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 10, 10, 10);//上、左、下、右（是相当于整个section的）
}

//section headView大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 40);
}


//定制section的 head  foot
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //判断是head ,还是foot
    if ([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        //这里是头部
        UICollectionReusableView *head =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"head" forIndexPath:indexPath];
        head.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREENHEIGHT-30, 38)];
        [titleLabel setText:self.sectionHeadTitleArr[indexPath.section]];
        [titleLabel setFont:[UIFont systemFontOfSize:16]];
        [head addSubview:titleLabel];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame), SCREENWIDTH-20, 1)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        [head addSubview:lineView];
        
        return head;
    }else
        return nil;
}



#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataArr[indexPath.section + 1];
    NSDictionary *dic = arr[indexPath.row];
    if (indexPath.section == 1)     // 一周最热
    {
        DetailViewController *vc = [[DetailViewController alloc] init];
        vc.secondID = [NSString stringWithFormat:@"%@",dic[@"selection"][@"id"]];
        [self.navigationController pushViewController:vc animated:YES];
    }else                   // 兴趣
    {
        
        HomeViewController *homeVC = [[HomeViewController alloc] init];
        homeVC.qkId = [NSString stringWithFormat:@"%@",dic[@"id"]];
        homeVC.titleStr = dic[@"name"];
        [self.navigationController pushViewController:homeVC animated:YES];
        
        
    }
    
}

#pragma mark - UIGestureRecognizerDelegate
// 代理方法----让其他的手势失效
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}



#pragma mark - setter and getter
-(NSMutableArray *)dataArr
{
    if (_dataArr == nil) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

-(NSArray *)sectionHeadTitleArr
{
    if (!_sectionHeadTitleArr)
    {
        _sectionHeadTitleArr = @[@"发现 · 兴趣",@"发现 · 一周最热"];
    }
    return _sectionHeadTitleArr;
}

//-(UIScrollView *)scroll
//{
//    if (!_scroll) {
//        
//        _scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
//        _scroll.pagingEnabled = YES;
//        _scroll.bounces = NO;
//    }
//    return _scroll;
//}
//
//-(UIView *)viewHead
//{
//    if (!_viewHead) {
//        
//        _viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, -200, SCREENWIDTH, 200)];
//        _viewHead.backgroundColor = [UIColor whiteColor];
//    }
//    return _viewHead;
//}

-(UIImageView *)topImgView
{
    if (!_topImgView) {
        _topImgView=[[UIImageView alloc]initWithFrame:CGRectMake(0, -200, SCREENWIDTH, 200)];
        _topImgView.image = [UIImage imageNamed:self.imageArray[0]];
//        [_topImgView sd_setImageWithURL:[NSURL URLWithString:self.imageArray[0]]];
        _topImgView.userInteractionEnabled = YES;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImageView)];
//        [_topImgView addGestureRecognizer:tap];
//        //每个轻扫手势对象只支持一个方向
//        //向右
//        UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//        //设置从左向右滑
//        rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//        [_topImgView addGestureRecognizer:rightSwipeGesture];
//        
//        //向左
//        UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//        //设置从右向左滑
//        leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//        [_topImgView addGestureRecognizer:leftSwipeGesture];
    }
    return _topImgView;
}
-(UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((SCREENWIDTH-60)*0.5, -30, 60, 20)];
        _pageControl.currentPageIndicatorTintColor=[UIColor orangeColor];
        _pageControl.pageIndicatorTintColor=[UIColor whiteColor];
        _pageControl.enabled=YES;
        _pageControl.numberOfPages=self.imageCount;
    }
    return _pageControl;
}

@end
