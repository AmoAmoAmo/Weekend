//
//  DetailViewController.h
//  Weekend
//
//  Created by Jane on 16/3/31.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

/** 周末--id */
@property (nonatomic,assign) NSString *leoID;

/** 轻刻--"发现"界面传过来的ID */
@property (nonatomic,assign) NSString *secondID;

/** 标题str */
@property (nonatomic,assign) NSString *titleStr;

@end
