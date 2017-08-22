//
//  SearchViewController.m
//  Weekend
//
//  Created by Jane on 16/3/30.
//  Copyright © 2016年 Jane. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchView.h"

#define USER @"user"


@interface SearchViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic,strong) UIButton *backBtn;

@property (nonatomic,strong) NSMutableArray * dataArray ; //数据源数组

@property (nonatomic,strong) NSMutableArray * resultArray ;//搜索结果数组
/** 历史记录数组 */
@property (nonatomic,strong) NSMutableArray * historyDataArr ;

@property (nonatomic,strong) UISearchBar *searchBar;
/** 清空历史记录的按钮 */
@property (nonatomic, strong) UIButton *clearnBtn;
/** 背景 最底层的scroll */
@property (nonatomic, strong) UIScrollView *bgScroll;

@property (nonatomic, strong) UITableView *table;

@property (nonatomic, strong) NSMutableArray *hotDataArr;
/** 热门搜索 的view */
@property (nonatomic, strong) SearchView *hotView;
/** 历史记录 的view */
@property (nonatomic, strong) SearchView *historyView;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = BGCOLOR;
    
    [self setUI];
}

-(void)setUI
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:(UIView *)self.backBtn];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
    
    [self.view addSubview:self.bgScroll];
    
    self.navigationItem.titleView = self.searchBar;
    
    [self.bgScroll addSubview:self.clearnBtn];//清除历史按钮  hiden
    
    [self buildHotView];
    
    [self loadHistorySearchData];   /** buildHistoryView */
    
    [self buildSearchedTable];
}

-(void)buildHotView
{
    [self.hotView createSearchViewWithTitle:@"热门搜索" andSearchViewFRame:CGRectMake(10, 20, SCREENWIDTH-20, 200) andDataArr:self.hotDataArr andreturnBtn:^(UIButton *btn) {
        //  回调
        //        NSLog(@"%@",btn.titleLabel.text);
        [self.searchBar setText:btn.titleLabel.text];
        [self writeDataToUserDefaultWithString:btn.titleLabel.text];
        //        NSLog(@"%@",self.searchBar.text);
        [self loadSearchedTableViewWithKeyWords:btn.titleLabel.text];
    }];
    
    self.hotView.frame = CGRectMake(10, 0, SCREENWIDTH - 20, self.hotView.viewHeight);
    [self.bgScroll addSubview:self.hotView];
}

-(void)loadHistorySearchData
{
    //清空
    if (self.historyView !=nil) {
        [self.historyView removeFromSuperview];
        self.historyView = nil;
    }
    
    
    NSMutableArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    //    NSLog(@"%ld",arr.count);
    if (arr > 0) {
        [self.historyView createSearchViewWithTitle:@"历史记录" andSearchViewFRame:CGRectMake(10, CGRectGetMaxY(self.hotView.frame) + 20, SCREENWIDTH - 20, 0) andDataArr:arr andreturnBtn:^(UIButton *btn) {
            
            //  回调
            [self.searchBar setText:btn.titleLabel.text];
            //            [self writeDataToUserDefaultWithString:btn.titleLabel.text];
            [self loadSearchedTableViewWithKeyWords: btn.titleLabel.text];
        }];
        self.historyView.frame = CGRectMake(10, CGRectGetMaxY(self.hotView.frame) + 20, SCREENWIDTH - 20, self.historyView.viewHeight);
        [self.bgScroll addSubview:self.historyView];
        [self updateCleanBtnWithisHiden:NO];
    }
    
    
}

-(void)writeDataToUserDefaultWithString:(NSString*)str
{
    NSMutableArray *arrM = [[NSUserDefaults standardUserDefaults] objectForKey:USER];
    NSMutableArray *arrM2 = [NSMutableArray arrayWithArray:arrM];
    for (NSString *string in arrM) {
        if (string == str) {// 如果重复过 则无视
            return;
        }
    }
    [arrM2 insertObject:str atIndex:arrM.count];
    //    NSLog(@"arrM.count=======%ld",arrM2.count);
    
    [[NSUserDefaults standardUserDefaults] setObject:arrM2 forKey:USER];
}

-(void)loadSearchedTableViewWithKeyWords:(NSString *)str
{
    self.table.hidden = NO;
}

-(void)buildSearchedTable
{
    self.table.hidden = YES;
    [self.view addSubview:self.table];
    //    //cell注册方式
    //    [self.table registerNib:[UINib nibWithNibName:@"FirstCell" bundle:nil] forCellReuseIdentifier:@"cell1"];
    
    // head...
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    headView.backgroundColor = [UIColor whiteColor];
    self.table.tableHeaderView = headView;
    
    // foot...
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, self.table.frame.size.height, self.view.frame.size.width, 100)];
    footView.backgroundColor = [UIColor grayColor];
    self.table.tableFooterView = footView;
}


