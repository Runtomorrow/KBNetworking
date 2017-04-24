//
//  KBNetworkManager.m
//  KBNetworking
//
//  Created by kobe on 2017/4/19.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "KBNetworkManager.h"
#import "KBRequest.h"
#import "KBAFNetworkEngine.h"


@interface KBNetworkManager ()
@property (nonatomic, copy, nullable, readwrite) NSString *generalServer;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, id> *generalParameters;
@property (nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSString *> *generalHeaders;
@property (nonatomic, copy) KBCenterResponseProgressBlock responseProcessHandler;
@end

@implementation KBNetworkManager

+ (instancetype)center{
    return [[[self class] alloc] init];
}

+ (instancetype)defaultCenter{
    static id shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [self center];
    });
    return shareInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setupConfig:(void (^)(KBNetworkManagerConfig * _Nonnull))block{
    KBNetworkManagerConfig *config = [[KBNetworkManagerConfig alloc] init];
    config.consoleLog = NO;
    KB_SAFE_BLOCK(block, config);
    if (config.generalServer) {
        self.generalServer = config.generalServer;
    }
    if (config.generalParameters.count > 0) {
        [self.generalParameters addEntriesFromDictionary:config.generalParameters];
    }
    if (config.generalHeaders.count > 0) {
        [self.generalHeaders addEntriesFromDictionary:config.generalHeaders];
    }
    
    if (config.callbackQueue != NULL) {
        self.callbackQueue = config.callbackQueue;
    }
    
    if (config.generalUserInfo) {
        self.generalUserInfo = config.generalUserInfo;
    }
    
    self.consoleLog = config.consoleLog;
}

- (void)setResponseProcessBlock:(KBCenterResponseProgressBlock)block{
    self.responseProcessHandler = block;
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:nil
                   onFailure:nil
                  onFinished:nil];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:successBlock
                   onFailure:nil
                  onFinished:nil];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:nil
                   onFailure:failureBlock
                  onFinished:nil];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:nil
                   onFailure:nil
                  onFinished:finishedBlock];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:successBlock
                   onFailure:failureBlock
                  onFinished:nil];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:successBlock
                   onFailure:failureBlock
                  onFinished:finishedBlock];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(KBProgressBlock)progressBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [self sendRequest:configBlock
                  onProgress:nil
                   onSuccess:successBlock
                   onFailure:failureBlock
                  onFinished:nil];
}

- (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(KBProgressBlock)progressBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    KBRequest *request = [KBRequest request];
    
    KB_SAFE_BLOCK(configBlock, request);
    [self kb_progressRequest:request
                  onProgress:progressBlock
                   onSuccess:successBlock
                   onFailure:failureBlock
                  onFinished:finishedBlock];
    return [self kb_sendRequest:request];
}


- (KBBatchRequest *)sendBatchRequest:(KBBatchRequestConfigBlock)configBlock
                           onSuccess:(nullable KBBatchSuccessBlock)successBlock
                           onFailure:(nullable KBBatchFailureBlock)failureBlock
                          onFinished:(nullable KBBatchFinishedBlock)finishedBlock{
    KBBatchRequest *batchRequest = [[KBBatchRequest alloc] init];
    KB_SAFE_BLOCK(configBlock, batchRequest);
    if (batchRequest.requestArray.count > 0) {
        if (successBlock) {
            [batchRequest setValue:successBlock forKey:@"_batchSuccessBlock"];
        }
        if (failureBlock) {
            [batchRequest setValue:failureBlock forKey:@"_batchFailureBlock"];
        }
        if (finishedBlock) {
            [batchRequest setValue:finishedBlock forKey:@"_batchFinishedBlock"];
        }
        [batchRequest.responseArray removeAllObjects];
        
        for (KBRequest *request in batchRequest.requestArray) {
            [batchRequest.responseArray addObject:[NSNull null]];
            [self kb_progressRequest:request
                          onProgress:nil
                           onSuccess:nil
                           onFailure:nil
                          onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
                              
                [batchRequest onFinishedOneRequest:request response:responseObject error:error];
                
            }];
            [self kb_sendRequest:request];
        }
        return batchRequest;
        
    }else{
        return nil;
    }
}

