//
//  BuildServiceHouseDetailVC.m
//  Building
//
//  Created by Macbook Pro on 2019/2/19.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "BuildServiceHouseDetailVC.h"
#import "SDCycleScrollView.h"
#import "FYServiceOrderScanHouseVC.h"
#import "ServiceBuyView.h"
#import "ServiceYuYueView.h"
#import "BuildAndCropServiceOrderVC.h"
#import "BuildAndCropServiceYuYueVC.h"
#import "bsDescription.h"

#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/tree.h>

@interface BuildServiceHouseDetailVC ()<SDCycleScrollViewDelegate, ServiceBuyViewDelegate, ServiceYuYueViewDelegate>
@property (strong, nonatomic) ServiceDetailModel *detailModel;
@property (weak, nonatomic) IBOutlet UIView *cycleSuperView;
@property (weak, nonatomic) IBOutlet UILabel *serviceNameLabel;//名称
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;//租金
@property (weak, nonatomic) IBOutlet UILabel *gongsiNameLabel;//楼盘名称
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *tagLabels;
@property (weak, nonatomic) IBOutlet UILabel *serviceJieShaoLabel;//房源介绍
@property (weak, nonatomic) IBOutlet UIButton *buyServiceButton;//预约看房
@property (weak, nonatomic) IBOutlet UIWebView *desview;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;
@property (weak, nonatomic) IBOutlet UIImageView *desImage;

@property (nonatomic, strong) ServiceBuyView *buyView;
@property (nonatomic, strong) ServiceYuYueView *yuyueView;
@property (strong, nonatomic) SDCycleScrollView *cycleScrollView;

@property (nonatomic, copy)  NSString  * mydescriptionStr;//产品描述

@end

@implementation BuildServiceHouseDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"服务详情";
    self.mydescriptionStr = nil;

    self.cycleScrollView = [[SDCycleScrollView alloc] init];
    self.cycleScrollView.delegate = self;
    self.cycleScrollView.pageDotColor = [UIColor whiteColor];
    self.cycleScrollView.currentPageDotColor = BAR_TINTCOLOR;
    [self.cycleSuperView addSubview:self.cycleScrollView];
    __weak typeof(self) weakSelf = self;
    [self.cycleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf.cycleSuperView);
    }];
    
    self.buyView = [[ServiceBuyView alloc] init];
    self.buyView.hidden = YES;
    self.buyView.delegate = self;
    [self.view addSubview:self.buyView];
    [self.buyView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.edges.mas_equalTo(weakSelf.cycleSuperView);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    self.yuyueView = [[ServiceYuYueView alloc] init];
    self.yuyueView.hidden = YES;
    self.yuyueView.delegate = self;
    [self.view addSubview:self.yuyueView];
    [self.yuyueView mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.edges.mas_equalTo(weakSelf.cycleSuperView);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left);
        make.right.mas_equalTo(self.view.mas_right);
        make.height.mas_equalTo(self.view.mas_height);
    }];
    
    self.desImage.userInteractionEnabled=YES;
    [self.desImage setImage:[UIImage imageNamed:@"list_icon_more.png"]];
    UITapGestureRecognizer *imgTouch = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.desImage addGestureRecognizer:imgTouch];

    
    self.desLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [self.desLabel addGestureRecognizer:labelTapGestureRecognizer];


    //UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 300, ScreenWidth, 0)];
    //self.desview.frame =
    self.desview.delegate = self.view;
    self.desview.scrollView.bounces = NO;
    self.desview.scrollView.showsHorizontalScrollIndicator = NO;
    self.desview.scrollView.scrollEnabled = NO;
    [self.desview sizeToFit];
    //获取数据
    [self gainBuildServiceDetailVCData];
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index; {

}

