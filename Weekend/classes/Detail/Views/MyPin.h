//
//  MyPin.h
//  Weekend
//
//  Created by Jane on 16/5/15.
//  Copyright © 2016年 Jane. All rights reserved.
//
//  大头针呼出气泡的数据

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyPin : NSObject<MKAnnotation>

//重写协议中的get方法
//- (CLLocationCoordinate2D)coordinate;
//- (NSString *)title;
//- (NSString *)subtitle;
/**
 *  大头针的位置
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/**
 *  大头针标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  大头针的子标题
 */
@property (nonatomic, copy) NSString *subtitle;
/**
 *  大头针的图片
 */
@property (nonatomic, copy) NSString *imgStr;

//自定义构造方法,来初始化大头针
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D )coordinate AndTitle:(NSString *)title AndSubTitle:(NSString *)subTitle AndImage:(NSString *)imgStr;

@end
