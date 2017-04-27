//
//  AGLNetRequestConfiguration.m
//  Ear.FM
//
//  Created by 李亚洲 on 16/5/15.
//  Copyright © 2016年 Edison. All rights reserved.
//

#import "AGLNetRequestConfiguration.h"

@implementation AGLNetRequestConfiguration

static AGLNetRequestConfiguration *_configuration;

+ (AGLNetRequestConfiguration *)defaultConfiguration {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _configuration = [[self alloc] init];
    });
    return _configuration;
}

@end
