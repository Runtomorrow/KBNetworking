//
//  KBNetworkManager.h
//  KBNetworking
//
//  Created by kobe on 2017/4/19.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBConst.h"
NS_ASSUME_NONNULL_BEGIN
@class KBNetworkManagerConfig;


@interface KBNetworkManager : NSObject
@property (nonatomic, copy, nullable ,readonly) NSString *generalServer;
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary<NSString *, id> *generalParameters;
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary<NSString *, NSString *> *generalHeaders;
@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;
@property (nonatomic, assign) BOOL consoleLog;


+ (instancetype)center;
+ (instancetype)defaultCenter;
- (void)setupConfig:(void(^)(KBNetworkManagerConfig *config))block;
- (void)setResponseProcessBlock:(KBCenterResponseProgressBlock)block;


/**
 SendRequest

 @param configBlock KBRequestConfigBlock
 @return A identiifer of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock;


/**
 SendRequest

 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onSuccess:(nullable KBSuccessBlock)successBlock;

/**
 SendRequest

 @param configBlock KBRequestConfigBlock
 @param failureBlock KBFailureBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onFailure:(nullable KBFailureBlock)failureBlock;

/**
 SendRequest

 @param configBlock   KBRequestConfigBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;


/**
 SendRequest

 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @param failureBlock KBFailureBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock;


/**
 SendRequest

 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @param failureBlock KBFailureBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;


/**
 SendRequest

 @param configBlock   KBRequestConfigBlock
 @param progressBlock KBProgressBlock
 @param successBlock  KBSuccessBlock
 @param failureBlock  KBFailureBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(nullable KBProgressBlock)progressBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock;


/**
 SendRequest

 @param configBlock   KBRequestConfigBlock
 @param progressBlock KBProgressBlock
 @param successBlock  KBSuccessBlock
 @param failureBlock  KBFailureBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(nullable KBProgressBlock)progressBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;


/**
 Send BatchRequest

 @param configBlock  KBBatchRequestConfigBlock
 @param successBlock KBBatchSuccessBlock
 @param failureBlock KBBatchFailureBlock
 @param finishedBlock KBBatchFinishedBlock
 @return KBBatchRequest
 */
- (nullable KBBatchRequest *)sendBatchRequest:(KBBatchRequestConfigBlock)configBlock
                                    onSuccess:(nullable KBBatchSuccessBlock)successBlock
                                    onFailure:(nullable KBBatchFailureBlock)failureBlock
                                   onFinished:(nullable KBBatchFinishedBlock)finishedBlock;


/**
 
 Send ChainRequest
 
 @param configBlock  KBChainRequestConfigBlock
 @param successBlock KBBatchSuccessBlock
 @param failureBlock KBBatchFailureBlock
 @param finishedBlock KBBatchFinishedBlock
 @return  KBChainRequest
 */
- (nullable KBChainRequest *)sendChainRequest:(KBChainRequestConfigBlock)configBlock
                                    onSuccess:(nullable KBBatchSuccessBlock)successBlock
                                    onFailure:(nullable KBBatchFailureBlock)failureBlock
                                   onFinished:(nullable KBBatchFinishedBlock)finishedBlock;


+ (void)setupConfig:(void(^)(KBNetworkManagerConfig *config))block;
+ (void)setResponseProcessBlock:(KBCenterResponseProgressBlock)block;
+ (void)setGeneralHeaderValue:(nullable NSString *)value forField:(NSString *)field;
+ (void)setGeneralParameterValue:(nullable NSString *)value forKey:(NSString *)key;


/**
 SendRequest
 
 @param configBlock KBRequestConfigBlock
 @return A identiifer of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock;

/**
 SendRequest
 
 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onSuccess:(nullable KBSuccessBlock)successBlock;

/**
 SendRequest
 
 @param configBlock KBRequestConfigBlock
 @param failureBlock KBFailureBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onFailure:(nullable KBFailureBlock)failureBlock;

/**
 SendRequest
 
 @param configBlock   KBRequestConfigBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;

/**
 SendRequest
 
 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @param failureBlock KBFailureBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock;

/**
 SendRequest
 
 @param configBlock  KBRequestConfigBlock
 @param successBlock KBSuccessBlock
 @param failureBlock KBFailureBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;

/**
 SendRequest
 
 @param configBlock   KBRequestConfigBlock
 @param progressBlock KBProgressBlock
 @param successBlock  KBSuccessBlock
 @param failureBlock  KBFailureBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(nullable KBProgressBlock)progressBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock;

/**
 SendRequest
 
 @param configBlock   KBRequestConfigBlock
 @param progressBlock KBProgressBlock
 @param successBlock  KBSuccessBlock
 @param failureBlock  KBFailureBlock
 @param finishedBlock KBFinishedBlock
 @return A identifier of Request
 */
+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(nullable KBProgressBlock)progressBlock
                onSuccess:(nullable KBSuccessBlock)successBlock
                onFailure:(nullable KBFailureBlock)failureBlock
               onFinished:(nullable KBFinishedBlock)finishedBlock;


/**
 Send BatchRequest
 
 @param configBlock  KBBatchRequestConfigBlock
 @param successBlock KBBatchSuccessBlock
 @param failureBlock KBBatchFailureBlock
 @param finishedBlock KBBatchFinishedBlock
 @return KBBatchRequest
 */
+ (nullable KBBatchRequest *)sendBatchRequest:(KBBatchRequestConfigBlock)configBlock
                                    onSuccess:(nullable KBBatchSuccessBlock)successBlock
                                    onFailure:(nullable KBBatchFailureBlock)failureBlock
                                   onFinished:(nullable KBBatchFinishedBlock)finishedBlock;


/**
 
 Send ChainRequest
 
 @param configBlock  KBChainRequestConfigBlock
 @param successBlock KBBatchSuccessBlock
 @param failureBlock KBBatchFailureBlock
 @param finishedBlock KBBatchFinishedBlock
 @return  KBChainRequest
 */
+ (nullable KBChainRequest *)sendChainRequest:(KBChainRequestConfigBlock)configBlock
                                    onSuccess:(nullable KBBatchSuccessBlock)successBlock
                                    onFailure:(nullable KBBatchFailureBlock)failureBlock
                                   onFinished:(nullable KBBatchFinishedBlock)finishedBlock;

/**
 Cancel Request

 @param identifier identifier
 */
+ (void)cancelRequest:(NSUInteger)identifier;


/**
 Cancel Request

 @param identifier identifier
 @param cancelBlock callback block
 */
+ (void)cancelRequest:(NSUInteger)identifier
             onCancel:(nullable KBCancelBlock)cancelBlock;


/**
 Get Request With Identifier

 @param identifier Identifier
 @return kBRequest
 */
+ (nullable KBRequest *)getRequest:(NSUInteger)identifier;


/**
 Network Status

 @return YES OR NO
 */
+ (BOOL)isNetworkReachable;

@end

@interface KBNetworkManagerConfig : NSObject
@property (nonatomic, copy, nullable) NSString *generalServer;       ///< Server
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *generalParameters;  ///< Params
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *generalHeaders;  ///< Headers
@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;       ///<queue
@property (nonatomic, assign) BOOL consoleLog;
@end

NS_ASSUME_NONNULL_END
