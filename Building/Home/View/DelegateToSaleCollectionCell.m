//
//  DelegateToSaleCollectionCell.m
//  Building
//
//  Created by Macbook Pro on 2019/2/16.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "DelegateToSaleCollectionCell.h"


@interface DelegateToSaleCollectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end


@implementation DelegateToSaleCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
#pragma mark - setters
- (void)setHouseModel:(DelegateHouseModel *)houseModel{
    _houseModel = houseModel;
    
    if (houseModel.isSelect) {//选中
        self.backgroundColor = UIColorFromHEX(0x73b8fd);
        self.titleLabel.tintColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xffffff);
        self.titleLabel.tintColor = UIColorFromHEX(0x6e6e6e);
    }
    self.titleLabel.text = houseModel.houseName;
}

@end
