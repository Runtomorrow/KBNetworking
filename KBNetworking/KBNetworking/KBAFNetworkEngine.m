//
//  KBAFNetworkEngine.m
//  KBNetworking
//
//  Created by kobe on 2017/4/19.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "KBAFNetworkEngine.h"
#import "AFNetworking.h"
#import "KBRequest.h"
#import "AFNetworkActivityIndicatorManager.h"
#import <objc/runtime.h>


static dispatch_queue_t kb_request_completion_callback_queue() {
    static dispatch_queue_t _kb_request_completion_callback_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kb_request_completion_callback_queue = dispatch_queue_create("com.kbnetworking.request.completion.callback.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    return _kb_request_completion_callback_queue;
}

@implementation NSObject (BindingKBRequestForNSURLSessionTask)
static NSString *const kBRequestBindingKey = @"kBRequestBindingKey";

- (void)bindingRequest:(KBRequest *)request{
    objc_setAssociatedObject(self, (__bridge CFStringRef)(kBRequestBindingKey), request, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KBRequest *)bindedRequest{
    KBRequest *request = objc_getAssociatedObject(self, (__bridge CFStringRef)kBRequestBindingKey);
    return request;
}

@end


@interface KBAFNetworkEngine ()
{
    dispatch_semaphore_t _lock;
}
@property (nonatomic, strong, readwrite) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) AFJSONRequestSerializer *aFJSONRequestSerializer;
@property (nonatomic, strong) AFPropertyListRequestSerializer *aFPropertyListRequestSerializer;
@property (nonatomic, strong) AFJSONResponseSerializer *aFJSONResponseSerializer;
@property (nonatomic, strong) AFPropertyListResponseSerializer *aFPropertyListResponseSerializer;
@property (nonatomic, strong) AFXMLParserResponseSerializer *aFXMLParserResponseSerializer;
@end


@implementation KBAFNetworkEngine

+ (instancetype)shareEngine{
    static id shareInstance =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[[self class] alloc] init];
    });
    return shareInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _lock = dispatch_semaphore_create(1);
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    }
    return self;
}

+ (void)load{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)dealloc{
    if (_sessionManager) {
        //Cancel Network request
        [_sessionManager invalidateSessionCancelingTasks:YES];
    }
}


#pragma mark - <Public Method>
- (NSUInteger)sendRequest:(KBRequest *)request
        completionHandler:(KBCompletionHandler)completionHandler{
    if (request.requestType == KBRequestNormal) {
        return [self kb_dataTaskWithRequest:request completionHandler:completionHandler];
    }else if (request.requestType == KBRequestUpload){
        return [self kb_uploadTaskWithRequest:request completionHandler:completionHandler];
    }else if (request.requestType == KBRequestDownload){
        return [self kb_downloadTaskWithRequest:request completionHandler:completionHandler];
    }else{
        NSAssert(NO, @"Unknown request type. ");
        return 0;
    }
}

- (nullable KBRequest *)cancelRequestByIdentifier:(NSUInteger)identifier{
    if (identifier == 0) return nil;
    __block KBRequest *request = nil;
    KBLock();
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.taskIdentifier == identifier) {
            request = obj.bindedRequest;
            [obj cancel];
            *stop = YES;
        }
    }];
    KBUnLock();
    return request;
}

- (nullable KBRequest *)getRequestByIdentifier:(NSUInteger)identifier{
    if (identifier == 0) return nil;
    __block KBRequest *request = nil;
    KBLock();
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.taskIdentifier == identifier) {
            request = obj.bindedRequest;
            *stop = YES;
        }
    }];
    KBUnLock();
    return request;
    
}

