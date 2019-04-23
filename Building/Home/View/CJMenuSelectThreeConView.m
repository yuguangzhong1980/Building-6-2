//
//  CJMenuSelectThreeConView.m
//  Building
//
//  Created by Macbook Pro on 2019/2/9.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "CJMenuSelectThreeConView.h"
#import "CJMenuCommonCell.h"

#define CJMenuSelectTwoConViewCellHeight       49
#define CJMenuCommonCellXibName                @"CJMenuCommonCell"


@interface CJMenuSelectThreeConView()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (nonatomic, strong) NSArray *leftTableViewArr;
@property (nonatomic, assign) NSInteger leftSelectedRow;


@property (weak, nonatomic) IBOutlet UITableView *centerTableView;
@property (nonatomic, strong) NSArray *centerTableViewArr;
@property (nonatomic, assign) NSInteger centerSelectedRow;

@property (weak, nonatomic) IBOutlet UITableView *rightTableView;
@property (nonatomic, strong) NSArray *rightTableViewArr;

@property (weak, nonatomic) IBOutlet UIView *blackView;
@end


@implementation CJMenuSelectThreeConView

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
        self = [[[UINib nibWithNibName:NSStringFromClass([CJMenuSelectThreeConView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
         [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)commonInit
{
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    self.leftTableView.tableFooterView = [UIView new];
    self.leftTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.centerTableView.delegate = self;
    self.centerTableView.dataSource = self;
    self.centerTableView.tableFooterView = [UIView new];
    self.centerTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;
    self.rightTableView.tableFooterView = [UIView new];
    self.rightTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(blackCoverViewTapAction:)];
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
    
    FYShangQuanOneLevelModel *model1 = [[FYShangQuanOneLevelModel alloc] init];
    model1.titleName = @"不限";
    FYShangQuanOneLevelModel *model2 = [[FYShangQuanOneLevelModel alloc] init];
    model2.titleName = @"商圈";
    FYShangQuanOneLevelModel *model3 = [[FYShangQuanOneLevelModel alloc] init];
    model3.titleName = @"地铁";
    self.leftTableViewArr = @[model1, model2, model3];
    self.leftSelectedRow = -1;//都未选中
    self.centerSelectedRow = -1;//选中第一个
    self.centerTableViewArr = [[NSMutableArray alloc] init];
    self.rightTableViewArr = [[NSMutableArray alloc] init];
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

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.blackView]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UITableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.leftTableView) {//左侧
        return self.leftTableViewArr.count;
    } else if (tableView == self.centerTableView) {
        return self.centerTableViewArr.count;
    } else {
        return self.rightTableViewArr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.leftTableView) {//左侧
        CJMenuCommonCell * cell = [tableView dequeueReusableCellWithIdentifier:CJMenuCommonCellXibName];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:CJMenuCommonCellXibName owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        FYShangQuanOneLevelModel *model = self.leftTableViewArr[indexPath.row];
        cell.shangQuanOneLevelModel = model;
        
        return cell;
    } else if (tableView == self.centerTableView) {
        CJMenuCommonCell * cell = [tableView dequeueReusableCellWithIdentifier:CJMenuCommonCellXibName];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:CJMenuCommonCellXibName owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        FYShangQuanCountryModel *model = self.centerTableViewArr[indexPath.row];
        cell.shangQuanCountryModel = model;
        
        return cell;
    } else {
        CJMenuCommonCell * cell = [tableView dequeueReusableCellWithIdentifier:CJMenuCommonCellXibName];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:CJMenuCommonCellXibName owner:nil options:nil][0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        FYShangQuanTradingModel *model = self.rightTableViewArr[indexPath.row];
        cell.shangQuanTradingModel = model;
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CJMenuSelectTwoConViewCellHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger row = [indexPath row];
    if (tableView == self.leftTableView) {//左侧
        if (self.leftSelectedRow == row) {//选中了当前行，什么也不用做
            return;
        }
        
        for (FYShangQuanOneLevelModel *model in self.leftTableViewArr) {
            model.isSelect = NO;
        }
        
        FYShangQuanOneLevelModel *model = self.leftTableViewArr[row];
        model.isSelect = YES;
        self.leftSelectedRow = row;
        if (0 == row) {//不限
            if (self.delegate && [self.delegate respondsToSelector:@selector(doneSelectBuXian)]) {
                [self.delegate doneSelectBuXian];
            }
        } else if (1 == row) {//商圈
            self.centerTableViewArr = self.currentCityModel.countryInfoList;
//            FYShangQuanCountryModel *countryModel = self.centerTableViewArr[self.centerSelectedRow];
            self.rightTableViewArr = [[NSMutableArray alloc] init];
            
            [self.leftTableView reloadData];
            [self.centerTableView reloadData];
            [self.rightTableView reloadData];
        } else {//地铁
            self.centerTableViewArr = self.currentCityModel.metroList;
            self.rightTableViewArr = [[NSMutableArray alloc] init];
            
            [self.leftTableView reloadData];
            [self.centerTableView reloadData];
            [self.rightTableView reloadData];
        }
    } else if (tableView == self.centerTableView) {
        if (self.leftSelectedRow == 0) {//不限
            
        } else if (self.leftSelectedRow == 1) {//商圈
            for (FYShangQuanCountryModel *model in self.centerTableViewArr) {
                model.isSelect = NO;
            }
            
            FYShangQuanCountryModel *model = self.centerTableViewArr[row];
            model.isSelect = YES;
            self.centerSelectedRow = row;
            self.rightTableViewArr = model.tradingInfoList;
            
            [self.leftTableView reloadData];
            [self.centerTableView reloadData];
            [self.rightTableView reloadData];
        } else {//地铁
            if (self.delegate && [self.delegate respondsToSelector:@selector(doneSelectMeroRow:)]) {
                [self.delegate doneSelectMeroRow:row];
            }
        }
    } else {
        FYShangQuanTradingModel *model = self.rightTableViewArr[row];
        if (self.delegate && [self.delegate respondsToSelector:@selector(doneSelectTradingId:)]) {
            [self.delegate doneSelectTradingId:[model.tradingId integerValue]];
        }
    }
}

#pragma mark - Private

- (void)setCurrentCityModel:(FYShangQuanCityModel *)currentCityModel{
    _currentCityModel = currentCityModel;
    
    [self.leftTableView reloadData];
    [self.centerTableView reloadData];
    [self.rightTableView reloadData];
}

- (void)showView{
    self.hidden = NO;
}

- (void)hiddenView{
    self.hidden = YES;
}
@end
