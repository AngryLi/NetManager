//
//  AGLNetManager.m
//  HuZhuYingYong
//
//  Created by 李亚洲 on 16/2/20.
//  Copyright © 2016年 angryli. All rights reserved.
//

#import "AGLNetManager.h"

#import "AGLBaseRequestAPIDelegate.h"

@import AFNetworking;

@interface AGLNetManager ()

@property (strong, nonatomic) AFHTTPSessionManager *httpSessionManager;
@property (strong, nonatomic) AFURLSessionManager  *urlSessionManager;
@property (strong, nonatomic) AFNetworkReachabilityManager  *reachabilityManager;
@property (assign, nonatomic) NetworkReachabilityStatus currentStatus;

@end

@implementation AGLNetManager

+ (AGLNetManager *)defaultManager {
    static AGLNetManager *_netManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _netManager = [[self alloc] init];
        _netManager.currentStatus = NetworkReachabilityStatusUnknown;
    });
    return _netManager;
}

- (void)_configManagerWith {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.httpSessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:self.configuration.baseUrl] sessionConfiguration:config];
        self.urlSessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        
        self.httpSessionManager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
        self.httpSessionManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
        
        self.urlSessionManager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
		
		self.reachabilityManager = [AFNetworkReachabilityManager managerForDomain:self.configuration.baseUrl];
    });
}

+(void)startWithAPI:(kRequestGetAPIBolck)getApi withNext:(kRequestNextBolck)next withSucess:(kRequestSucessBolck)sucess{
    [self startWithAPI:getApi withNext:next withSucess:sucess withError:nil withFailture:nil];
}

+ (void)startWithAPI:(kRequestGetAPIBolck)getApi withNext:(kRequestNextBolck)next withSucess:(kRequestSucessBolck)sucess withError:(kRequestErrorBolck)error withFailture:(kRequestFailureBolck)failure {
    [self.defaultManager starWithAPI:getApi withNext:next withSucess:sucess withError:error withFailture:failure];
}
+ (void)startMonitoringReachabilityStatusChangeBlock:(void (^)(NetworkReachabilityStatus, NetworkReachabilityStatus))block {
	if (block) {
		[self.defaultManager startMonitoringReachabilityStatusChangeBlock:block];
	}
}

+ (void)stopMonitoring {
	[self.defaultManager.reachabilityManager stopMonitoring];
}

+ (void)getReachableBlock:(void (^)(BOOL))block {
	if (block) {
		[self.defaultManager getReachableBlock:block];
	}
}

- (void)startMonitoringReachabilityStatusChangeBlock:(void (^)(NetworkReachabilityStatus, NetworkReachabilityStatus))block {
	[self _configManagerWith];
	[self.reachabilityManager startMonitoring];
    __weak __typeof(self) weakSelf = self;
	[self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
		block((NSInteger)weakSelf.currentStatus, (NSInteger)status);
        weakSelf.currentStatus = (NSInteger)status;
	}];
}

- (void)getReachableBlock:(void (^)(BOOL))block {
	block(self.reachabilityManager.reachable);
}

- (void)starWithAPI:(nonnull kRequestGetAPIBolck)getApi withNext:(nullable kRequestNextBolck)next withSucess:(nonnull kRequestSucessBolck)sucess withError:(nullable kRequestErrorBolck)error withFailture:(nullable kRequestFailureBolck)failure {
    [self _configManagerWith];
    id<AGLBaseRequestAPIDelegate> api = getApi();
    NSAssert([api conformsToProtocol:@protocol(AGLBaseRequestAPIDelegate)], @"接口要实现BaseRequestAPIDelegate接口");
    
    kRequestSucessBolck _sucessBlock = sucess ? : self.configuration.defultSucessBlock;
    kRequestNextBolck _nextBlock = next ? : self.configuration.defultNextBlock;
    kRequestErrorBolck _errorBlock = error ? : self.configuration.defultErrorBlock;
    kRequestFailureBolck _failureBlock = failure ? : self.configuration.defultFailureBlock;
    KCustomErrorHandler _customError = self.configuration.customErrorHandler ? : ^(NSDictionary * dictData, kCustomErrorHanderResult result) {
        result(YES, 1, nil);
    };
    
    void(^completeHander)(BOOL, NSURLSessionDataTask *, NSDictionary *, NSError *) = [^(BOOL requestSucess, NSURLSessionDataTask *task, NSDictionary *responseDict, NSError *error) {
		if (_nextBlock) _nextBlock();
        NSInteger statusCode = 0;
        NSString *errorString = @"服务器错误";
        if (requestSucess) {
            if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
            }
            if (statusCode == 200) {
                _customError(responseDict, ^(BOOL noError, NSInteger errorCode, NSString * errorMsg) {
                    if (noError) {
                        if (_sucessBlock) _sucessBlock(responseDict);
                    } else {
                        if (_errorBlock) _errorBlock(errorCode, errorMsg);
                    }
                });
            } else {
                if (_failureBlock) _failureBlock(statusCode, errorString);
            }
        } else {
            if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) statusCode = ((NSHTTPURLResponse *)task.response).statusCode;
            if (error) errorString = error.localizedDescription;
            if (_failureBlock) _failureBlock(statusCode, errorString);
        }
    } copy];
    
    kHttpMethod method = [api respondsToSelector:@selector(httpMehod)] ? [api httpMehod] : kHttpMethodGET;
    NSString *requestUrl = [api respondsToSelector:@selector(requestUrl)] ? [api requestUrl] : nil;
    NSDictionary *parameters = [api respondsToSelector:@selector(requestParameters)] ? [api requestParameters] : nil;
    NSDictionary *httpHeaderField = [api respondsToSelector:@selector(httpHeaderField)] ?[api httpHeaderField]:nil;
    
    [httpHeaderField enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.httpSessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    if (AGLNetRequestConfiguration.defaultConfiguration.communalParameters) {
        if (parameters == nil) {
            parameters = AGLNetRequestConfiguration.defaultConfiguration.communalParameters;
        } else {
            
            NSMutableDictionary *mParameters = [parameters mutableCopy];
            
            [mParameters addEntriesFromDictionary:AGLNetRequestConfiguration.defaultConfiguration.communalParameters];
            
            parameters = [mParameters copy];
        }
    }
    
//    DDLogInfo(@"API请求:\n%@\n%@\n%@", api, requestUrl, parameters);
	
    switch (method) {
        case kHttpMethodGET: {
            [_httpSessionManager GET:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completeHander(YES, task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completeHander(NO, task, nil, error);
            }];
            break;
        }
        case kHttpMethodPOST: {
            [_httpSessionManager POST:requestUrl parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completeHander(YES, task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completeHander(NO, task, nil, error);
            }];
            break;
        }
        case kHttpMethodPUT: {
            [_httpSessionManager PUT:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completeHander(YES, task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completeHander(NO, task, nil, error);
            }];
            break;
        }
        case kHttpMethodDELETE: {
            [_httpSessionManager DELETE:requestUrl parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                completeHander(YES, task, responseObject, nil);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                completeHander(NO, task, nil, error);
            }];
            break;
        }
    }
}




@end