- (KBChainRequest *)sendChainRequest:(KBChainRequestConfigBlock)configBlock
                           onSuccess:(nullable KBBatchSuccessBlock)successBlock
                           onFailure:(nullable KBBatchFailureBlock)failureBlock
                          onFinished:(nullable KBBatchFinishedBlock)finishedBlock{
    KBChainRequest *chainRequest = [[KBChainRequest alloc] init];
    KB_SAFE_BLOCK(configBlock,chainRequest);
    if (chainRequest.firstRequest) {
        if (successBlock) {
            [chainRequest setValue:successBlock forKey:@"_chainSuccessBlock"];
        }
        if (failureBlock) {
            [chainRequest setValue:failureBlock forKey:@"_chainFailureBlock"];
        }
        if (finishedBlock) {
            [chainRequest setValue:finishedBlock forKey:@"_chainFinishedBlock"];
        }
        [self kb_sendChainRequest:chainRequest withRequest:chainRequest.firstRequest];
        return chainRequest;
    }else{
        return nil;
    }
}

+ (void)setupConfig:(void (^)(KBNetworkManagerConfig * _Nonnull))block{
    [[KBNetworkManager defaultCenter] setupConfig:block];
}

+ (void)setResponseProcessBlock:(KBCenterResponseProgressBlock)block{
    [[KBNetworkManager defaultCenter] setResponseProcessBlock:block];
}

+ (void)setGeneralHeaderValue:(NSString *)value
                     forField:(NSString *)field{
    [[KBNetworkManager defaultCenter].generalParameters setValue:value forKey:field];
}

+ (void)setGeneralParameterValue:(NSString *)value
                          forKey:(NSString *)key{
    [[KBNetworkManager defaultCenter].generalParameters setValue:value forKey:key];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:nil onFailure:nil onFinished:nil];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:successBlock onFailure:nil onFinished:nil];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:nil onFailure:failureBlock onFinished:nil];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:nil onFailure:nil onFinished:finishedBlock];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:successBlock onFailure:failureBlock onFinished:nil];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onSuccess:successBlock onFailure:failureBlock onFinished:finishedBlock];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(KBProgressBlock)progressBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onProgress:progressBlock onSuccess:successBlock onFailure:failureBlock onFinished:nil];
}

+ (NSUInteger)sendRequest:(KBRequestConfigBlock)configBlock
               onProgress:(KBProgressBlock)progressBlock
                onSuccess:(KBSuccessBlock)successBlock
                onFailure:(KBFailureBlock)failureBlock
               onFinished:(KBFinishedBlock)finishedBlock{
    return [[KBNetworkManager defaultCenter] sendRequest:configBlock onProgress:progressBlock onSuccess:successBlock onFailure:failureBlock onFinished:finishedBlock];
}

+ (KBBatchRequest *)sendBatchRequest:(KBBatchRequestConfigBlock)configBlock
                           onSuccess:(KBBatchSuccessBlock)successBlock
                           onFailure:(KBBatchFailureBlock)failureBlock
                          onFinished:(KBBatchFinishedBlock)finishedBlock{
    return [[KBNetworkManager defaultCenter] sendBatchRequest:configBlock onSuccess:successBlock onFailure:failureBlock onFinished:finishedBlock];
}

+ (KBChainRequest *)sendChainRequest:(KBChainRequestConfigBlock)configBlock
                           onSuccess:(KBBatchSuccessBlock)successBlock
                           onFailure:(KBBatchFailureBlock)failureBlock
                          onFinished:(KBBatchFinishedBlock)finishedBlock{
    return [[KBNetworkManager defaultCenter] sendChainRequest:configBlock onSuccess:successBlock onFailure:failureBlock onFinished:finishedBlock];
}

