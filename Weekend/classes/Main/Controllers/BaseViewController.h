//
//  BaseViewController.h
//  Weekend
//
//  Created by Jane on 16/3/29.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnimationViewController.h"

@interface BaseViewController : AnimationViewController

@property (nonatomic, assign)BOOL isScale;

@property (nonatomic, strong)UIButton *vcCoverBtn;

/** 点击缩放按钮 */
-(void)clickLeftBtn;

/** 点击遮盖vc的按钮 */
-(void)vcCoverBtnClick;

@end