#pragma mark - Actions
-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    //NSLog(@"%@被点击了",self.desLabel.text);
   bsDescription *bsd = [[bsDescription alloc] init];
    bsd.mydescription = self.mydescriptionStr;
    [bsd setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:bsd animated:YES];
}
//立即购买
- (IBAction)buyServiceButtonAction:(id)sender {
    //ygz test
    if ([GlobalConfigClass shareMySingle].userAndTokenModel == nil){
        LoginViewController * loginVC = [[LoginViewController alloc] init];
        [loginVC setHidesBottomBarWhenPushed:YES];
        
        [self.navigationController pushViewController:loginVC animated:YES];
        
        return;
    }
    
    
    if (self.detailModel.productInfo.saleWay == 1) {//售卖方式1购买2预约
        self.buyView.hidden = NO;
    } else {
        self.yuyueView.hidden = NO;
    }
}

#pragma mark - requests
//获取楼宇服务房间详情
- (void)gainBuildServiceDetailVCData{
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService gainServiceDetailProductIda:self.productId success:^(ServiceDetailModel *detail) {
        weakSelf.detailModel = detail;
        
        self.navigationItem.title = detail.productInfo.name;

        weakSelf.cycleScrollView.imageURLStringsGroup = detail.productInfo.detailImg;
        weakSelf.serviceNameLabel.text = detail.productInfo.name;//名称
        weakSelf.moneyLabel.text = [NSString stringWithFormat:@"%@", detail.productInfo.price];//租金
        weakSelf.gongsiNameLabel.text = detail.productInfo.supplierName;//
        NSArray *tagsArray = [detail.productInfo.label componentsSeparatedByString:@" "];//以“ ”切割
        NSInteger tagsCount = tagsArray.count < weakSelf.tagLabels.count ? tagsArray.count : weakSelf.tagLabels.count;
        for (int i = 0; i < tagsCount; i++) {
            UILabel *tagLabel = weakSelf.tagLabels[i];
            NSString *tagStr = [NSString stringWithFormat:@" %@ ", tagsArray[i]];
            tagLabel.text = tagStr;
            [tagLabel setBorderWidthColor:UIColorFromHEX(0x73B8FD)];
        }
        //weakSelf.serviceJieShaoLabel.text = detail.productInfo.mydescription;//房源介绍
        weakSelf.mydescriptionStr = detail.productInfo.mydescription;//房源介绍
        weakSelf.serviceJieShaoLabel.alpha = 0;
        //NSLog(@"mydescription:%@", detail.productInfo.mydescription);
        [weakSelf.desview loadHTMLString:detail.productInfo.mydescription baseURL:nil];
        //[self htmlParseToString:detail.productInfo.mydescription];

        if (detail.productInfo.saleWay == 1) {//售卖方式1购买2预约
            [self.buyServiceButton setTitle:@"立即购买" forState:UIControlStateNormal];
        } else {
            [self.buyServiceButton setTitle:@"立即预约" forState:UIControlStateNormal];
        }
        
        weakSelf.buyView.detailModel = detail;
        weakSelf.yuyueView.detailModel = detail;
    } failure:^(id response) {
        [weakSelf showHint:response];
    }];
}

#pragma mark - ServiceBuyViewDelegate
- (void)coverViewTapAction{
    self.buyView.hidden = YES;
}

- (void)toPayBtnAction{
    BuildAndCropServiceOrderVC *hoseDetailVC = [[BuildAndCropServiceOrderVC alloc] init];
    hoseDetailVC.detailModel = self.detailModel;
    [hoseDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:hoseDetailVC animated:YES];
    
    self.buyView.hidden = YES;
}

#pragma mark - ServiceYuYueViewDelegate
- (void)toPayBtnActionOfServiceYuYueView{
    BuildAndCropServiceYuYueVC *hoseDetailVC = [[BuildAndCropServiceYuYueVC alloc] init];
    hoseDetailVC.detailModel = self.detailModel;
    [hoseDetailVC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:hoseDetailVC animated:YES];
    
    self.yuyueView.hidden = YES;
}
- (void)coverViewTapActionOfServiceYuYueView{
    
    self.yuyueView.hidden = YES;
}
@end
