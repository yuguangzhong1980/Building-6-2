//
//  ServiceBuyView.m
//  Building
//
//  Created by Macbook Pro on 2019/2/14.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "ServiceBuyView.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ServiceBuyView()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *dataView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *choiceButtons;
@property (weak, nonatomic) IBOutlet UIButton *jianshaoButton;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;

@property (assign, nonatomic) NSInteger currentBtnIndex;
@property (assign, nonatomic) float currentPrice;

@end

@implementation ServiceBuyView

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self = [[[UINib nibWithNibName:NSStringFromClass([ServiceBuyView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)commonInit
{
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackCoverViewTapAction:)];
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
    
    self.currentBtnIndex = 0;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.dataView]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - Actions
//cover视图tap响应函数
- (void)blackCoverViewTapAction:(UITapGestureRecognizer *)tapGesture
{
    //    UIView *itemView = tapGesture.view;
    //    NSLog(@"%ld", (long)itemView.tag);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverViewTapAction)]) {
        [self.delegate coverViewTapAction];
    }
}
//选项
- (IBAction)choiceButtonsAction:(id)sender {
    //NSLog(@"choiceButtonsAction");
    NSInteger buttonCount = self.choiceButtons.count > self.detailModel.productSku.skuInfo[0].attrList.count ? self.detailModel.productSku.skuInfo[0].attrList.count : self.choiceButtons.count;
    for (NSInteger i=0; i<buttonCount; i++) {
        UIButton *tempButton = self.choiceButtons[i];
        tempButton.layer.borderColor  = UIColorFromHEX(0xe5e5e5).CGColor;
    }
    UIButton *button = (UIButton *)sender;
    button.layer.borderColor  = UIColorFromHEX(0x9accff).CGColor;
    
    for (ServiceProductSkuInfoAttrModel *item in self.detailModel.productSku.skuInfo[0].attrList) {
        item.isSelect = false;
    }
    self.currentBtnIndex = button.tag - 1;
    ServiceProductSkuInfoAttrModel *attrModel = self.detailModel.productSku.skuInfo[0].attrList[self.currentBtnIndex];
    attrModel.isSelect = true;

    //NSLog(@"currentBtnIndex:%ld", self.currentBtnIndex);

    NSString *currentPriceStr = @"0";
    for (ServiceProductSkuPriceModel *item in self.detailModel.productSku.priceList) {
        if (item.attrIds == attrModel.attrId) {
            currentPriceStr = item.price;
            //NSLog(@"currentPriceStr:%@", currentPriceStr);
            break;
        }
    }
    self.currentPrice = [currentPriceStr floatValue];
    self.moneyLabel.text = currentPriceStr;
    self.countLabel.text = @"1";
}
//增加
- (IBAction)addButtonAction:(id)sender {
    self.countLabel.text = [NSString stringWithFormat:@"%ld", [self.countLabel.text integerValue]+1];
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f", self.currentPrice * [self.countLabel.text integerValue]];
    self.detailModel.productSku.payCount = self.countLabel.text;
    
}
//减少
- (IBAction)jianshaoButtonAction:(id)sender {
    if ([self.countLabel.text integerValue] > 1) {
        self.countLabel.text = [NSString stringWithFormat:@"%ld", [self.countLabel.text integerValue]-1];
        self.moneyLabel.text = [NSString stringWithFormat:@"%.2f", self.currentPrice * [self.countLabel.text integerValue]];
        self.detailModel.productSku.payCount = self.countLabel.text;
    }
}
//购买
- (IBAction)buyButtonAction:(id)sender {
    if( self.currentPrice <= 0 )
    {
        [self showHint:@"不能购买,价格为0元"];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(toPayBtnAction)]) {
        [self.delegate toPayBtnAction];
    }
}

- (void)showHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = [IosDeviceType isIphone_5]?1.f:1.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}
#pragma mark - setters
- (void)setDetailModel:(ServiceDetailModel *)detailModel{
    _detailModel = detailModel;
    
    self.titleLabel.text = detailModel.productSku.skuInfo[0].skuName;
    NSInteger buttonCount = self.choiceButtons.count > detailModel.productSku.skuInfo[0].attrList.count ? detailModel.productSku.skuInfo[0].attrList.count : self.choiceButtons.count;
    for (NSInteger i=0; i<buttonCount; i++) {
        UIButton *tempButton = self.choiceButtons[i];
        ServiceProductSkuInfoAttrModel *attrModel = detailModel.productSku.skuInfo[0].attrList[i];
        
        tempButton.layer.cornerRadius = 4;
        tempButton.layer.borderColor  = UIColorFromHEX(0xe5e5e5).CGColor;
        tempButton.layer.borderWidth  = 1;
        
        [tempButton setTitle:attrModel.attrName forState:UIControlStateNormal];
        tempButton.hidden = NO;
    }
    if (buttonCount > 0) {
        UIButton *tempButton = self.choiceButtons[0];
        tempButton.layer.borderColor  = UIColorFromHEX(0x9accff).CGColor;
        self.currentBtnIndex = 0;
        
        NSString *currentPriceStr = @"0";
        ServiceProductSkuInfoAttrModel *attrModel = detailModel.productSku.skuInfo[0].attrList[self.currentBtnIndex];
        attrModel.isSelect = true;
        for (ServiceProductSkuPriceModel *item in detailModel.productSku.priceList) {
            if (item.attrIds == attrModel.attrId) {
                currentPriceStr = item.price;
                break;
            }
        }
        self.currentPrice = [currentPriceStr floatValue];
        self.moneyLabel.text = currentPriceStr;
        self.countLabel.text = @"1";
        self.detailModel.productSku.payCount = self.countLabel.text;
    }
    
    if (detailModel.productInfo.saleWay == 1) {//售卖方式1购买2预约
        [self.buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
    } else {
        [self.buyButton setTitle:@"立即预约" forState:UIControlStateNormal];
    }
}
@end