+ (void)cancelRequest:(NSUInteger)identifier{
    [self cancelRequest:identifier onCancel:nil];
}

+ (void)cancelRequest:(NSUInteger)identifier
             onCancel:(KBCancelBlock)cancelBlock{
    KBRequest *request = [[KBAFNetworkEngine shareEngine] cancelRequestByIdentifier:identifier];
    KB_SAFE_BLOCK(cancelBlock, request);
}

+ (nullable KBRequest *)getRequest:(NSUInteger)identifier{
    return [[KBAFNetworkEngine shareEngine] getRequestByIdentifier:identifier];
}

+ (BOOL)isNetworkReachable{
    return [KBAFNetworkEngine shareEngine].networkReachability != 0;
}


#pragma mark <Private Method>
- (void)kb_sendChainRequest:(KBChainRequest *)chainRequest
                withRequest:(KBRequest *)request{
    __weak __typeof(self)weakSelf = self;
    [self kb_progressRequest:request
                  onProgress:nil
                   onSuccess:nil
                   onFailure:nil
                  onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [chainRequest onFinishedOneRequest:request
                                  response:responseObject
                                     error:error];
        if (chainRequest.nextRequest) {
            [strongSelf kb_sendChainRequest:chainRequest withRequest:chainRequest.nextRequest];
        }
    }];
    [self kb_sendRequest:request];
}


/**
 Send A Request

 @param request KBRequest
 @return identifier
 */
- (NSUInteger)kb_sendRequest:(KBRequest *)request{
    if (self.consoleLog) {
        if (request.requestType == KBRequestDownload) {
            NSLog(@"\n================ [KBRequest Info] ==============\n request download url: %@\n request save path: %@\n request headers: \n%@ \n request parameters: \n%@ \n===============================================\n",request.url,request.downloadSavePath,request.headers, request.parameters);
        }else{
            NSLog(@"\n ================ [KBRequest Info] ==============\n request url: %@ \n request headers:\n%@ \n request parameters: \n%@ \n ======================================\n",request.url, request.headers, request.parameters);
        }
    }
    
    return [[KBAFNetworkEngine shareEngine] sendRequest:request
                                      completionHandler:^(id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            [self kb_failureWithError:error forRequest:request];
        }else{
            [self kb_successWithResponse:responseObject forRequest:request];
        }
    }];
}


/**
 Deal Response

 @param request KBRequest
 @param progressBlock ProgressBlock
 @param successBlock SuccessBlock
 @param failureBlock FailureBlock
 @param finishedBlock FinishBlock
 */
- (void)kb_progressRequest:(KBRequest *)request
                onProgress:(KBProgressBlock)progressBlock
                 onSuccess:(KBSuccessBlock)successBlock
                 onFailure:(KBFailureBlock)failureBlock
                onFinished:(KBFinishedBlock)finishedBlock{
    if (successBlock) {
        [request setValue:successBlock forKey:@"_successBlock"];
    }
    if (failureBlock) {
        [request setValue:failureBlock forKey:@"_failureBlock"];
    }
    if (finishedBlock) {
        [request setValue:finishedBlock forKey:@"_finishedBlock"];
    }
    if (progressBlock && request.requestType != KBRequestNormal) {
        [request setValue:progressBlock forKey:@"_progressBlock"];
    }
    
    if (!request.userInfo && self.generalUserInfo) {
        request.userInfo = self.generalUserInfo;
    }
    
    if (request.useGeneralParameters && self.generalParameters.count > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters addEntriesFromDictionary:self.generalParameters];
        if (request.parameters.count > 0) {
            [parameters addEntriesFromDictionary:request.parameters];
        }
        request.parameters = parameters;
    }
    
    if (request.useGeneralHeaders && self.generalHeaders.count > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [headers addEntriesFromDictionary:self.generalHeaders];
        if (request.headers) {
            [headers addEntriesFromDictionary:request.headers];
        }
        request.headers = headers;
    }
    
    // 处理URL
    if (request.url.length == 0) {
        //如果Request没有配置则在KBNetworkManager配置
        if (request.server.length == 0 && request.useGeneralServer && self.generalServer.length > 0) {
            request.server = self.generalServer;
        }
        //如果有请求API
        if (request.api.length > 0) {
            NSURL *baseURL = [NSURL URLWithString:request.server];
            // 获取完成的路径并且是以/结束的
            if ([[baseURL path] length] > 0 && [[baseURL absoluteString] hasSuffix:@"/"]) {
                baseURL = [baseURL URLByAppendingPathComponent:@""];
            }
            request.url = [[NSURL URLWithString:request.api relativeToURL:baseURL] absoluteString];
        }else{
            request.url = request.server;
        }
    }
    NSAssert(request.url.length > 0, @"The request url can't be null.");
}


