//
//  KBRequest.m
//  KBNetworking
//
//  Created by kobe on 2017/4/18.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "KBRequest.h"
#import "KBNetworkManager.h"

///---------------------------
/// @name KBRequest NSObject
///---------------------------
@interface KBRequest ()

@end

@implementation KBRequest

/**
 Create A KBRequest

 @return KBRequest Object
 */
+ (instancetype)request{
    return [[[self class] alloc] init];
}


- (instancetype)init{
    if (self = [super init]) {
        
        //Defalut Some Data
        _requestType = KBRequestNormal;
        _httpMethod = KBHTTPMethodPOST;
        _requestSerializerType = KBRequestSerializerJSON;
        _responseSerializerType = KBResponseSerializerJSON;
        _timeoutInterval = 60.0;
        _useGeneralServer = YES;
        _useGeneralHeaders = YES;
        _useGeneralParameters = YES;
        _retryCount = 0;
        _identifier = 0;
    }
    return  self;
}

- (void)cleanCallbackBlocks{
    _successBlock = nil;
    _failureBlock = nil;
    _finishedBlock = nil;
    _progressBlock = nil;
}

-(NSMutableArray<KBUploadFormData *> *)uploadFormDatas{
    if (!_uploadFormDatas) {
        _uploadFormDatas = [NSMutableArray array];
    }
    return _uploadFormDatas;
}

