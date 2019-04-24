//
//  ServiceViewController.m
//  YouYi
//
//  Created by Macbook Pro on 2019/1/29.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "ServiceViewController.h"
#import "SDCycleScrollView.h"
#import "CJDropDownMenuView.h"
#import "HomeChoiceCell.h"
#import "CJMenuSelectTwoConView.h"
#import "CJMenuSelectOneConView.h"
#import "FYServiceHouseDetailVC.h"
#import "BuildServiceHouseDetailVC.h"
#import "WRCustomNavigationBar.h"
#import "WRNavigationBar.h"


#define FangYuanCellSectionHeight       47
#define HomeServiceCellHeight       120
#define HomeChoiceCellXibName       @"HomeChoiceCell"

@interface ServiceViewController ()<UITableViewDataSource, UITableViewDelegate, SDCycleScrollViewDelegate, CJDropDownMenuViewDelegate, CJMenuSelectTwoConViewDelegate, CJMenuSelectOneConViewDelegate>
@property (weak, nonatomic) SDCycleScrollView *cycleScrollView;
@property (nonatomic, strong) NSMutableArray *bannerModelArr;
@property (nonatomic, assign) float cycleScrollViewheight;

@property (nonatomic, strong) WRCustomNavigationBar *customNavBar;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CJDropDownMenuView *sectionView;
@property (strong, nonatomic) NSMutableArray <ServiceItemModel *> *serviceList;

//房源列表的参数信息
@property (nonatomic, copy)  NSString  * serviceType;//楼宇服务：buildService;企业服务：corpService
@property (nonatomic, copy)  NSString  * sort;//排序字段,price_desc:价格从高到底; price_asc:价格从低到高；
@property (nonatomic, assign)  NSInteger rentRange;//租金范围1：1500以下；2：1500-2500；3：2500-3500；4：3500-4500；5：4500以上
@property (nonatomic, assign)  NSInteger pageSize;//每页记录数,默认十条，===必填===
@property (nonatomic, assign)  NSInteger page;//查询页码,默认第一页，===必填===
@property (nonatomic, copy)  NSString  * metro;//地铁线路
@property (nonatomic, copy)  NSString  * keyWord;//搜索关键词
@property (nonatomic, assign)  NSInteger productTypeId;//产品类型id ，从首页-》服务二级页面进来时必填
@property (nonatomic, copy)  NSString  *countyId;//区id,支持多选，多个逗号分隔
@property (nonatomic, assign)  NSInteger cityId;//城市id,首页定位的，===必填===
@property (nonatomic, assign)  NSInteger tradingId;//商圈id,支持多选，多个逗号分隔
@property (nonatomic, copy)  NSString  *token;//header传参,登录了传，没有不传，不影响数据的获取
@property (nonatomic, assign)  NSInteger buildId;

@property (strong, nonatomic) CJMenuSelectOneConView *loupanView;//楼盘
@property (assign, nonatomic) BOOL loupanViewIsShow;
@property (strong, nonatomic) NSArray <FYBuildListModel *> *loupanList;
@property (nonatomic, strong) NSMutableArray *lpArr;
@property (nonatomic, strong) NSArray *loupanArr;

@property (strong, nonatomic) NSMutableArray <FYShangQuanCityModel *> *sqModel;

@property (strong, nonatomic) CJMenuSelectOneConView *serviceTypeView;//服务分类
@property (assign, nonatomic) BOOL serviceTypeViewIsShow;

@property (strong, nonatomic) CJMenuSelectTwoConView *quyuView;
@property (assign, nonatomic) BOOL quyuViewIsShow;
@property (strong, nonatomic) NSArray <FYProvinceModel *> *cityList;

