//
//  LeftMenuView.m
//  Weekend
//
//  Created by Jane on 16/3/28.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "LeftMenuView.h"

@interface LeftMenuView ()

@property (nonatomic, weak) UIButton *selectedBtn;//临时属性 记录之前选中按钮

@property (weak, nonatomic) IBOutlet UIButton *homeBtn;

@property (weak, nonatomic) IBOutlet UIButton *foundBtn;

@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;

@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;
@property (weak, nonatomic) IBOutlet UIButton *cityBtn;

@end

@implementation LeftMenuView

-(void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
    
    self.userHeadImgView.clipsToBounds = YES;
    self.userHeadImgView.layer.cornerRadius = self.userHeadImgView.frame.size.width/2;
    
    self.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
//    NSLog(@"%d",HomeBtnTag);
    //给按钮添加tag值
    self.homeBtn.tag = HomeBtnTag;
    self.foundBtn.tag = FoundBtnTag;
    self.collectionBtn.tag = CollectionBtnTag;
    self.settingBtn.tag = SettingBtnTag;
    // 用户头像按钮
    self.userBtn.tag = SettingBtnTag;
    // 切换城市按钮
    self.cityBtn.tag = CityBtnTag;
    
    [self addNotification];
}

-(void)setDelegate:(id<LeftMenuViewDelegate>)delegate
{
    _delegate = delegate;
    [self LeftMenuBtnClick:self.homeBtn]; // *** 第一次 把home传过去，即默认显示首页
}


- (IBAction)LeftMenuBtnClick:(UIButton *)sender {
    
    if ([_delegate respondsToSelector:@selector(LeftMenuViewBtnClickFromBtnTag:ToBtnTag:)])
    {
        [_delegate LeftMenuViewBtnClickFromBtnTag:self.selectedBtn.tag ToBtnTag:sender.tag];
    }
    
    self.selectedBtn.selected = NO;
    sender.selected = YES;
    self.selectedBtn = sender;
}


-(void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setSelectIndexToHome:) name:@"setSelectIndexToHome" object:nil];
}
-(void)setSelectIndexToHome:(NSNotification*)noti
{
    NSString *btnTitleStr = [NSString stringWithFormat:@"%@[切换]",noti.userInfo[@"name"]];
    [self.cityBtn setTitle:btnTitleStr forState:UIControlStateSelected];
    [self.cityBtn setTitle:btnTitleStr forState:UIControlStateNormal];
    // 延时
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self LeftMenuBtnClick:self.homeBtn];
    });
    
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
