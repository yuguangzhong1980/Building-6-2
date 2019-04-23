//
//  FYServiceOrderScanHouseVC.m
//  Building
//
//  Created by Macbook Pro on 2019/2/20.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "FYServiceOrderScanHouseVC.h"
#import "RRTextView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ZHPickView.h"

@interface FYServiceOrderScanHouseVC ()<UITextViewDelegate, ZHPickViewDelegate>
@property (strong, nonatomic) FYServiceDetailModel *detailModel;
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeFloorLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverMoneyLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;//显示textView剩余可输入字数，已隐藏
@property (weak, nonatomic) IBOutlet RRTextView *myTextView;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (nonatomic, strong)ZHPickView *pickDateview;
@end

@implementation FYServiceOrderScanHouseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"预约看房";
    self.phoneField.keyboardType = UIKeyboardTypeNumberPad;
    
    [_myTextView setBackgroundColor:UIColorFromHEX(0xf7f7f7)];
    [_myTextView setUserInteractionEnabled:YES];
    _myTextView.delegate = self;
    [_myTextView setFont:UIFontWithSize(13)];
    [_myTextView setPlaceholderOriginY:7 andOriginX:2];
    _myTextView.placeholder = @"留言信息（最多300字）";
    [_myTextView setPlaceholderColor:UIColorFromHEX(0xbababa)];
    
    
    NSDate *dateTemp = [NSDate date];
    _pickDateview = [[ZHPickView alloc] initDatePickWithDate:dateTemp maxDate:nil datePickerMode:UIDatePickerModeDateAndTime isHaveNavControler:NO];
    _pickDateview.delegate=self;
    
    

    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfViewTapAction:)];
    //gesture.delegate = self;
    gesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gesture];

    [self gainFYServiceSecondLevelVCData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.pickDateview remove];
}

-(void)textViewDidChange:(UITextView *)textView
{
    long currentLen = (long)textView.text.length;
    //NSLog(@"currentLen:%ld", currentLen );
    
    if( currentLen >= 300 )
    {
        self.countLabel.text = [NSString stringWithFormat:@"还可输入%ld字",0];
        //textView.editable = NO;
        textView.text = [textView.text substringToIndex:300];
        //return NO;
    }
    else
    {
        //还可输入300字
        self.countLabel.text = [NSString stringWithFormat:@"还可输入%ld字",300-currentLen];
        //textView.editable = YES;
    }
    //return YES;
}

#pragma mark - ZhpickVIewDelegate
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString {
    DLog(@"resultString=%@\n", resultString);
    NSString *selectdateStr = [resultString substringToIndex:17];//截取2018-11-20 10:30格式的字符串
    NSString *datetext = [selectdateStr stringByReplacingOccurrencesOfString:@"年" withString:@"-"];
    datetext = [datetext stringByReplacingOccurrencesOfString:@"月" withString:@"-"];
    datetext = [datetext stringByReplacingOccurrencesOfString:@"日" withString:@""];
    self.timeField.text = datetext;
//   NSLog(@"timeField:%@",self.timeField.text );
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss +0000";
//
//    NSDate *tempDate = [formatter dateFromString:resultString];
//    DLog(@"tempDate=%@\n", tempDate);
    
//    self.birthTimeStr = [NSString stringWithFormat:@"%lld", (long long)([tempDate timeIntervalSince1970] * 1000)];
//    self.birthLabel.text = [GlobalUtil dateStrForTime:[self.birthTimeStr longLongValue] format:@"yyyy-MM-dd"];
}

#pragma mark - Actions
//提交按钮
- (IBAction)commitButtonAction:(id)sender {
    [self.view endEditing:YES];
    
    if ([GlobalConfigClass shareMySingle].userAndTokenModel == nil) {//未登录
        [[UIApplication sharedApplication].delegate performSelector:@selector(jumpToLoginVCWithVC:) withObject:self];
    } else {
        [self orderFYServiceHouse];
    }
}

- (void) handleBackgroundTap:(UITapGestureRecognizer*)sender
{
    //NSLog(@"handleBackgroundTap");
    [self.myTextView resignFirstResponder];
    [self.pickDateview remove];

}

//点击别的区域隐藏虚拟键盘
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    //NSLog(@"touchesBegan");
    [self.myTextView resignFirstResponder];
    [self.pickDateview remove];

    //_myTextView.placeholder.
}
//选择时间
- (IBAction)timeViewTap:(id)sender {
    [_pickDateview show];
}

//tap响应函数
- (void)selfViewTapAction:(UITapGestureRecognizer *)tapGesture
{
    //    UIView *itemView = tapGesture.view;
    //    NSLog(@"%ld", (long)itemView.tag);
    
    [self.view endEditing:YES];
    [self.pickDateview remove];
}


#pragma mark - requests
//获取房源服务房间详情
- (void)gainFYServiceSecondLevelVCData{
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService gainFYServiceHouseDetailHouseId:self.houseId success:^(FYServiceDetailModel *detail) {
        weakSelf.detailModel = detail;
        
        NSURL *url = [NSURL URLWithString:detail.houseInfo.picList[0]];
        [self.myImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"url_no_access_image"]];
        self.nameLabel.text = detail.houseInfo.name;//房间名称
        self.sizeFloorLabel.text = [NSString stringWithFormat:@"%@㎡ | %@层", detail.houseInfo.acreage, detail.houseInfo.floor];////平米/楼层
        self.addressLabel.text = detail.buildInfo.address;//地址
        self.moneyLabel.text = [NSString stringWithFormat:@"%@", detail.houseInfo.price];//租金

        if ([detail.houseInfo.commission isEqualToString:@""] || (detail.houseInfo.commission == nil) ) {
            //self.serverMoneyLabel.hidden = YES;//佣金
            self.serverMoneyLabel.hidden = YES;
        } else {
            self.serverMoneyLabel.text = [NSString stringWithFormat:@"%@", detail.houseInfo.commission];//佣金
        }
        self.phoneField.text = [GlobalConfigClass shareMySingle].userAndTokenModel.mobile;
    } failure:^(id response) {
        [self showHint:response];
    }];
}

//预约房间
- (void)orderFYServiceHouse{
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
    
    __weak typeof(self) weakSelf = self;
    [HomeNetworkService orderFYServiceHouse:[self.detailModel.houseInfo.houseId integerValue] contact:self.nameField.text contactNumber:self.phoneField.text message:self.myTextView.text subscribeTime:self.timeField.text success:^(NSInteger code) {
        [weakSelf showHint:@"预约成功"];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(id response) {
        [weakSelf showHint:response];
    }];
}

@end
