//
//  AGLNetRequestConfiguration.h
//  Ear.FM
//
//  Created by 李亚洲 on 16/5/15.
//  Copyright © 2016年 Edison. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AGLBaseRequestAPIDelegate;

typedef _Nonnull id<AGLBaseRequestAPIDelegate>(^kRequestGetAPIBolck)();
typedef void(^kRequestNextBolck)();
typedef void(^kRequestSucessBolck)(NSDictionary * _Nullable dictData);
typedef void(^kRequestErrorBolck)(NSInteger errorCode, NSString *errorMsg);
typedef void(^kRequestFailureBolck)(NSInteger statusCode, NSString *reason);
typedef void(^kRequestAllWillBolck)();

typedef void(^kCustomErrorHanderResult)(BOOL, NSInteger,NSString * _Nullable);
typedef void(^KCustomErrorHandler)(NSDictionary *, kCustomErrorHanderResult);

@interface AGLNetRequestConfiguration : NSObject

@property (class, strong, readonly) AGLNetRequestConfiguration *defaultConfiguration;

@property (nonatomic, strong) NSDictionary *communalParameters;
@property (nonatomic, copy) NSString *baseUrl;;

@property (copy, nonatomic) KCustomErrorHandler customErrorHandler;
@property (copy, nonatomic) kRequestNextBolck defultNextBlock;
@property (copy, nonatomic) kRequestSucessBolck defultSucessBlock;
@property (copy, nonatomic) kRequestErrorBolck defultErrorBlock;
@property (copy, nonatomic) kRequestFailureBolck defultFailureBlock;
@end

NS_ASSUME_NONNULL_END
