//
//  AGLBaseRequestAPIDelegate.h
//  HuZhuYingYong
//
//  Created by 李亚洲 on 16/3/18.
//  Copyright © 2016年 angryli. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, kHttpMethod) {
    kHttpMethodGET = 0,
    kHttpMethodPOST,
    kHttpMethodPUT,
    kHttpMethodDELETE
};

@protocol AGLBaseRequestAPIDelegate <NSObject>

- (nonnull NSString *)requestUrl;
- (nullable NSDictionary *)requestParameters;
- (kHttpMethod)httpMehod;

@optional
- (nullable NSDictionary *)httpHeaderField;
@end



