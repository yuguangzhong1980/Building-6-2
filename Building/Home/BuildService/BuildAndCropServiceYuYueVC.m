//
//  BuildAndCropServiceYuYueVC.m
//  Building
//
//  Created by Macbook Pro on 2019/3/11.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "BuildAndCropServiceYuYueVC.h"
#import "RRTextView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AlipaySDK/AlipaySDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZHPickView.h"

@interface BuildAndCropServiceYuYueVC ()<UITextViewDelegate, ZHPickViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *oneLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *countLiuYanLabel;
@property (weak, nonatomic) IBOutlet RRTextView *myTextView;
@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (nonatomic, copy)  NSString  *token;//header传参,登录了传，没有不传，不影响数据的获取
@property (strong, nonatomic) ServiceProductSkuPriceModel *currentProductPriceModel;
@property (nonatomic, strong)ZHPickView *pickDateview;
@end

@implementation BuildAndCropServiceYuYueVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //数据初始化
    if ([GlobalConfigClass shareMySingle].userAndTokenModel == nil) {//未登录
        self.token = nil;
    } else {
        self.token = [GlobalConfigClass shareMySingle].userAndTokenModel.token;
    }
    
    [_myTextView setBackgroundColor:UIColorFromHEX(0xf7f7f7)];
    [_myTextView setUserInteractionEnabled:YES];
    _myTextView.delegate = self;
    [_myTextView setFont:UIFontWithSize(13)];
    [_myTextView setPlaceholderOriginY:7 andOriginX:2];
    _myTextView.placeholder = @"留言信息（最多300字）";

//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
//                                             initWithTarget:self action:@selector(handleBackgroundTap:)];
//    tapRecognizer.cancelsTouchesInView = NO;
//    [self.view addGestureRecognizer:tapRecognizer];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfViewTapAction:)];
    //gesture.delegate = self;
    gesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gesture];

    NSDate *dateTemp = [NSDate date];
    _pickDateview = [[ZHPickView alloc] initDatePickWithDate:dateTemp maxDate:nil datePickerMode:UIDatePickerModeDateAndTime isHaveNavControler:NO];
    _pickDateview.delegate=self;

    self.detailModel = self.detailModel;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self gainAddressList];
    [self.pickDateview remove];

    //[self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
    [self.myTextView resignFirstResponder];
}

//tap响应函数
- (void)selfViewTapAction:(UITapGestureRecognizer *)tapGesture
{
    //    UIView *itemView = tapGesture.view;
    //    NSLog(@"%ld", (long)itemView.tag);
    
    [self.view endEditing:YES];
    [self.pickDateview remove];
}

//点击别的区域隐藏虚拟键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self.pickDateview remove];

}
#pragma mark - requests
//获取地址列表
- (void)gainAddressList
{
//    NSMutableDictionary* paramsHeader = [[NSMutableDictionary alloc] init];
//    if (self.token != nil) {
//        [paramsHeader setObject:self.token forKey:@"token"];
//    }
//
//    __weak __typeof__ (self) wself = self;
//    [MineNetworkService gainAddressListWithHeaderParams:paramsHeader Success:^(NSArray *addressArr) {
//        wself.addressList = addressArr;
//        for (AddressModel* item in addressArr) {
//            if (item.defaultBool == true) {
//
//                break;
//            }
//        }
//    } failure:^(id  _Nonnull response) {
//        [wself showHint:response];
//    }];
}