- (NSInteger)networkReachability{
    return [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

#pragma mark - Private Method



/**
 Normal Request

 @param request KBRequest
 @param completionHandler Callback Block
 @return identifier
 */
- (NSUInteger)kb_dataTaskWithRequest:(KBRequest *)request
                   completionHandler:(KBCompletionHandler)completionHandler{
    NSString *httpMethod = nil;
    static dispatch_once_t onceToken;
    static NSArray  *httpMethodArray = nil;
    
    dispatch_once(&onceToken, ^{
        httpMethodArray = @[@"GET", @"POST", @"HEAD", @"DELETE", @"PUT", @"PATCH"];
    });
    
    //获取请求方法
    if (request.httpMethod >= 0 && request.httpMethod < httpMethodArray.count) {
        httpMethod = httpMethodArray[request.httpMethod];
    };
    NSAssert(httpMethod.length > 0, @"The HTTP method not found.");
    
    // 请求序列化
    AFHTTPRequestSerializer *requestSerializer = [self kb_getRequestSerializer:request];
    NSError *serializationError = nil;
    
    // URL序列化
    NSMutableURLRequest *urlRequest = [requestSerializer requestWithMethod:httpMethod
                                                                 URLString:request.url
                                                                parameters:request.parameters
                                                                    error:&serializationError];
    if (serializationError) {
        if (completionHandler) {
            //async
            dispatch_async(kb_request_completion_callback_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return 0;
    }
    // 拼接请求头
    [self kb_processURLRequest:urlRequest byKBRequest:request];
    
    
    // 发送网路请求
    NSURLSessionDataTask *dataTask = nil;
    __weak __typeof(self)weakSelf = self;
    dataTask = [self.sessionManager dataTaskWithRequest:urlRequest
                                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                          
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf kb_processResponse:response
                                object:responseObject
                                 error:error
                               request:request
                     completionHandler:completionHandler];
    }];
    
    // 绑定请求
    [dataTask bindingRequest:request];
    // 设置标识符
    [request setIdentifier:dataTask.taskIdentifier];
    // 开始执行
    [dataTask resume];
    
    return request.identifier;
}

/**
 Download Request

 @param request KBRequest
 @param completionHandler Callback Block
 @return identifier
 */
- (NSUInteger)kb_downloadTaskWithRequest:(KBRequest *)request
                       completionHandler:(KBCompletionHandler)completionHandler{
    
    // 请求
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:request.url]];
    // 拼接请求头
    [self kb_processURLRequest:urlRequest byKBRequest:request];
    
    NSURL *downloadFileSavePath;
    BOOL isDirectory;

    // 通过传入一个路径来判断文件或者目录是否存在
    if (![[NSFileManager defaultManager] fileExistsAtPath:request.downloadSavePath isDirectory:&isDirectory]) {
        isDirectory = NO;
    }
    
    // 如果文件目录存在的话
    if (isDirectory) {
        NSString *fileName = [urlRequest.URL lastPathComponent];
        downloadFileSavePath = [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadSavePath, fileName]] isDirectory:NO];
    }else{
        downloadFileSavePath = [NSURL fileURLWithPath:request.downloadSavePath isDirectory:NO];
    }
    
    // 下载
    NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [self.sessionManager downloadTaskWithRequest:urlRequest
                                                       progress:request.progressBlock
                                                    destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return downloadFileSavePath;
    }
                                              completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(filePath, error);
        }
    }];
    
    [downloadTask bindingRequest:request];
    [request setIdentifier:downloadTask.taskIdentifier];
    [downloadTask resume];
    return request.identifier;
}


/**
 Upload Request

 @param request KBRequest
 @param completionHandler Callback Block
 @return identifier
 */
- (NSUInteger)kb_uploadTaskWithRequest:(KBRequest *)request
                     completionHandler:(KBCompletionHandler)completionHandler{
    AFHTTPRequestSerializer *requestSerializer = [self kb_getRequestSerializer:request];
    __block NSError *serializationError = nil;
    
    NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                              URLString:request.url
                                                                             parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [request.uploadFormDatas enumerateObjectsUsingBlock:^(KBUploadFormData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //是否是二进制文件
            if (obj.fileData) {
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileData:obj.fileData
                                                name:obj.name
                                            fileName:obj.fileName
                                            mimeType:obj.mimeType];
                }else{
                    [formData appendPartWithFormData:obj.fileData
                                                name:obj.name];
                }
            }else if (obj.fileURL){
                NSError *fileError = nil;
                if (obj.fileName && obj.mimeType) {
                    [formData appendPartWithFileURL:obj.fileURL
                                               name:obj.name
                                           fileName:obj.fileName
                                           mimeType:obj.mimeType
                                              error:&fileError];
                }else{
                    [formData appendPartWithFileURL:obj.fileURL
                                               name:obj.name error:&fileError];
                }
                
                if (fileError) {
                    serializationError = fileError;
                    *stop = YES;
                }
            }
        }];
        
    } error:&serializationError];
    
    
    if (serializationError) {
        if (completionHandler) {
            
            dispatch_async(kb_request_completion_callback_queue(), ^{
                completionHandler(nil, serializationError);
            });
        }
        return 0;
    }
    
    // 添加请求头
    [self kb_processURLRequest:urlRequest byKBRequest:request];
    
    // 上传
    NSURLSessionUploadTask *uploadTask = nil;
    __weak __typeof(self)weakSelf = self;
    uploadTask = [self.sessionManager uploadTaskWithStreamedRequest:urlRequest
                                                           progress:request.progressBlock completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        __strong __typeof(self)strongSelf = weakSelf;
        [strongSelf kb_processResponse:response
                                object:responseObject
                                 error:error
                               request:request
                     completionHandler:completionHandler];
    }];
    
    [uploadTask bindingRequest:request];
    [request setIdentifier:uploadTask.taskIdentifier];
    [uploadTask resume];
    
    return request.identifier;
}


