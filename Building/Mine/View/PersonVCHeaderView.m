//
//  PersonVCHeaderView.m
//  Building
//
//  Created by Macbook Pro on 2019/2/14.
//  Copyright © 2019 Macbook Pro. All rights reserved.
//

#import "PersonVCHeaderView.h"

@implementation PersonVCHeaderView

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
        self = [[[UINib nibWithNibName:NSStringFromClass([PersonVCHeaderView class]) bundle:nil] instantiateWithOwner:nil options:nil] firstObject];
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)commonInit
{
}
@end
