//
//  CJMenuCommonCell.m
//  Building
//
//  Created by Macbook Pro on 2019/2/10.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "CJMenuCommonCell.h"

@interface CJMenuCommonCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CJMenuCommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - setters
- (void)setProvinceModel:(FYProvinceModel *)provinceModel{
    _provinceModel = provinceModel;
    
    self.titleLabel.text = provinceModel.provinceName;
    if (provinceModel.isSelect) {
        self.backgroundColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xf3f3f3);
    }
}

- (void)setCityModel:(FYCityModel *)cityModel{
    _cityModel = cityModel;
    
    self.titleLabel.text = cityModel.cityName;
    if (cityModel.isSelect) {
        self.backgroundColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xf3f3f3);
    }
}

- (void)setShangQuanOneLevelModel:(FYShangQuanOneLevelModel *)shangQuanOneLevelModel{
    _shangQuanOneLevelModel = shangQuanOneLevelModel;
    
    self.titleLabel.text = shangQuanOneLevelModel.titleName;
    if (shangQuanOneLevelModel.isSelect) {
        self.backgroundColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xf3f3f3);
    }
}

-(void)setShangQuanCountryModel:(FYShangQuanCountryModel *)shangQuanCountryModel{
    _shangQuanCountryModel = shangQuanCountryModel;
    
    self.titleLabel.text = shangQuanCountryModel.countryName;
    if (shangQuanCountryModel.isSelect) {
        self.backgroundColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xf3f3f3);
    }
}

- (void)setShangQuanTradingModel:(FYShangQuanTradingModel *)shangQuanTradingModel{
    _shangQuanTradingModel = shangQuanTradingModel;
    
    self.titleLabel.text = shangQuanTradingModel.tradingName;
    if (shangQuanTradingModel.isSelect) {
        self.backgroundColor = UIColorFromHEX(0xffffff);
    } else {
        self.backgroundColor = UIColorFromHEX(0xf3f3f3);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