#pragma mark - ZhpickVIewDelegate
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString {
    DLog(@"resultString=%@\n", resultString);
    NSString *selectdateStr = [resultString substringToIndex:17];//截取2018-11-20 10:30格式的字符串
    NSString *datetext = [selectdateStr stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
    datetext = [datetext stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
    datetext = [datetext stringByReplacingOccurrencesOfString:@"日" withString:@""];
    self.timeField.text = datetext;
    //NSLog(@"timeField:%@",self.timeField.text );
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +0000";
    //
    //    NSDate *tempDate = [formatter dateFromString:resultString];
    //    DLog(@"tempDate=%@\n", tempDate);
    
    //    self.birthTimeStr = [NSString stringWithFormat:@"%lld", (long long)([tempDate timeIntervalSince1970] * 1000)];
    //    self.birthLabel.text = [GlobalUtil dateStrForTime:[self.birthTimeStr longLongValue] format:@"yyyy-MM-dd"];
}

-(void)textViewDidChange:(UITextView *)textView
{
    long currentLen = (long)textView.text.length;
    //NSLog(@"currentLen:%ld", currentLen );
    //[self.myTextView resignFirstResponder];
    if( currentLen >= 300 )
    {
        self.countLiuYanLabel.text = [NSString stringWithFormat:@"还可输入%ld字",0];
        //textView.editable = NO;
        textView.text = [textView.text substringToIndex:300];
        //return NO;
    }
    else
    {
        //还可输入300字
        self.countLiuYanLabel.text = [NSString stringWithFormat:@"还可输入%ld字",300-currentLen];
        //textView.editable = YES;
    }
    
    //    if( currentLen > 0 )
    //    {
    //        [_myTextView setHidden:YES];
    //    }
    //return YES;
}
#pragma mark - Actions
//选择预约时间
- (IBAction)timeViewTap:(id)sender {
    [_pickDateview show];
}
//支付
- (IBAction)buyButtonAction:(id)sender {
    [self.view endEditing:YES];

    if ([self.nameField.text isEqualToString:@""] ) {
        [self showHint:self.view text:@"请填写您的姓名"];
        return;
    } else if  ([self.phoneField.text isEqualToString:@""]) {
        [self showHint:self.view text:@"请填写您的手机号"];
        return;
    } else if  ([self.timeField.text isEqualToString:@""]) {
        [self showHint:self.view text:@"请选择您要预约的时间"];
        return;
    }
    if  (self.token == nil) {
        [self showHint:self.view text:@"请登录"];
        return;
    }
    
    //组装数据
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:self.nameField.text forKey:@"contact"];
    [params setObject:self.phoneField.text forKey:@"contactNumber"];
    [params setObject:self.myTextView.text forKey:@"message"];
    [params setObject:self.timeField.text forKey:@"subscribeTime"];
    //NSLog(@"timeLabel:%@", self.timeField.text);
    [params setObject:[NSString stringWithFormat:@"%ld",(long)self.detailModel.productInfo.productId] forKey:@"productId" ];
    [params setObject:[NSString stringWithFormat:@"%ld", self.currentProductPriceModel.productSaleId] forKey:@"productSaleId" ];
    
    NSMutableDictionary* paramsHeader = [[NSMutableDictionary alloc] init];
    if (self.token != nil) {
        [paramsHeader setObject:self.token forKey:@"token"];
    }
    
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService orderBuildAndCropServiceWithParams:params headerParams:paramsHeader Success:^(NSInteger code) {
        [weakSelf showHint:@"预约成功"];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(id response) {
        [weakSelf showHint:response];
    }];
}


#pragma mark - setters
- (void)setDetailModel:(ServiceDetailModel *)detailModel{
    _detailModel = detailModel;

    NSURL *url = [NSURL URLWithString:@""];
    if (detailModel.productInfo.detailImg.count > 0) {
        url = [NSURL URLWithString:detailModel.productInfo.detailImg[0]];
    }
    [self.myImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"url_no_access_image"]];

    self.navigationItem.title = detailModel.productInfo.name;

    self.oneLabel.text = detailModel.productInfo.name;//产品名称
    self.twoLabel.text = detailModel.productInfo.supplierName;
    
    ServiceProductSkuInfoAttrModel *selectItem = nil;
    for (ServiceProductSkuInfoAttrModel *item in detailModel.productSku.skuInfo[0].attrList) {
        if (item.isSelect == true) {
            self.threeLabel.text = item.attrName;
            selectItem = item;
            break;
        }
    }
    
    for (ServiceProductSkuPriceModel *item in self.detailModel.productSku.priceList) {
        if (item.attrIds == selectItem.attrId) {
            self.moneyLabel.text = item.price;
            self.currentProductPriceModel = item;
            break;
        }
    }
    
    self.totalMoneyLabel.text = self.moneyLabel.text;
}

@end
