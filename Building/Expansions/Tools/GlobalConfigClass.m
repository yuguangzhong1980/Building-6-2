//
//  GlobalConfigClass.m
//  SmartHealth
//
//  Created by Apple on 15/10/10.
//  Copyright (c) 2015年 certus. All rights reserved.
//

#import "GlobalConfigClass.h"

@implementation GlobalConfigClass

static GlobalConfigClass* mysingleClass = nil;

+(GlobalConfigClass *)shareMySingle
{
    static dispatch_once_t onceSingl;
    dispatch_once(&onceSingl, ^{
        
        mysingleClass = [[GlobalConfigClass alloc] init];
        
    });
    return mysingleClass;
    
}


@end