@property (strong, nonatomic) CJMenuSelectOneConView *orderView;//排序
@property (assign, nonatomic) BOOL orderViewIsShow;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //数据初始化
    self.bannerModelArr = [[NSMutableArray alloc] init];
    self.serviceList = [[NSMutableArray alloc] init];
    self.cityList = [[NSMutableArray alloc] init];
    self.lpArr = [[NSMutableArray alloc] init];
    self.loupanArr = [[NSArray alloc] init];
    self.loupanList = [[NSMutableArray alloc] init];

    self.quyuViewIsShow = NO;
    self.orderViewIsShow = NO;
    self.serviceTypeViewIsShow = NO;
    self.cycleScrollViewheight = ScreenWidth * 56 / 75;
    
    //房源列表的参数信息,-1和nil在请求数据时不用组装成参数
    self.serviceType = nil;
    self.sort = nil;
    self.rentRange = -1;
    self.pageSize = 20;
    self.page = 1;
    self.metro = nil;
    self.keyWord = nil;
    self.productTypeId = -1;
    self.countyId = nil;
    self.cityId = [[GlobalConfigClass shareMySingle].cityModel.cityId integerValue];
    self.tradingId = -1;
    if ([GlobalConfigClass shareMySingle].userAndTokenModel == nil) {//未登录
        self.token = nil;
    } else {
        self.token = [GlobalConfigClass shareMySingle].userAndTokenModel.token;
    }
    
    
    //UIView *headView = [self myTableHeaderView];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableHeaderView = [self myTableHeaderView];
    
    self.customNavBar.titleLabelColor = UIColorFromHEX(0x6e6e6e);//[UIColor whiteColor];
    //self.customNavBar.title = @"服务";
    [self.customNavBar wr_setBackgroundAlpha:0];
    [self.view insertSubview:self.customNavBar aboveSubview:self.tableView];

    CJDropDownMenuView *menuView = [[CJDropDownMenuView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 47) titleArr:@[@"楼盘", @"服务分类", @"区域", @"默认"]];
    self.sectionView.backgroundColor = [UIColor whiteColor];
    menuView.delegate = self;
    self.sectionView = menuView;
    [self.view insertSubview:self.sectionView belowSubview:self.customNavBar];

    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        self.tableView.mj_footer.hidden = YES;
        [self gainServiceListWithRefresh:YES];
    }];
    //上拉加载
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self gainServiceListWithRefresh:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    //请求数据
    [self gainBannerData];
    [self gainCityList];
    [self gainCityShangQuanALL];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self gainServiceListWithRefresh:YES];
    [self gainCityShangQuanALL];
    //NSLog(@"viewWillAppear animated");
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//城市、商圈基础数据查询
- (void)gainCityShangQuanALL{
    //__weak typeof(self) weakSelf = self;
    [FangYuanNetworkService getHomeCityShangQuanListSuccess:^(NSArray * _Nonnull citys) {
        //weakSelf.cityList = citys;
        self.sqModel = citys;
        [self.lpArr removeAllObjects];
        NSString *str = @"全部";
        NSArray *arr = @[str];
        [self.lpArr addObjectsFromArray:arr];
        self.loupanArr = nil;
        NSString *cityId = [GlobalConfigClass shareMySingle].cityModel.cityId;
        for (FYShangQuanCityModel *cityModel in citys) {
            //            NSLog(@"FYShangQuanCityModel cityId:%@", cityModel.cityId );
            //            NSLog(@"FYShangQuanCityModel cityName:%@", cityModel.cityName );
            //            NSLog(@"FYShangQuanCityModel metro:%@", cityModel.metro );
            
            if ([cityId isEqualToString:cityModel.cityId])
            {
                for (FYBuildListModel *loupanStr in cityModel.buildList)
                {
                    //NSLog(@"loupanStr.name:%@", loupanStr.name );
                    //NSLog(@"loupanStr.id:%@", loupanStr.id );
                    NSArray *array = @[loupanStr.name];
                    [self.lpArr addObjectsFromArray:array];
                }
                self.loupanArr = self.lpArr;
            }
        }
    } failure:^(id  _Nonnull response) {
        
    }];
}

