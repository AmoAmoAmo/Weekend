//
//  MainViewController.m
//  Weekend
//
//  Created by Jane on 16/3/28.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "MainViewController.h"
#import "BaseViewController.h"
#import "LeftMenuView.h"
#import "HomeViewController.h"
#import "FoundViewController.h"
#import "CollectionViewController.h"
#import "SettingViewController.h"
#import "CityViewController.h"
#import "MainBGView.h"

@interface MainViewController ()<LeftMenuViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, weak) BaseViewController *currentVC;

@property (nonatomic, strong) MainBGView *bgImgView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self buildADImageView];
//    [self addNotification];
//    self.view.backgroundColor = [UIColor yellowColor];
    
    //添加子控制器
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav.view.layer.shadowColor = [UIColor blackColor].CGColor;
    [self addChildViewController:nav];
    FoundViewController *foundVC = [[FoundViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:foundVC];
    [self addChildViewController:nav2];
    CollectionViewController *collectionVC = [[CollectionViewController alloc] init];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:collectionVC];
    [self addChildViewController:nav3];
    SettingViewController *settingVC = [[SettingViewController alloc] init];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:settingVC];
    [self addChildViewController:nav4];
    CityViewController *cityVC = [[CityViewController alloc] init];
    UINavigationController *nav5= [[UINavigationController alloc] initWithRootViewController:cityVC];
    [self addChildViewController:nav5];
    
    [self setMenuUI];
}

-(void)setMenuUI
{
    [self.view addSubview:self.bgImgView];
    
    LeftMenuView *view = [[NSBundle mainBundle] loadNibNamed:@"LeftMenuView" owner:self options:0][0];
    [self.view addSubview:view];//[self.view insertSubview:view atIndex:1];
    view.delegate = self;
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}

-(void)buildADImageView
{
    UIImageView *adImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    adImgView.image = [UIImage imageNamed:@"1"];
    [self.view addSubview:adImgView];
    
    [UIImageView animateWithDuration:2 animations:^{
        
        adImgView.transform = CGAffineTransformMakeScale(1.2, 1.2);
        adImgView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        [adImgView removeFromSuperview];
        
    }];
    adImgView = nil;
}


#pragma mark - 手势
-(void)pan:(UIPanGestureRecognizer *)pan
{
    CGFloat moveX = [pan translationInView:self.view].x;
    //X最终偏移距离
    CGFloat maxX = SCREENWIDTH * ( 1 - ScaleToRight);
    
    if (self.currentVC.isScale == NO) //没有缩放时，允许缩放//**** 左滑 ****
    {
        if (moveX <= maxX + 5 && moveX >= 0)
        {
            //获取随X偏移变大 XY缩放的比例(倍数)变小 -》右图大小占Main图的比例
            CGFloat scaleXY = 1 - ( ScaleToRight/maxX) * moveX;//画图理解 函数:y=1-0.2*x
            CGAffineTransform transform = CGAffineTransformMakeScale(scaleXY, scaleXY);// Scale 缩放
            //先缩放在位移会使位移缩水,正常需要moveX/scaleXY 才是正常的比例
            self.currentVC.navigationController.view.transform = CGAffineTransformTranslate(transform, moveX/scaleXY, 0);
        }
        
        if (pan.state == UIGestureRecognizerStateEnded)//当手势停止的时候,判断X轴的移动距离，停靠
        {
            if (moveX >= maxX/2)//超过一半 缩放
            {
                [UIView animateWithDuration:0.2 animations:^{
                    CGAffineTransform transform2 = CGAffineTransformMakeScale((1-ScaleToRight), (1-ScaleToRight));
                    self.currentVC.navigationController.view.transform = CGAffineTransformTranslate(transform2, maxX, 0);
//                    self.currentVC.navigationController.view.transform = CGAffineTransformTranslate(transform2, maxX/(1-ScaleToRight), 0);
                    
                } completion:^(BOOL finished) {
                    
                    self.currentVC.isScale = YES;
                    [self.currentVC clickLeftBtn];
                    
                }];
                
            }else// 移动没有超过一半 不缩放
            {
                [UIView animateWithDuration:0.2 animations:^{
                    
                    self.currentVC.navigationController.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    self.currentVC.isScale = NO;
                    
                }];
            }
        }
        
    }
    else if (self.currentVC.isScale == YES) // 已经缩放，允许右滑
    {
        if (moveX <= 5)
        {
            //获取随X偏移变小 XY缩放的比例(倍数)变大 -》右图大小占Main图的比例
            CGFloat scaleXY = (1-ScaleToRight) - ( ScaleToRight/maxX) * moveX;//画图理解 函数:y=(1-0.2)-0.02*x
            CGAffineTransform transform = CGAffineTransformMakeScale(scaleXY, scaleXY);// Scale 缩放
            self.currentVC.navigationController.view.transform = CGAffineTransformTranslate(transform, maxX + moveX, 0);
        }
        
        if (pan.state == UIGestureRecognizerStateEnded)//当手势停止的时候,判断X轴的移动距离，停靠
        {
            if (-moveX >= maxX/2)//超过一半 放大
            {
                [UIView animateWithDuration:0.2 animations:^{
                    
                    self.currentVC.navigationController.view.transform = CGAffineTransformIdentity;
                    
                } completion:^(BOOL finished) {
                    
                    self.currentVC.isScale = NO;
                    //手动点击遮盖按钮
                    [self.currentVC vcCoverBtnClick];
                    
                }];
                
            }else// 移动没有超过一半 回到原位 不放大
            {
                [UIView animateWithDuration:0.2 animations:^{
                    CGAffineTransform transform2 = CGAffineTransformMakeScale((1-ScaleToRight), (1-ScaleToRight));
                    self.currentVC.navigationController.view.transform = CGAffineTransformTranslate(transform2, maxX, 0);;
                    
                } completion:^(BOOL finished) {
                    self.currentVC.isScale = YES;
                    
                }];
            }
        }
    }
    
}

#pragma mark - LeftMenuViewDelegate
-(void)LeftMenuViewBtnClickFromBtnTag:(NSInteger)fromTag ToBtnTag:(NSInteger)toTag
{
    UINavigationController *oldNav = self.childViewControllers[fromTag];
    [oldNav.view removeFromSuperview];
    
    UINavigationController *newNav = self.childViewControllers[toTag];
    [self.view addSubview:newNav.view];
    //******
    newNav.view.transform = oldNav.view.transform;
    
    // 临时属性，记录当前VC
    self.currentVC = newNav.childViewControllers[0];
    
    //自动点击遮盖btn --> 左视图按钮点击后 自动执行和点击遮盖按钮一样的效果 即右视图左滑
    [self.currentVC vcCoverBtnClick];
}

//-(void)addNotification
//{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectIndexToHome) name:@"setSelectIndexToHome" object:nil];
//}
//-(void)setSelectIndexToHome
//{
//    // 延时
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self LeftMenuViewBtnClickFromBtnTag:CityBtnTag ToBtnTag:HomeBtnTag];
//    });
//    
//}
//-(void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}


#pragma mark - UIGestureRecognizerDelegate
// 是否开始触发手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // 如果当前控制器的Nav的栈顶为根视图控制器
    if (self.currentVC.navigationController.topViewController == [self.currentVC.navigationController.childViewControllers firstObject]) {//self.currentVC.navigationController.topViewController == self.currentVC也可以
        return YES;
    }else
        return NO;
}

#pragma mark - 懒加载
-(MainBGView *)bgImgView
{
    if (!_bgImgView) {
        
        _bgImgView = [[MainBGView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _bgImgView;
}


@end
