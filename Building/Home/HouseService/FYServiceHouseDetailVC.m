//
//  FYServiceHouseDetailVC.m
//  Building
//
//  Created by Macbook Pro on 2019/2/19.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "FYServiceHouseDetailVC.h"
#import "SDCycleScrollView.h"
#import "FYServiceOrderScanHouseVC.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/tree.h>
#import "bsDescription.h"

@interface FYServiceHouseDetailVC ()<SDCycleScrollViewDelegate, BMKMapViewDelegate>
@property (strong, nonatomic) FYServiceDetailModel *detailModel;
@property (weak, nonatomic) IBOutlet UIView *cycleSuperView;
@property (weak, nonatomic) IBOutlet UILabel *houseNameLabel;//房间名称
@property (weak, nonatomic) IBOutlet UILabel *sizeFloorLabel;//平米/楼层
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;//租金
@property (weak, nonatomic) IBOutlet UILabel *louPanNameLabel;//楼盘名称
@property (weak, nonatomic) IBOutlet UILabel *serverMoneyLabel;//佣金
@property (weak, nonatomic) IBOutlet UILabel *serverMoneyTitleLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *tagLabels;
@property (weak, nonatomic) IBOutlet UILabel *telLabel;//联系方式
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *houseAreaLabel;//房屋面积
@property (weak, nonatomic) IBOutlet UILabel *wuyeMoneyLabel;//物业管理费
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;//所在楼层
@property (weak, nonatomic) IBOutlet UILabel *fixStatusLabel;//装修情况
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;//建筑面积
@property (weak, nonatomic) IBOutlet UILabel *buildLabel;//建筑年代
@property (weak, nonatomic) IBOutlet UIView *useInfoView;


@property (weak, nonatomic) IBOutlet UILabel *useInfoLabel;//中介操作说明

@property (weak, nonatomic) IBOutlet UILabel *houseJieShaoLabel;//房源介绍
@property (weak, nonatomic) IBOutlet BMKMapView *dituSupperView;
@property (weak, nonatomic) IBOutlet UILabel *gongjiaoLabel;//公交
@property (weak, nonatomic) IBOutlet UILabel *ditieLabel;//地铁
@property (weak, nonatomic) IBOutlet UILabel *buildJieShaoLabel;//楼盘介绍
@property (weak, nonatomic) IBOutlet UIButton *scanHouseButton;//预约看房
@property (weak, nonatomic) IBOutlet UIImageView *phoneCallImg;

@property (strong, nonatomic) SDCycleScrollView *cycleScrollView;

@property (weak, nonatomic) IBOutlet UIWebView *desview;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIImageView *desImage;
@property (nonatomic, copy)  NSString  * mydescriptionStr;//产品描述

//@property (nonatomic, strong) BMKMapView *mapView;//地图
@end

@implementation FYServiceHouseDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cycleScrollView = [[SDCycleScrollView alloc] init];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.pageDotColor = [UIColor whiteColor];
    self.cycleScrollView.currentPageDotColor = BAR_TINTCOLOR;
    [self.cycleSuperView addSubview:self.cycleScrollView];
    __weak typeof(self) weakSelf = self;
    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.cycleSuperView);
    }];
    
    [self.ditieLabel setNumberOfLines:0];
    self.ditieLabel.lineBreakMode = NSLineBreakByWordWrapping;
    //self.ditieLabel.adjustsFontSizeToFitWidth = YES;
    //self.ditieLabel.minimumScaleFactor = 0.5;
    //self.ditieLabel.frame.size =
    
    //百度地图
    self.dituSupperView.delegate = self;
    [self.dituSupperView setZoomLevel:15];//设置缩放级别
    self.dituSupperView.showsUserLocation = YES;//展示定位
    
//    self.dituSupperView.zoomLevel =15;
    //图片，图片点击事件
    [self.phoneCallImg setImage:[UIImage imageNamed:@"ic_telephone.png"]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.phoneCallImg addGestureRecognizer:tapGesture];
    self.phoneCallImg.userInteractionEnabled = YES;
    
    self.desImage.userInteractionEnabled=YES;
    [self.desImage setImage:[UIImage imageNamed:@"list_icon_more.png"]];
    UITapGestureRecognizer *imgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.desImage addGestureRecognizer:imgTouch];
    
    
    self.desLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.desLabel addGestureRecognizer:labelTapGestureRecognizer];

    //self.desview.frame =
    self.desview.delegate = self.view;
    self.desview.scrollView.bounces = NO;
    self.desview.scrollView.showsHorizontalScrollIndicator = NO;
    self.desview.scrollView.scrollEnabled = NO;
    [self.desview sizeToFit];

    //获取数据
    [self gainFYServiceSecondLevelVCData];
}


#pragma mark - Actions
-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"%@被点击了",self.desLabel.text);
    bsDescription *bsd = [[bsDescription alloc] init];
    bsd.mydescription = self.mydescriptionStr;
    [bsd setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:bsd animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dituSupperView viewWillAppear];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dituSupperView viewWillDisappear];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index; {

}

#pragma mark - Actions
-(void)clickImage{
    UIWebView *call = [[UIWebView alloc] init];

    NSMutableString *callSrtr=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.telLabel.text];
    [call loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:callSrtr]]];
    [self.view addSubview:call];
    
    //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:callSrtr]];
    
    //NSLog(@"clickImage:%@", callSrtr);
}