#pragma mark - requests
//获取服务列表
- (void)gainServiceListWithRefresh:(BOOL)isRefresh
{
    //NSLog(@"gainServiceListWithRefresh isRefresh");
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    if (self.rentRange != -1) {
        [params setObject:@(self.rentRange) forKey:@"rentRange"];
    }
    if (self.pageSize != -1) {
        [params setObject:@(self.pageSize) forKey:@"pageSize"];
    }
    if (self.page != -1) {
        [params setObject:@(self.page) forKey:@"page"];
    }
    if (self.productTypeId != -1) {
        [params setObject:@(self.productTypeId) forKey:@"productTypeId"];
    }
    if (self.countyId != nil) {
        [params setObject:self.countyId forKey:@"countyId"];
    }
    if (self.cityId != -1) {
        [params setObject:@(self.cityId) forKey:@"cityId"];
    }
    if (self.tradingId != -1) {
        [params setObject:@(self.tradingId) forKey:@"tradingId"];
    }
    if (self.buildId != -1) {
        [params setObject:@(self.buildId) forKey:@"buildId"];
    }
    if (self.keyWord != nil) {
        [params setObject:self.keyWord forKey:@"keyWord"];
    }
    if (self.metro != nil) {
        [params setObject:self.metro forKey:@"metro"];
    }
    if (self.sort != nil) {
        [params setObject:self.sort forKey:@"sort"];
    }
    if( [GlobalConfigClass shareMySingle].serviceType != nil )
    {
        self.serviceType = [GlobalConfigClass shareMySingle].serviceType;
        [GlobalConfigClass shareMySingle].serviceType = nil;
        //NSLog(@"serviceType:%@", self.serviceType );
        [params setObject:self.serviceType forKey:@"serviceType"];
    }else if (self.serviceType != nil ) {
//        if( [GlobalConfigClass shareMySingle].serviceType != nil )
//        {
//            self.serviceType = [GlobalConfigClass shareMySingle].serviceType;
//            [GlobalConfigClass shareMySingle].serviceType = nil;
//        }
        //NSLog(@"serviceType in:%@", self.serviceType );
        [params setObject:self.serviceType forKey:@"serviceType"];
    }
    else
    {
        //NSLog(@"serviceType out:%@", self.serviceType );
    }

    NSMutableDictionary* paramsHeader = [[NSMutableDictionary alloc] init];
    if (self.token != nil) {
        [paramsHeader setObject:self.token forKey:@"token"];
    }
    
    __weak __typeof__ (self) wself = self;
    [FangYuanNetworkService gainServiceListWithParams:params headerParams:paramsHeader Success:^(id  _Nonnull response) {
        ServiceItemListModel *serviceListModel = response;
        if (isRefresh) {
            [self.serviceList removeAllObjects];
        }
        
        if (!serviceListModel.hasNext) {//下拉加载更多
            self.tableView.mj_footer.hidden = YES;
        } else {
            self.tableView.mj_footer.hidden = NO;
        }
        [wself.serviceList addObjectsFromArray:serviceListModel.data];
        [wself.tableView reloadData];
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    } failure:^(id  _Nonnull response) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

//获取城市列表
- (void)gainCityList{
    __weak typeof(self) weakSelf = self;
    [FangYuanNetworkService getHomeCityListSuccess:^(NSArray * _Nonnull citys) {
        weakSelf.cityList = citys;
    } failure:^(id  _Nonnull response) {
        
    }];
}

- (void)gainBannerData{
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService getBannerInfoWithType:@"POST_SERVICE" Success:^(NSArray *banners) {
        //        NSLog(@"%@", banners);
        [weakSelf.bannerModelArr removeAllObjects];
        for (BannerModel * banner in banners) {
            if([banner.image hasPrefix:@"http"]) {
                [weakSelf.bannerModelArr addObject:banner];
            }
        }
        
        NSMutableArray * bannersTemp = [NSMutableArray arrayWithCapacity:6];
        for (BannerModel *banner in weakSelf.bannerModelArr) {
            [bannersTemp addObject:banner.image];
        }
        
        weakSelf.cycleScrollView.imageURLStringsGroup = bannersTemp;
    } failure:^(id response) {
        [self showHint:response];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY > self.cycleScrollViewheight)
    {
        CGFloat alpha = (offsetY - self.cycleScrollViewheight) / NAV_HEIGHT;
        [self.customNavBar wr_setBackgroundAlpha:alpha];
        self.customNavBar.title = @"服务";
        [self.customNavBar wr_setTintColor:[[UIColor blackColor] colorWithAlphaComponent:alpha]];
        [self wr_setStatusBarStyle:UIStatusBarStyleDefault];
        //self.sectionView.frame=CGRectMake(0, offsetY, ScreenWidth, self.cycleScrollViewheight);

    }
    else
    {
        self.customNavBar.title = @"";
        [self.customNavBar wr_setBackgroundAlpha:0];
        [self.customNavBar wr_setTintColor:UIColorFromHEX(0x707070)];
        [self wr_setStatusBarStyle:UIStatusBarStyleLightContent];
        
    }
    
    if( offsetY > self.customNavBar.height )
    {
        scrollView.contentInset = UIEdgeInsetsMake(self.customNavBar.height, 0, 0, 0);
        self.sectionView.backgroundColor = [UIColor whiteColor];

    }
    else
    {
        self.sectionView.backgroundColor = [UIColor whiteColor];
        scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    }
//    CGFloat sectionHeaderHeight = 47;
//    NSLog(@"contentOffset:%lf,%lf", scrollView.contentOffset.x,scrollView.contentOffset.y);
// if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);
//
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//
//    }
}
#pragma mark - getters and setters
- (WRCustomNavigationBar *)customNavBar
{
    if (_customNavBar == nil) {
        _customNavBar = [WRCustomNavigationBar CustomNavigationBar];
    }
    return _customNavBar;
}

#pragma mark - UITableView Delegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    //ygz test
//    CJDropDownMenuView *menuView = [[CJDropDownMenuView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 47) titleArr:@[@"楼盘", @"服务分类", @"区域", @"默认"]];
//    menuView.delegate = self;
//    self.sectionView = menuView;
//    return menuView;
    
    return self.sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return FangYuanCellSectionHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.serviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeChoiceCell *cell = (HomeChoiceCell *)[self getCellFromXibName:HomeChoiceCellXibName dequeueTableView:tableView];
    ServiceItemModel *model = self.serviceList[indexPath.row];
    cell.serviceModel = model;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HomeServiceCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    
    ServiceItemModel *model = self.serviceList[row];
    BuildServiceHouseDetailVC *hoseDetailVC = [[BuildServiceHouseDetailVC alloc] init];
    hoseDetailVC.productId = [model.productId integerValue];
    [hoseDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:hoseDetailVC animated:YES];
}

#pragma mark - CJDropDownMenuViewDelegate
- (void)didSelectMenuViewItem:(NSInteger)index{
    if(index == 0){
        [self hiddenServiceTypeView];
        [self hiddenQuYuView];
        [self hiddenOrderView];
        
        if (self.loupanViewIsShow) {//目前正在显示
            [self hiddenLoupanView];
        } else {
            [self showLoupanView];
        }
    }
    else if (index == 1) {//服务分类
        [self hiddenLoupanView];
        [self hiddenQuYuView];
        [self hiddenOrderView];
        
        if (self.serviceTypeViewIsShow) {//目前正在显示
            [self hiddenServiceTypeView];
        } else {
            [self showServiceTypeView];
        }
        
    } else if (index == 2) {//区域
        [self hiddenLoupanView];
        [self hiddenServiceTypeView];
        [self hiddenOrderView];
        
        if (self.quyuViewIsShow) {//目前正在显示
            [self hiddenQuYuView];
        } else {
            [self showQuYuView];
        }
        
    } else {//默认
        [self hiddenLoupanView];
        [self hiddenServiceTypeView];
        [self hiddenQuYuView];
        
        if (self.orderViewIsShow) {//目前正在显示
            [self hiddenOrderView];
        } else {
            [self showOrderView];
        }
    }
}

#pragma mark - CJMenuSelectTwoConViewDelegate
- (NSArray *)leftTableViewDatas{
    
    for( FYProvinceModel *pmodel in self.cityList )
    {
        for( FYCityModel *cmode in pmodel.cityList )
        {
            NSString  * cityId = [GlobalConfigClass shareMySingle].cityModel.cityId;
            if( [cmode.cityId isEqualToString:cityId] )
            {
                //NSLog(@"cmode.cityName:%@", cmode.cityName );
                return @[cmode];
                
            }
        }
    }
    
    FYProvinceModel *model = self.cityList[0];
    //NSLog(@"model.cityList[0]:%@", model.cityList[0].cityName );
    return @[model.cityList[0]];//===写死的北京，应该是首页定位的城市或者选择的城市
}

- (void)resetButtonAction:(id)data{
    self.countyId = nil;
    [self hiddenQuYuView];
    [self.tableView.mj_header beginRefreshing];
}

- (void)doneButtonActionSelectCity:(FYCityModel *)city selectCountryArr:(NSArray *)countryArr{
    if (city != nil) {
        self.cityId = [city.cityId intValue];
        if (countryArr.count > 0) {
            for (int i = 0; i < countryArr.count; i++) {
                FYCountryModel *selectCountryModel = countryArr[i];
                if (i == 0) {//第一个
                    self.countyId = selectCountryModel.countryId;
                } else {
                    self.countyId = [NSString stringWithFormat:@"%@,%@", self.countyId, selectCountryModel.countryId];
                }
            }
        }
        
        [self.tableView.mj_header beginRefreshing];
    }
    
    [self hiddenQuYuView];
}

- (void)coverViewTapAction{
    [self hiddenQuYuView];
}

#pragma mark - CJMenuSelectOneConViewDelegate
//row从0开始，分别为@[@"默认", @"价格 低->高", @"价格 高->低"]
- (void)selectOneConViewSelectRow:(NSInteger)row selfView:(CJMenuSelectOneConView *)oneConView{
    if (oneConView == self.orderView) {//排序
        //price_desc:价格从高到底; price_asc:价格从低到高；
        if (row == 1) {
            self.sort = @"price_asc";
        } else if(row == 2){
            self.sort = @"price_desc";
        } else {
            self.sort = nil;
        }
        [self.tableView.mj_header beginRefreshing];
        
        [self hiddenOrderView];
    }
    else if (oneConView == self.loupanView){//楼盘
        //add
        if( row > 0 )
        {
            NSString *cityId = [GlobalConfigClass shareMySingle].cityModel.cityId;
            for (FYShangQuanCityModel *cityModel in self.sqModel) {
                if ([cityId isEqualToString:cityModel.cityId])
                {
                    for (FYBuildListModel *loupanStr in cityModel.buildList)
                    {
                        if( [loupanStr.name isEqualToString:self.loupanArr[row]] )
                        {
                            self.buildId = [loupanStr.id intValue];
                            break;
                        }
                    }
                    break;
                }
            }
        }
        else
            self.buildId = -1;
        NSLog(@"self.buildId:%ld", self.buildId);
        
        [self.tableView.mj_header beginRefreshing];
        
        [self hiddenLoupanView];
    }
    else {//服务分类
        //楼宇服务：buildService;企业服务：corpService
        if (row == 1) {
            self.serviceType = @"buildService";
        } else if(row == 2){
            self.serviceType = @"corpService";
        } else {
            self.serviceType = nil;
        }
        [self.tableView.mj_header beginRefreshing];
        
        [self hiddenServiceTypeView];
    }
}

- (void)selectOneConViewCoverViewTapActionSelfView:(CJMenuSelectOneConView *)oneConView{
    if (oneConView == self.orderView) {//排序
        [self hiddenOrderView];
    }  else if (oneConView == self.loupanView){//楼盘
        [self hiddenLoupanView];
    }else {//服务分类
        [self hiddenServiceTypeView];
    }
}

- (NSArray *)selectOneConViewTableViewDatasSelfView:(CJMenuSelectOneConView *)oneConView{
    if (oneConView == self.orderView) {//排序
        return @[@"默认", @"价格 低->高", @"价格 高->低"];
    }  else if (oneConView == self.loupanView){//楼盘
        return self.loupanArr;
    }else {//服务分类
        return @[@"全部", @"楼宇服务", @"楼通万商"];
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index; {
//    if (self.bannerModelArr.count > index) {
        //        BannerModel *bannerModel = self.bannerModelArr[index];
        //
        //        //统计banner点击率
        //        [HomeNetworkService StatisticBannerClickRateWithBannerid:bannerModel.idStr Success:^(id response) {
        //        } failure:^(id response) {
        //        }];
        //
        //        //跳转对应的链接页
        //        self.webBrowser.navigationItem.title = bannerModel.title;
        //        self.webBrowser.KINWebType = CustomKINWebBrowserTypeHomeBanner;
        //        [self.navigationController pushViewController:self.webBrowser animated:YES];
        //        [self.webBrowser loadURLString:bannerModel.linkUrl];
//    }
}

#pragma mark - getters
- (UIView *)myTableHeaderView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, self.cycleScrollViewheight)];
    
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, ScreenWidth, self.cycleScrollViewheight) delegate:self placeholderImage:[UIImage imageNamed:@"url_no_access_image"]];
    cycleScrollView.pageDotColor = [UIColor whiteColor];
    cycleScrollView.currentPageDotColor = BAR_TINTCOLOR;
    [headerView addSubview:cycleScrollView];
    self.cycleScrollView = cycleScrollView;
    
    return headerView;
}

