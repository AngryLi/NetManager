//
//  AGLNetManager.h
//  HuZhuYingYong
//
//  Created by 李亚洲 on 16/2/20.
//  Copyright © 2016年 angryli. All rights reserved.
//

#import "AGLNetRequestConfiguration.h"

@protocol AGLBaseRequestAPIDelegate;

typedef NS_ENUM(NSInteger, NetworkReachabilityStatus) {
	NetworkReachabilityStatusUnknown          = -1,
	NetworkReachabilityStatusNotReachable     = 0,
	NetworkReachabilityStatusReachableViaWWAN = 1,
	NetworkReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface AGLNetManager : NSObject

@property (nonatomic, strong) AGLNetRequestConfiguration *configuration;

@property (class, strong, readonly) AGLNetManager *defaultManager;

+ (void)startWithAPI:(kRequestGetAPIBolck _Nonnull)getApi withNext:(nullable kRequestNextBolck)next withSucess:(kRequestSucessBolck _Nonnull)sucess;
///**
// *  不是纯获取数据的接口用这个
// */
+ (void)startWithAPI:(kRequestGetAPIBolck _Nonnull)getApi withNext:(nullable kRequestNextBolck)next withSucess:(kRequestSucessBolck _Nonnull)sucess withError:(kRequestErrorBolck _Nullable)error withFailture:(kRequestFailureBolck _Nullable)failure;

+ (void)startMonitoringReachabilityStatusChangeBlock:(nullable void (^)(NetworkReachabilityStatus lastStatus, NetworkReachabilityStatus currentStatus))block;
+ (void)stopMonitoring;
+ (void)getReachableBlock:(nullable void (^)(BOOL status))block;

@end

NS_ASSUME_NONNULL_END
