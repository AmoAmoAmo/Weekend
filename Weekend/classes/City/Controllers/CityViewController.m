//
//  CityViewController.m
//  Weekend
//
//  Created by Jane on 16/5/14.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "CityViewController.h"

@interface CityViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation CityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"当前城市：深圳";
    
    self.view.backgroundColor= AUTOCOLOR;
    
    [self buildTableView];
}

-(void)buildTableView
{
    [self.view addSubview:self.table];
    //    //cell注册方式
    //    [self.table registerNib:[UINib nibWithNibName:@"FirstCell" bundle:nil] forCellReuseIdentifier:@"cell1"];
    
//    // head...
//    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
//    headView.backgroundColor = [UIColor whiteColor];
//    self.table.tableHeaderView = headView;
//    
//    // foot...
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, self.table.frame.size.height, self.view.frame.size.width, 100)];
//    footView.backgroundColor = [UIColor grayColor];
//    self.table.tableFooterView = footView;
}


#pragma mark - UITableViewDataSource
// 返回段头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}
////设置组名
//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    // data
//    NSDictionary *dic = [self.dataArr objectAtIndex:section];
//    return dic[@"begin_key"];
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = [self.dataArr objectAtIndex:section];
    NSArray *arr = dic[@"city_list"];
    return arr.count;
}
-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 35)];
    bgView.backgroundColor= [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 35)];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor blackColor];
    // data
    NSDictionary *dic = [self.dataArr objectAtIndex:section];
    label.text = dic[@"begin_key"];
    [bgView addSubview:label];
    return bgView;
}
// 设置组索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    //需要返回一个数组
    //用valueForKey只能在本层级字典中查找，而self.dataArr是数组，且没有title关键字
    //用valueForKeyPath可以在本级及下级字典数组中查找，有path路径
    // data
    return [self.dataArr valueForKeyPath:@"begin_key"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//去掉cell选中效果
    
    
    // data
    NSDictionary *dic = [self.dataArr objectAtIndex:indexPath.section];
    NSArray *arr = dic[@"city_list"];
    NSDictionary *tempDic = arr[indexPath.row];
    cell.textLabel.text = tempDic[@"city_name"];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // data
    NSDictionary *dic = [self.dataArr objectAtIndex:indexPath.section];
    NSArray *arr = dic[@"city_list"];
    NSDictionary *tempDic = arr[indexPath.row];
    self.title = [NSString stringWithFormat:@"当前城市：%@",tempDic[@"city_name"]];
    [self clickLeftBtn];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setSelectIndexToHome" object:nil userInfo:@{@"name":tempDic[@"city_name"]}];
    
    // 通知首页、其他页面刷新数据    发送city id
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didSelectACityToReloadData" object:nil userInfo:@{@"city_id":tempDic[@"city_id"]}];
    
}




#pragma mark - setter and getter
//懒加载
-(UITableView *)table
{
    if (_table == nil)
    {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];//style:UITableViewStylePlain(默认 设置分组有悬浮)
        //        _table.separatorStyle = UITableViewCellSeparatorStyleNone;//把table的线去掉
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"City" ofType:nil];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        _dataArr = dic[@"result"];
    }
    return _dataArr;
}


@end