/**
 Request Headers

 @param urlRequest URL
 @param request KBRequest
 */
- (void)kb_processURLRequest:(NSMutableURLRequest *)urlRequest
                 byKBRequest:(KBRequest *)request{
    if (request.headers.count > 0) {
        [request.headers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [urlRequest setValue:obj forHTTPHeaderField:key];
        }];
    }
    // 请求超时
    urlRequest.timeoutInterval = request.timeoutInterval;
}



/**
 Serializer Response

 @param response URL
 @param responseObject Response
 @param error error
 @param request KBRequest
 @param completionHandler Callback Block
 */
- (void)kb_processResponse:(NSURLResponse *)response
                    object:(id)responseObject
                     error:(NSError *)error
                   request:(KBRequest *)request
         completionHandler:(KBCompletionHandler)completionHandler{
    NSError *serializationError = nil;
    if (request.responseSerializerType != KBResponseSerializerRAW) {
        AFHTTPResponseSerializer *responseSerializer = [self kb_getResponseSerializer:request];
        // 返回的对象序列化
        responseObject = [responseSerializer responseObjectForResponse:response
                                                                  data:responseObject
                                                                 error:&serializationError];
    }
    
    if (completionHandler) {
        if (serializationError) {
            completionHandler(nil, serializationError);
        }else{
            
            completionHandler(responseObject, error);
        }
    }
}


- (AFHTTPRequestSerializer *)kb_getRequestSerializer:(KBRequest *)request{
    if (request.requestSerializerType == KBRequestSerializerRAW) {
        return self.sessionManager.requestSerializer;
    }else if (request.requestSerializerType == KBRequestSerializerJSON){
        return self.aFJSONRequestSerializer;
    }else if (request.requestSerializerType == KBRequestSerializerPlist){
        return self.aFPropertyListRequestSerializer;
    }else{
        NSAssert(NO, @"Unknown request serializer type.");
        return nil;
    }
}

- (AFHTTPResponseSerializer *)kb_getResponseSerializer:(KBRequest *)request{
    if (request.responseSerializerType == KBRequestSerializerRAW) {
        return self.sessionManager.responseSerializer;
    }else if (request.responseSerializerType == KBRequestSerializerJSON){
        return self.aFJSONResponseSerializer;
    }else if (request.responseSerializerType == KBRequestSerializerPlist){
        return self.aFPropertyListResponseSerializer;
    }else if (request.responseSerializerType == KBResponseSerializerXML){
        return self.aFXMLParserResponseSerializer;
    }else{
        NSAssert(NO, @"Unknown response serializer type.");
        return nil;
    }
}


#pragma mark <getter setter>
- (AFHTTPSessionManager *)sessionManager{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.operationQueue.maxConcurrentOperationCount = 5;
        _sessionManager.completionQueue = kb_request_completion_callback_queue();
    }
    return _sessionManager;
}

- (AFJSONRequestSerializer *)aFJSONRequestSerializer{
    if (!_aFJSONRequestSerializer) {
        _aFJSONRequestSerializer = [AFJSONRequestSerializer serializer];
    }
    return _aFJSONRequestSerializer;
}

- (AFPropertyListRequestSerializer *)aFPropertyListRequestSerializer{
    if (!_aFPropertyListRequestSerializer) {
        _aFPropertyListRequestSerializer = [AFPropertyListRequestSerializer serializer];
    }
    return _aFPropertyListRequestSerializer;
}

- (AFJSONResponseSerializer *)aFJSONResponseSerializer{
    if (!_aFJSONResponseSerializer) {
        _aFJSONResponseSerializer = [AFJSONResponseSerializer serializer];
        _aFJSONResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html",@"text/plain", nil];
    }
    return _aFJSONResponseSerializer;
}

- (AFPropertyListResponseSerializer *)aFPropertyListResponseSerializer{
    if (!_aFPropertyListResponseSerializer) {
        _aFPropertyListResponseSerializer = [AFPropertyListResponseSerializer serializer];
    }
    return _aFPropertyListResponseSerializer;
}

- (AFXMLParserResponseSerializer *)aFXMLParserResponseSerializer{
    if (!_aFXMLParserResponseSerializer) {
        _aFXMLParserResponseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return _aFXMLParserResponseSerializer;
}

@end