- (void)addFormDataWithName:(NSString *)name
                   fileData:(NSData *)fileData{
    KBUploadFormData *formData = [KBUploadFormData formDataWithName:name
                                                           fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                   fileData:(NSData *)fileData{
    KBUploadFormData *formData = [KBUploadFormData formDataWithName:name
                                                           fileName:fileName
                                                           mimeType:mimeType
                                                           fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}


- (void)addFormDataWithName:(NSString *)name
                    fileURL:(NSURL *)fileURL{
    KBUploadFormData *formData = [KBUploadFormData formDataWithName:name
                                                            fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                    fileURL:( NSURL *)fileURL{
    KBUploadFormData *formData = [KBUploadFormData formDataWithName:name
                                                           fileName:fileName
                                                           mimeType:mimeType
                                                            fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"----%s----",__FUNCTION__);
#endif
}

@end


///-------------------------------
/// @name KBBatchRequest NSObject
///-------------------------------

@interface KBBatchRequest ()
{
    dispatch_semaphore_t _lock;
    NSUInteger _finishedCount;
    BOOL _failed;
}

@property (nonatomic, copy) KBBatchSuccessBlock batchSuccessBlock;
@property (nonatomic, copy) KBBatchFailureBlock batchFailureBlock;
@property (nonatomic, copy) KBBatchFinishedBlock batchFinishedBlock;

@end

@implementation KBBatchRequest

- (instancetype)init{
    if (self= [super init]) {
        _failed = NO;
        _finishedCount = 0;
        _lock = dispatch_semaphore_create(1);
        _requestArray = [NSMutableArray array];
        _responseArray = [NSMutableArray array];
    }
    return self;
}

- (void)onFinishedOneRequest:(KBRequest *)request
                    response:(id)responseObject
                       error:(NSError *)error{
    KBLock();
    NSUInteger index = [_requestArray indexOfObject:request];
    if (responseObject) {
        [_responseArray replaceObjectAtIndex:index withObject:responseObject];
    }else{
        _failed = YES;
        if (error) {
            [_responseArray replaceObjectAtIndex:index withObject:error];
        }
    }
    
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
        if (!_failed) {
            KB_SAFE_BLOCK(_batchSuccessBlock, _responseArray);
            KB_SAFE_BLOCK(_batchFinishedBlock, _responseArray,nil);
        }else{
            KB_SAFE_BLOCK(_batchFailureBlock, _responseArray);
            KB_SAFE_BLOCK(_batchFinishedBlock, nil, _responseArray);
        }
        [self cleanCallBackBlocks];
    }
    KBUnLock();
}


- (void)cleanCallBackBlocks{
    _batchSuccessBlock = nil;
    _batchFailureBlock = nil;
    _batchFinishedBlock = nil;
}



- (void)cancelWithBlock:(void (^)())cancelBlock{
    if (_requestArray.count > 0) {
        [_requestArray enumerateObjectsUsingBlock:^(KBRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.identifier > 0) {
                [KBNetworkManager cancelRequest:obj.identifier];
            }
        }];
    }
    KB_SAFE_BLOCK(cancelBlock);
    
}

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"-----%s-----", __FUNCTION__);
#endif
}


@end

///-------------------------------
/// @name KBChainRequest NSObject
///-------------------------------

@interface KBChainRequest ()
{
    NSUInteger _chainIndex;
}
@property (nonatomic, strong, readwrite) KBRequest *firstRequest;
@property (nonatomic, strong, readwrite) KBRequest *nextRequest;
@property (nonatomic, strong) NSMutableArray<KBChainNextBlock> *nextBlockArray;
@property (nonatomic, strong) NSMutableArray<id> *responseArray;
@property (nonatomic, copy) KBBatchSuccessBlock chainSuccessBlock;
@property (nonatomic, copy) KBBatchFailureBlock chainFailureBlock;
@property (nonatomic, copy) KBBatchFinishedBlock chainFinishedBlock;

@end

@implementation KBChainRequest

- (instancetype)init{
    if (self = [super init]) {
        _chainIndex = 0;
        _responseArray = [NSMutableArray array];
        _nextBlockArray = [NSMutableArray array];
    }
    return self;
}


/**
 ChainRequest The First KBRequest

 @param firstBlock KBRequestConfigBlock
 @return KBRequest
 */
- (KBChainRequest *)onFirst:(KBRequestConfigBlock)firstBlock{
    //If the condition is true not show tip info
    NSAssert(firstBlock != nil, @"The first block for chain requests can't be nil.");
    NSAssert(_nextBlockArray.count ==0, @"The `onFirst:` method must be called before `onNext:` method");
    
    //Create a first request
    _firstRequest = [KBRequest request];
    firstBlock(_firstRequest);
    [_responseArray addObject:[NSNull null]];
    return self;
}

- (KBChainRequest *)onNext:(KBChainNextBlock)nextBlock{
    NSAssert(nextBlock != nil, @"The next block for chain request can't be nil.");
    [_nextBlockArray addObject:nextBlock];
    [_responseArray addObject:[NSNull null]];
    return self;
}

- (void)onFinishedOneRequest:(KBRequest *)request
                    response:(id)responseObject
                       error:(NSError *)error{
    if (responseObject) {
        [_responseArray replaceObjectAtIndex:_chainIndex withObject:responseObject];
        
        if (_chainIndex < _nextBlockArray.count) {
            _nextRequest = [KBRequest request];
            KBChainNextBlock nextBlock = _nextBlockArray[_chainIndex];
            BOOL startNext = YES;
            
            nextBlock(_nextRequest, responseObject, &startNext);
            
            //此处代码不不知道什么作用
            if (!startNext) {
                KB_SAFE_BLOCK(_chainFailureBlock, _responseArray);
                KB_SAFE_BLOCK(_chainFinishedBlock, nil, _responseArray);
                [self cleanCallbackBlocks];
            }
            
        }else{
            KB_SAFE_BLOCK(_chainSuccessBlock, _responseArray);
            KB_SAFE_BLOCK(_chainFinishedBlock, nil, _responseArray);
            [self cleanCallbackBlocks];
        }
    }else{
        if (error) {
            [_responseArray replaceObjectAtIndex:_chainIndex withObject:error];
        }
        KB_SAFE_BLOCK(_chainFailureBlock, _responseArray);
        KB_SAFE_BLOCK(_chainFinishedBlock, nil, _responseArray);
        [self cleanCallbackBlocks];
    }
    _chainIndex++;
}


- (void)cleanCallbackBlocks{
    _firstRequest  = nil;
    _nextRequest = nil;
    _chainSuccessBlock = nil;
    _chainFailureBlock = nil;
    _chainFinishedBlock = nil;
    [_nextBlockArray removeAllObjects];
}


- (void)cancelWithBlock:(void (^)())cancelBlock{
    if (_firstRequest && !_nextRequest) {
        [KBNetworkManager cancelRequest:_firstRequest.identifier];
    }else if (_nextRequest){
        [KBNetworkManager cancelRequest:_nextRequest.identifier];
    }
    KB_SAFE_BLOCK(cancelBlock);
}

- (void)dealloc{
#ifdef DEBUG
    NSLog(@"----%s-----", __FUNCTION__);
#endif
}

@end



///---------------------------------
/// @name KBUploadFormData NSObject
///---------------------------------

@interface KBUploadFormData ()

@end
@implementation KBUploadFormData

+ (instancetype)formDataWithName:(NSString *)name
                        fileData:(NSData *)fileData{
    KBUploadFormData *formData = [[KBUploadFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                        fileData:(NSData *)fileData{
    KBUploadFormData *formData = [[KBUploadFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name fileURL:(NSURL *)fileURL{
    KBUploadFormData *formData = [[KBUploadFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         fileURL:(NSURL *)fileURL{
    KBUploadFormData *formData = [[KBUploadFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}


@end
