//
//  SearchView.m
//  LoveFresh
//
//  Created by Jane on 16/4/11.
//  Copyright © 2016年 Jane. All rights reserved.
//
//  生成 “热门搜索” 和 “历史记录” 的view

#import "SearchView.h"

@interface SearchView ()

@property (nonatomic,strong) UILabel *headTitleLabel;

@end


@implementation SearchView

-(void)createSearchViewWithTitle:(NSString *)titleName andSearchViewFRame:(CGRect)frame andDataArr:(NSMutableArray *)dataArr andreturnBtn:(ReturnBtnBlock)block
{
    
    self.headTitleLabel.frame = CGRectMake(10, 0, frame.size.width-40, 40);
    self.headTitleLabel.font = [UIFont systemFontOfSize:14];
    self.headTitleLabel.text = titleName;
    [self addSubview:self.headTitleLabel];
    
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, 39, SCREENWIDTH-20, 1)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineV];
    
    CGFloat btnW = 0;
    CGFloat btnH = 25;
    CGFloat addW = 30;   // 补充宽度
    CGFloat marginX = 10;//间距
    CGFloat marginY = 10;
    CGFloat lastX = 0;
    CGFloat lastY= 40 + 20;
    
    for (int i = 0; i < dataArr.count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:dataArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn.titleLabel sizeToFit];
        btn.backgroundColor = [UIColor whiteColor];
//        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = 13;
        btn.layer.borderWidth = 0.8;
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = YES;
        
        btnW = btn.titleLabel.frame.size.width + addW;  // 按钮总宽度 = label宽 + 补充
        
        // 判断Y，并且设置frame
        if ((frame.size.width - lastX) > btnW) {
            btn.frame= CGRectMake(lastX, lastY, btnW, btnH);
        }else{
            btn.frame= CGRectMake(0, lastY + marginY + btnH, btnW, btnH);
        }
        
        lastX = CGRectGetMaxX(btn.frame) + marginX;
        lastY = btn.frame.origin.y;
        self.viewHeight = CGRectGetMaxY(btn.frame);
        
        [self addSubview:btn];
    }
    
    self.returnBtnBlock = block;
//    NSLog(@"blcok1%@",block);
}

-(void)clickBtn:(UIButton *)btn
{
//    NSLog(@"click btn");
    if (self.returnBtnBlock) {
//        NSLog(@"*****%@",btn.titleLabel.text);
        self.returnBtnBlock(btn);
    }
}

-(UILabel *)headTitleLabel
{
    if (!_headTitleLabel) {
        _headTitleLabel = [[UILabel alloc] init];
    }
    return _headTitleLabel;
}

@end
