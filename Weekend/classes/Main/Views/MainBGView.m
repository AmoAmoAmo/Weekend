//
//  MainBGView.m
//  Weekend
//
//  Created by Jane on 16/4/5.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "MainBGView.h"

@interface MainBGView ()

#ifdef iOS8
/** 用来模糊背景的特效 - 毛玻璃 */
@property (nonatomic, strong) UIVisualEffectView *effectview;
#endif

@end

@implementation MainBGView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        [self setImage:[UIImage imageNamed:@"3"]];
        self.alpha = 1;
        
        
        if (iOS8) {
            //添加到要有毛玻璃特效的控件中
            [self addSubview:self.effectview];
        }
    }
    return self;
}

#ifdef iOS8
- (UIVisualEffectView *)effectview
{
    if (_effectview == nil) {
        //  创建需要的毛玻璃特效"类型"
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        //  毛玻璃view "视图"
        _effectview = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _effectview.frame = [[UIScreen mainScreen] bounds];

        //  设置模糊透明度
//        _effectview.alpha = .5f;
    }
    
    return _effectview;
}
#endif

@end
