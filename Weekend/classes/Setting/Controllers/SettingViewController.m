//
//  SettingViewController.m
//  Weekend
//
//  Created by Jane on 16/3/30.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "SettingViewController.h"
#import "InfoView.h"

@interface SettingViewController ()

@property (nonatomic, strong) UIScrollView *bgScroll;

@property (nonatomic, strong) UIImageView *bgImgView;

///** 缓存弹出提示框 */
//@property (nonatomic,strong) UIAlertView *alertView;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setUI];
}

-(void)setUI
{
    [self.view addSubview:self.bgImgView];
    
    self.title = @"设置";
    self.navigationItem.rightBarButtonItem = nil;
    [self.view addSubview:self.bgScroll];
    
    InfoView *view = [InfoView createInfoView];
    [self.bgScroll addSubview:view];
    
    [self.bgScroll addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat y = self.bgScroll.contentOffset.y;
    CGFloat yy = y + 20;
    
    if (yy < 0) {
        
        self.bgImgView.frame = CGRectMake(yy, 64, SCREENWIDTH + (-yy)*2, 240 + (-yy));
    }
    if (y > 0) {
        
        self.bgImgView.frame = CGRectMake(0, 64 - (y)/2, SCREENWIDTH, 240);
    }
}
-(void)dealloc
{
    [_bgScroll removeObserver:self forKeyPath:@"contentOffset"];
}



-(UIImageView *)bgImgView
{
    if (!_bgImgView) {
        
        _bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREENWIDTH, 240)];
        [_bgImgView setImage:[UIImage imageNamed:@"setting_head_bg"]];
        
    }
    return _bgImgView;
}

-(UIScrollView *)bgScroll
{
    if (_bgScroll == nil) {
        
        _bgScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bgScroll.contentSize = CGSizeMake(0, SCREENHEIGHT-64);
        _bgScroll.alwaysBounceVertical = YES;
    }
    return _bgScroll;
}

@end