- (void)kb_successWithResponse:(id)responseObject
                    forRequest:(KBRequest *)request{
    //此处代码可以省略
    NSError *processError = nil;
    KB_SAFE_BLOCK(self.responseProcessHandler, request, responseObject, &processError);
    if (processError) {
        [self kb_failureWithError:processError forRequest:request];
        return;
    }
    
    if (self.consoleLog) {
        if (request.requestType == KBRequestDownload) {
            NSLog(@"\n======================== [KBResponse Data] ==========================\n request download url: %@\n response data: %@\n======================================\n",request.url, responseObject);
        }else{
            if (request.responseSerializerType == KBResponseSerializerRAW) {
                NSLog(@"\n===================== [KBResponse Data] ==============\n request url: %@\n response data:\n%@\n============================\n",request.url, [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding]);
            }else{
                NSLog(@"\n====================== [KBResponse Data] ================\n request url: %@\n response data:\n%@\n===============================\n",request.url,responseObject);
            }
        }
    }
    if (self.callbackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.callbackQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf kb_execureSuccessBlockWithResponse:responseObject
                                                forRequest:request];
        });
    }else{
        [self kb_execureSuccessBlockWithResponse:responseObject
                                      forRequest:request];
    }
}

- (void)kb_failureWithError:(NSError *)error
                 forRequest:(KBRequest *)request{
    if (self.consoleLog) {
        NSLog(@"\n==================== [KBResponse Error] =====================\n request url: %@ \n error info:\n%@\n============================================\n",request.url, error);
    }
    
    //retry again
    if (request.retryCount > 0) {
        request.retryCount -- ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self kb_sendRequest:request];
        });
        return;
    }
    // 异步处理
    if (self.callbackQueue) {
        __weak __typeof(self)weakSelf = self;
        dispatch_async(self.callbackQueue, ^{
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            [strongSelf kb_execureFailureBlockWithError:error forRequest:request];
        });
    }else{
        [self kb_execureFailureBlockWithError:error forRequest:request];
    }
}

- (void)kb_execureSuccessBlockWithResponse:(id)responseObject
                                forRequest:(KBRequest *)request{
    
    KB_SAFE_BLOCK(request.successBlock, responseObject);
    KB_SAFE_BLOCK(request.finishedBlock, responseObject , nil);
    [request cleanCallbackBlocks];
}


- (void)kb_execureFailureBlockWithError:(NSError *)error
                             forRequest:(KBRequest *)request{
    
    KB_SAFE_BLOCK(request.failureBlock, error);
    KB_SAFE_BLOCK(request.finishedBlock, nil, error);
    [request cleanCallbackBlocks];
}

- (NSMutableDictionary<NSString *,id> *)generalParameters{
    if (!_generalParameters) {
        _generalParameters = [NSMutableDictionary dictionary];
    }
    return _generalParameters;
}

- (NSMutableDictionary<NSString *,NSString *> *)generalHeaders{
    if (!_generalHeaders) {
        _generalHeaders = [NSMutableDictionary dictionary];
    }
    return _generalHeaders;
}

@end

@implementation KBNetworkManagerConfig

@end