#pragma mark - UITableViewDataSource
// 返回段头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
// 返回段头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    backView.backgroundColor = [UIColor orangeColor];
    
    // 添加自定义的view
    
    // 带有xib的UIView创建方式
    //    customHeadView *headView = [[NSBundle mainBundle] loadNibNamed:@"customHeadView" owner:self options:0][0];
    
    //    headView.frame = CGRectMake(20, 10, self.view.frame.size.width-40, 50);
    
    //    [backView addSubview:headView];
    
    return backView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //_dataArray 有多少个数组,就有多少个section
    //    return _dataArray.count;
    return 5;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //取到每个_dataArray的元素,并返回元素个数
    //    NSArray *array = [_dataArray objectAtIndex:section];
    //    return array.count;
    return 10;
}

//返回每个cell的高度，这里高度是固定的，可以直接写死, 如果高度是不固定的需要先调用estimatedHeightForRowAtIndexPath:方法给个预计高度
//等网络请求完毕后根据cell内容算出高度 再调用heightForRowAtIndexPath：设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;//cell右侧提示图标
    cell.selectionStyle = UITableViewCellSelectionStyleNone;//去掉cell选中效果
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}





#pragma mark -- UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText //实时获得搜索框中输入的数据
{
    //    NSLog(@"%@ ", searchText) ;
    //    NSString * str = searchBar.text ;
    if (searchText.length == 0) {
        //    NSLog(@"%@ -- %@",str, searchText) ;
        
        // searchBar字符串为0就隐藏搜索结果collection
        self.table.hidden = YES;
        // 刷新 历史记录
        [self loadHistorySearchData];
    }
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar  //  搜索按钮(回车)被按下
{
//    NSLog(@"search.......");
    
    
    [self writeDataToUserDefaultWithString:self.searchBar.text];
    //        NSLog(@"%@",self.searchBar.text);
    [self loadSearchedTableViewWithKeyWords:self.searchBar.text];
    
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self.searchBar endEditing:YES];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar endEditing:YES];
}





//清 空 历 史
-(void)clickCleanHistorySearch
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER];
    [self loadHistorySearchData];
    [self updateCleanBtnWithisHiden:YES];
}

//更新清除历史按钮的位置
-(void)updateCleanBtnWithisHiden:(BOOL)isHiden
{
    if (self.historyView != nil) {
        self.clearnBtn.frame = CGRectMake(0.1*SCREENWIDTH, CGRectGetMaxY(self.historyView.frame)+20, SCREENWIDTH*0.8, 40);
    }
    self.clearnBtn.hidden = isHiden;
    
}



#pragma mark - setter and getter
//懒加载
-(UITableView *)table
{
    if (_table == nil)
    {
        _table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];//style:UITableViewStylePlain(默认 设置分组有悬浮)
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;//把table的线去掉
        _table.delegate = self;
        _table.dataSource = self;
    }
    return _table;
}









-(void)clickBackBtn
{
    [self.navigationController popViewControllerAnimated:YES];
}






#pragma mark - setter and getter

-(UIButton *)backBtn
{
    if (!_backBtn) {
        
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[[UIImage imageNamed:@"ic_nav_left"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        _backBtn.frame = CGRectMake(0, 0, 25, 25);
        _backBtn.titleLabel.hidden =YES;
        [_backBtn addTarget:self action:@selector(clickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
-(UIScrollView *)bgScroll
{
    if (!_bgScroll) {
        
        _bgScroll = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _bgScroll.alwaysBounceVertical = YES;
        _bgScroll.delegate = self;
        _bgScroll.userInteractionEnabled = YES;
    }
    return _bgScroll;
}
-(NSMutableArray *)hotDataArr
{
    if (!_hotDataArr) {
        
        // 模拟服务器返回的数据
        _hotDataArr = [NSMutableArray arrayWithObjects:@"滑雪",@"温泉",@"跨年",@"骑行",@"丛林",@"热气球",@"跳伞",@"美食",@"橙", nil];
    }
    return _hotDataArr;
}
-(UISearchBar *)searchBar
{
    if (!_searchBar) {
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
        _searchBar.delegate = self;
        _searchBar.searchBarStyle = UISearchBarStyleDefault;
        _searchBar.placeholder = @"请输入关键字";
    }
    return _searchBar;
}
-(SearchView *)hotView
{
    if (!_hotView) {
        
        //        _hotView = [[SearchView alloc] init];//用这个方法 初始化时frame为0000，子控件btn不能被点击到
        _hotView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];//随便设一个frame，反正后面会修改
        _hotView.userInteractionEnabled = YES;
    }
    return _hotView;
}
-(SearchView *)historyView
{
    if (!_historyView) {
        
        _historyView = [[SearchView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
    }
    return _historyView;
}

-(UIButton *)clearnBtn
{
    if (!_clearnBtn) {
        
        _clearnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clearnBtn setTitle:@"清 空 历 史" forState:UIControlStateNormal];
        [_clearnBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _clearnBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _clearnBtn.backgroundColor = self.view.backgroundColor;
        _clearnBtn.layer.cornerRadius = 8;
        _clearnBtn.clipsToBounds = YES;
        _clearnBtn.layer.borderWidth = 1;
        _clearnBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [_clearnBtn addTarget:self action:@selector(clickCleanHistorySearch) forControlEvents:UIControlEventTouchUpInside];
        _clearnBtn.hidden = YES;
    }
    return _clearnBtn;
}

@end
