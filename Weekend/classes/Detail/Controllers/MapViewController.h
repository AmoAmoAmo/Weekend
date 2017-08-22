//
//  MapViewController.h
//  Weekend
//
//  Created by Jane on 16/4/19.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

/** 纬度 */
@property (nonatomic, assign) CGFloat lat;
/** 经度 */
@property (nonatomic, assign) CGFloat lon;

/** 地址信息 - detail */
@property (nonatomic, copy) NSString *locStr;
@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *subTitleStr;

@property (nonatomic, assign) BOOL allowToTransform;

@end