#pragma - getters and setters
- (CJMenuSelectOneConView *)loupanView{
    if (_loupanView == nil) {
        _loupanView = [[CJMenuSelectOneConView alloc] init];
        _loupanView.delegate = self;
        _loupanView.hidden = YES;
        [self.view addSubview:_loupanView];
        float orderY = self.cycleScrollViewheight + FangYuanCellSectionHeight + 44;
        self.orderView.frame = CGRectMake(0, orderY, ScreenWidth, self.view.frame.size.height - orderY);
    }
    return _loupanView;
}

- (CJMenuSelectTwoConView *)quyuView{
    if (_quyuView == nil) {
        _quyuView = [[CJMenuSelectTwoConView alloc] init];
        _quyuView.delegate = self;
        _quyuView.hidden = YES;
        [self.view addSubview:_quyuView];
        float quyuY = self.cycleScrollViewheight + FangYuanCellSectionHeight + 44;
        self.quyuView.frame = CGRectMake(0, quyuY, ScreenWidth, self.view.frame.size.height - quyuY);
        
    }
    return _quyuView;
}
- (CJMenuSelectOneConView *)orderView{
    if (_orderView == nil) {
        _orderView = [[CJMenuSelectOneConView alloc] init];
        _orderView.delegate = self;
        _orderView.hidden = YES;
        [self.view addSubview:_orderView];
        float orderY = self.cycleScrollViewheight + FangYuanCellSectionHeight + 44;
        self.orderView.frame = CGRectMake(0, orderY, ScreenWidth, self.view.frame.size.height - orderY);
        
    }
    return _orderView;
}

