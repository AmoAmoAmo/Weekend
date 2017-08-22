//
//  SearchView.h
//  LoveFresh
//
//  Created by Jane on 16/4/11.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>
/** 点击返回该按钮的回调 */
typedef void(^ReturnBtnBlock)(UIButton *btn);

@interface SearchView : UIView

@property (nonatomic,assign) CGFloat viewHeight;

@property (nonatomic,strong) ReturnBtnBlock returnBtnBlock;
//-(void)returnBtn:(ReturnBtnBlock)block;


-(void)createSearchViewWithTitle:(NSString *)titleName andSearchViewFRame:(CGRect)frame andDataArr:(NSMutableArray*)dataArr andreturnBtn:(ReturnBtnBlock)block;

@end
