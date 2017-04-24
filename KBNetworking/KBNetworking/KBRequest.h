//
//  KBRequest.h
//  KBNetworking
//
//  Created by kobe on 2017/4/18.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KBConst.h"

NS_ASSUME_NONNULL_BEGIN

@class KBUploadFormData;
///---------------------------
/// @name KBRequest NSObject
///---------------------------
@interface KBRequest : NSObject

@property (nonatomic, assign) NSUInteger identifier;         ///<创建一个请求标识符
@property (nonatomic, copy, nullable) NSString *server;      ///<服务器的域名
@property (nonatomic, copy, nullable) NSString *api;         ///<请求api
@property (nonatomic, copy, nullable) NSString *url;         ///<请求地址
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *parameters;   ///<请求参数
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *headers;   ///<请求头参数
@property (nonatomic, assign) BOOL useGeneralServer;
@property (nonatomic, assign) BOOL useGeneralHeaders;
@property (nonatomic, assign) BOOL useGeneralParameters;
@property (nonatomic, assign) KBRequestType requestType;
@property (nonatomic, assign) KBHTTPMethodType httpMethod;
@property (nonatomic, assign) KBResponseSerializerType responseSerializerType;    ///< Default JSON
@property (nonatomic, assign) KBRequestSerializerType requestSerializerType;      ///< Default JSON
@property (nonatomic, assign) NSTimeInterval timeoutInterval;      ///<请求超时
@property (nonatomic, assign) NSUInteger retryCount;               ///<尝试请求的次数
@property (nonatomic, strong, nullable) NSDictionary *userInfo;
@property (nonatomic, strong, nullable) NSString *downloadSavePath;
@property (nonatomic, strong, nullable) NSMutableArray<KBUploadFormData *> *uploadFormDatas;

@property (nonatomic, copy, readonly, nullable) KBSuccessBlock successBlock;
@property (nonatomic, copy, readonly, nullable) KBFailureBlock failureBlock;
@property (nonatomic, copy, readonly, nullable) KBFinishedBlock finishedBlock;
@property (nonatomic, copy, readonly, nullable) KBProgressBlock progressBlock;

+ (instancetype)request;

- (void)cleanCallbackBlocks;

- (void)addFormDataWithName:(NSString *)name
                   fileData:(NSData *)fileData;

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                   fileData:(NSData *)fileData;

- (void)addFormDataWithName:(NSString *)name
                    fileURL:(NSURL *)fileURL;

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                    fileURL:(NSURL *)fileURL;
@end


///-------------------------------
/// @name KBBatchRequest NSObject
///-------------------------------
@interface KBBatchRequest : NSObject

@property (nonatomic, strong, readonly) NSMutableArray<KBRequest *> *requestArray;
@property (nonatomic, strong, readonly) NSMutableArray<id> *responseArray;


/**
 Finished A KBBatchRequest

 @param request KBRequest
 @param responseObject responseObject
 @param error error
 */
- (void)onFinishedOneRequest:(KBRequest *)request
                    response:(nullable id)responseObject
                       error:(nullable NSError *)error;


/**
 Cancel All KBRequest

 @param cancelBlock void
 */
- (void)cancelWithBlock:(nullable void(^)())cancelBlock;

@end


///-------------------------------
/// @name KBChainRequest NSObject
///-------------------------------
@interface KBChainRequest : NSObject
@property (nonatomic, strong, readonly) KBRequest *firstRequest;
@property (nonatomic, strong, readonly) KBRequest *nextRequest;


/**
 First ChainRequest

 @param firstBlock KBRequestConfigBlock
 @return KBChainRequest
 */
- (KBChainRequest *)onFirst:(KBRequestConfigBlock)firstBlock;

/**
 Next ChainRequest

 @param nextBlock KBChainNextBlock
 @return KBChainRequest
 */
- (KBChainRequest *)onNext:(KBChainNextBlock)nextBlock;


/**
 Finished One Request

 @param request KBRequest
 @param responseObject responseBbject
 @param error error
 */
- (void)onFinishedOneRequest:(KBRequest *)request
                    response:(nullable id)responseObject
                       error:(nullable NSError *)error;


/**
 Cancel ChainRequest

 @param cancelBlock void
 */
- (void)cancelWithBlock:(nullable void(^)())cancelBlock;

@end


///---------------------------------
/// @name KBUploadFormData NSObject
///---------------------------------
@interface KBUploadFormData : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSString *mimeType;
@property (nonatomic, strong, nullable) NSData *fileData;
@property (nonatomic, strong, nullable) NSURL *fileURL;

+ (instancetype)formDataWithName:(NSString *)name
                        fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                        fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name
                         fileURL:(NSURL *)fileURL;

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         fileURL:(NSURL *)fileURL;

@end


NS_ASSUME_NONNULL_END