- (CJMenuSelectOneConView *)serviceTypeView{
    if (_serviceTypeView == nil) {
        _serviceTypeView = [[CJMenuSelectOneConView alloc] init];
        _serviceTypeView.delegate = self;
        _serviceTypeView.hidden = YES;
        [self.view addSubview:_serviceTypeView];
        float orderY = self.cycleScrollViewheight + FangYuanCellSectionHeight + 44;
        self.serviceTypeView.frame = CGRectMake(0, orderY, ScreenWidth, self.view.frame.size.height - orderY);
        
    }
    return _serviceTypeView;
}

#pragma - privates
- (void)showLoupanView{
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect rect = [self.sectionView convertRect:self.sectionView.bounds toView:self.view];
    float loupanViewY = rect.origin.y + rect.size.height;
    self.loupanView.frame = CGRectMake(0, loupanViewY, ScreenWidth, self.view.frame.size.height - loupanViewY);
    
    self.loupanView.hidden = NO;
    self.loupanViewIsShow = YES;
}

- (void)hiddenLoupanView{
    self.loupanView.hidden = YES;
    self.loupanViewIsShow = NO;
}

- (void)showServiceTypeView{
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect rect = [self.sectionView convertRect:self.sectionView.bounds toView:self.view];
    float orderY = rect.origin.y + rect.size.height;
    self.serviceTypeView.frame = CGRectMake(0, orderY, ScreenWidth, self.view.frame.size.height - orderY);
    
    self.serviceTypeView.hidden = NO;
    self.serviceTypeViewIsShow = YES;
}

