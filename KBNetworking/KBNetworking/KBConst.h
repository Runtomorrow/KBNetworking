//
//  KBConst.h
//  KBNetworking
//
//  Created by kobe on 2017/4/18.
//  Copyright © 2017年 kobe. All rights reserved.
//

#ifndef KBConst_h
#define KBConst_h

#define KB_SAFE_BLOCK(BlockName,...) ({ !BlockName ? nil : BlockName(__VA_ARGS__); })
#define KBLock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define KBUnLock() dispatch_semaphore_signal(self->_lock)

NS_ASSUME_NONNULL_BEGIN

@class KBRequest,KBBatchRequest,KBChainRequest;


/**
   Network Request Type

 - KBRequestNormal:   Normal
 - KBRequestUpload:   Upload
 - KBRequestDownload: Download
 */
typedef NS_ENUM(NSInteger, KBRequestType){
    KBRequestNormal = 0,
    KBRequestUpload = 1,
    KBRequestDownload = 2,
};



/**
   Network HTTP Type

 - KBHTTPMethodGET: GET
 - KBHTTPMethodPOST: POST
 - KBHTTPMethodHEAD: HEAD
 - KBHTTPMethodDELETE: DELETE
 - KBHTTPMethodPUT: PUT
 - KBHTTPMethodPATCH: PATCH
 */
typedef NS_ENUM(NSInteger, KBHTTPMethodType){
    KBHTTPMethodGET = 0,
    KBHTTPMethodPOST = 1,
    KBHTTPMethodHEAD = 2,
    KBHTTPMethodDELETE = 3,
    KBHTTPMethodPUT = 4,
    KBHTTPMethodPATCH = 5
};



/**
  Network Request Serializer Type

 - KBRequestSerializerRAW: RAW
 - KBRequestSerializerJSON: JSON
 - KBRequestSerializerPlist: Plist
 */
typedef NS_ENUM(NSInteger, KBRequestSerializerType){
    KBRequestSerializerRAW = 0,
    KBRequestSerializerJSON = 1,
    KBRequestSerializerPlist = 2,
};



/**
   Network Response Serializer Type

 - KBResponseSerializerRAW: RAW
 - KBResponseSerializerJSON: JSON
 - KBResponseSerializerPlist: Plist
 - KBResponseSerializerXML: XML
 */
typedef NS_ENUM(NSInteger, KBResponseSerializerType){
    KBResponseSerializerRAW = 0,
    KBResponseSerializerJSON = 1,
    KBResponseSerializerPlist = 2,
    KBResponseSerializerXML = 3,
};


///-------------------------------
/// @name KBRequest Config Blocks
///-------------------------------
typedef void(^KBRequestConfigBlock)(KBRequest *request);
typedef void(^KBBatchRequestConfigBlock)(KBBatchRequest *batchRequest);
typedef void(^KBChainRequestConfigBlock)(KBChainRequest *chainRequest);


///--------------------------------
/// @name KBRequest Callback Blocks
///--------------------------------
typedef void(^KBProgressBlock)(NSProgress *progress);
typedef void(^KBSuccessBlock)(id _Nullable responseObject);
typedef void(^KBFailureBlock)(NSError * _Nullable error);
typedef void(^KBFinishedBlock)(id _Nullable responseObject, NSError * _Nullable error);
typedef void(^KBCancelBlock)(KBRequest * _Nullable request);

///-------------------------------------
/// @name KBBatchRequest Callback Blocks
///-------------------------------------
typedef void(^KBBatchSuccessBlock)(NSArray<id> *responseObject);
typedef void(^KBBatchFailureBlock)(NSArray<id> *errors);
typedef void(^KBBatchFinishedBlock)(NSArray<id> * _Nullable responseObjects, NSArray<id> * _Nullable errors);

///--------------------------------------
/// @name KBChainRequest Callback Blocks
///--------------------------------------
typedef void(^KBChainNextBlock)(KBRequest *request, id _Nullable responseObject, BOOL *sendNext);


/**
 Response Process Block 
 
 @param request KBRequest
 @param responseObject Response Object
 @param error Response Error
 */
typedef void(^KBCenterResponseProgressBlock)(KBRequest *request, id _Nullable responseObject, NSError * _Nullable __autoreleasing *error);

NS_ASSUME_NONNULL_END


#endif /* KBConst_h */
