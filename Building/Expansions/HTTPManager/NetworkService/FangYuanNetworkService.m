//
//  FangYuanNetworkService.m
//  Building
//
//  Created by Macbook Pro on 2019/2/9.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "FangYuanNetworkService.h"

@implementation FangYuanNetworkService
//城市、商圈基础数据查询
+ (void)getHomeCityShangQuanListSuccess:(void(^)(NSArray *citys))success failure:(void(^)(id response))failure {
    NSString *url = [NSString stringWithFormat:@"%@/home/basicData",BasicUrl];
    [QSNetworking getWithUrl:url success:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] == 200) {
            NSArray * articleArr = [NSArray yy_modelArrayWithClass:[FYShangQuanCityModel class] json:[response objectForKey:@"result"]];
            success(articleArr);
        }else{
            if (failure) {
                failure([response objectForKey:@"msg"]);
            }
        }
    } fail:^(NSError *error) {
        if (failure) {
            failure(@"网络错误");
        }
    }];
}

//城市列表
+ (void)getHomeCityListSuccess:(void(^)(NSArray *citys))success failure:(void(^)(id response))failure {
    NSString *url = [NSString stringWithFormat:@"%@/home/cityList",BasicUrl];
    [QSNetworking getWithUrl:url success:^(id response) {
        if ([[response objectForKey:@"code"] integerValue] == 200) {
            NSArray * articleArr = [NSArray yy_modelArrayWithClass:[FYProvinceModel class] json:[response objectForKey:@"result"]];
            success(articleArr);
        }else{
            if (failure) {
                failure([response objectForKey:@"msg"]);
            }
        }
    } fail:^(NSError *error) {
        if (failure) {
            failure(@"网络错误");
        }
    }];
}

//获取房源列表
+ (void)gainHouseResourceListWithParams:(NSMutableDictionary *)params Success:(void(^)(id response))success failure:(void(^)(id response))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/house/list",BasicUrl];
    [QSNetworking postWithUrl:url params:params success:^(NSDictionary * response) {
        NSDictionary *dict = (NSDictionary *)response;
        if ([[response objectForKey:@"code"] integerValue] == 200){
            FYItemListModel *serviceInfo = [FYItemListModel yy_modelWithJSON:[response objectForKey:@"result"]];
            success(serviceInfo);
        }else{
            if (failure) {
                failure([dict objectForKey:@"msg"]);
            }
        }
    } fail:^(NSError *error) {
        if (failure) {
            failure(@"网络错误");
        }
    }];
}

//获取服务列表
+ (void)gainServiceListWithParams:(NSMutableDictionary *)params headerParams:(NSMutableDictionary *)headerParams Success:(void(^)(id response))success failure:(void(^)(id response))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/product/list",BasicUrl];
    [QSNetworking postWithUrl:url params:params headerParams:headerParams success:^(id response) {
        NSDictionary *dict = (NSDictionary *)response;
        if ([[response objectForKey:@"code"] integerValue] == 200){
            ServiceItemListModel *serviceInfo = [ServiceItemListModel yy_modelWithJSON:[response objectForKey:@"result"]];
            success(serviceInfo);
        }else{
            if (failure) {
                failure([dict objectForKey:@"msg"]);
            }
        }
    } fail:^(NSError *error) {
        if (failure) {
            failure(@"网络错误");
        }
    }];
}

@end