- (void)hiddenServiceTypeView{
    self.serviceTypeView.hidden = YES;
    self.serviceTypeViewIsShow = NO;
}

- (void)showQuYuView{
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect rect = [self.sectionView convertRect:self.sectionView.bounds toView:self.view];
    float quyuY = rect.origin.y + rect.size.height;
    self.quyuView.frame = CGRectMake(0, quyuY, ScreenWidth, self.view.frame.size.height - quyuY);

    [self.quyuView showView];
    self.quyuViewIsShow = YES;
}

- (void)hiddenQuYuView{
    [self.quyuView hiddenView];
    self.quyuViewIsShow = NO;
}

- (void)showOrderView{
    //    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    CGRect rect = [self.sectionView convertRect:self.sectionView.bounds toView:self.view];
    float orderY = rect.origin.y + rect.size.height;
    self.orderView.frame = CGRectMake(0, orderY, ScreenWidth, self.view.frame.size.height - orderY);
    
    //self.orderView.tintColor = UIColorFromHEX(0x73b8ee);
    
    self.orderView.hidden = NO;
    self.orderViewIsShow = YES;
}

- (void)hiddenOrderView{
    //self.orderView.tintColor = UIColorFromHEX(0x6e6e6e);

    self.orderView.hidden = YES;
    self.orderViewIsShow = NO;
}
@end