//预约看房
- (IBAction)scanHouseButtonAction:(id)sender {
    //ygz test
    if ([GlobalConfigClass shareMySingle].userAndTokenModel == nil){
        LoginViewController * loginVC = [[LoginViewController alloc] init];
        [loginVC setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:loginVC animated:YES];
        return;
    }
    FYServiceOrderScanHouseVC *hoseDetailVC = [[FYServiceOrderScanHouseVC alloc] init];
    hoseDetailVC.houseId = self.houseId;
    [hoseDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:hoseDetailVC animated:YES];
}

#pragma mark - requests
//获取房源服务房间详情
- (void)gainFYServiceSecondLevelVCData{
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService gainFYServiceHouseDetailHouseId:self.houseId success:^(FYServiceDetailModel *detail) {
        weakSelf.detailModel = detail;
        
        weakSelf.cycleScrollView.imageURLStringsGroup = detail.houseInfo.picList;
        self.houseNameLabel.text = detail.houseInfo.name;//房间名称
        self.sizeFloorLabel.text = [NSString stringWithFormat:@"%@㎡ | %@层", detail.houseInfo.acreage, detail.houseInfo.floor];////平米/楼层
        self.moneyLabel.text = [NSString stringWithFormat:@"%@", detail.houseInfo.price];//租金
        self.louPanNameLabel.text = detail.buildInfo.name;//楼盘名称
        self.mydescriptionStr = detail.houseInfo.descriptionIos;
        //NSLog(@"houseNameLabel:%@",detail.houseInfo.name);
        //NSLog(@"louPanNameLabel:%@",detail.houseInfo.price);
        //NSLog(@"price:%@",detail.buildInfo.name);
        //NSLog(@"commission:%@",detail.houseInfo.commission);
        
        if ([detail.houseInfo.commission isEqualToString:@""] || (detail.houseInfo.commission == nil) ) {
            self.serverMoneyLabel.hidden = YES;//佣金
            self.serverMoneyTitleLabel.hidden = YES;
        } else {
            self.serverMoneyLabel.text = [NSString stringWithFormat:@"%@", detail.houseInfo.commission];//佣金
        }
        
        NSArray *tagsArray = [detail.houseInfo.label componentsSeparatedByString:@" "];//以“ ”切割
        NSInteger tagsCount = tagsArray.count < self.tagLabels.count ? tagsArray.count : self.tagLabels.count;
        for (int i = 0; i < tagsCount; i++) {
            UILabel *tagLabel = self.tagLabels[i];
            //NSString *tagStr = tagsArray[i];
            NSString *tagStr = [NSString stringWithFormat:@" %@ ", tagsArray[i]];
            tagLabel.text = tagStr;
            [tagLabel setBorderWidthColor:UIColorFromHEX(0x73B8FD)];
        }
        self.telLabel.text = detail.buildInfo.wyPhone;//联系方式
        self.addressLabel.text = detail.buildInfo.address;//地址
        self.houseAreaLabel.text = [NSString stringWithFormat:@"%@㎡", detail.houseInfo.acreage];//房屋面积
        self.wuyeMoneyLabel.text = detail.buildInfo.wyFee;//物业管理费
        self.floorLabel.text = [NSString stringWithFormat:@"%@层", detail.houseInfo.floor];//所在楼层
        self.fixStatusLabel.text = detail.houseInfo.decoration;//装修情况
        
        self.areaLabel.text = [NSString stringWithFormat:@"%@㎡", detail.buildInfo.area];//建筑面积
        self.buildLabel.text = detail.buildInfo.endTime;//建筑年代
        
        //NSLog(@"detail.houseInfo.agencyRemark:%@", detail.houseInfo.agencyRemark );

        if( [detail.houseInfo.agencyRemark isEqual:nil] || [detail.houseInfo.agencyRemark isEqualToString:@""] || (detail.houseInfo.agencyRemark == nil) )
        {
            self.useInfoView.alpha = 0;
            //NSLog(@"detail.houseInfo.agencyRemark:nil");
        }
        else
        {
            self.useInfoView.alpha = 1;
            self.useInfoLabel.text = detail.houseInfo.agencyRemark;//中介操作说明

        }

        self.houseJieShaoLabel.text = detail.houseInfo.descriptionIos;//房源介绍
        self.gongjiaoLabel.text = detail.buildInfo.busInfo;//公交
        self.ditieLabel.text = detail.buildInfo.metroInfo;//地铁
        //设置一个行高上限
        CGSize size = CGSizeMake(self.ditieLabel.frame.size.width, self.ditieLabel.frame.size.height*2);
        CGSize expect = [self.ditieLabel sizeThatFits:size];
        self.ditieLabel.frame = CGRectMake( self.ditieLabel.frame.origin.x, self.ditieLabel.frame.origin.y, expect.width, expect.height );

//        float width = ScreenWidth * (375-62)/375;
//        self.ditieLabel.frame.size.width = width;
        self.buildJieShaoLabel.text = detail.buildInfo.introduction;//楼盘介绍
        
        self.navigationItem.title = detail.buildInfo.name;
        
        
        //更新位置数据
        BMKUserLocation *userLocation = [[BMKUserLocation alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[detail.buildInfo.latitude doubleValue] longitude:[detail.buildInfo.longitude doubleValue]];
        userLocation.location = location;
        userLocation.title = detail.buildInfo.name;
        [self.dituSupperView updateLocationData:userLocation];
        [self.dituSupperView setCenterCoordinate:userLocation.location.coordinate animated:YES];//设置用户的坐标
        //设置当前位置小蓝点
//        self.dituSupperView.coordinate = userLocation.location.coordinate;
    } failure:^(id response) {
        [self showHint:response];
    }];
}

@end
