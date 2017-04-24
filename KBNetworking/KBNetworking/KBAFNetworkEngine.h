//
//  KBAFNetworkEngine.h
//  KBNetworking
//
//  Created by kobe on 2017/4/19.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class KBRequest, AFHTTPSessionManager;

typedef void(^KBCompletionHandler)(id _Nullable responseObject, NSError * _Nullable error);

@interface KBAFNetworkEngine : NSObject
//__attribute__((unavailable("Disabled. Use +sharedInstance instead")));
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)shareEngine;

@property (nonatomic, strong, readonly) AFHTTPSessionManager *sessionManager;

/**
 Send A KBRequest

 @param request KBRequest
 @param completionHandler Callback Block
 @return NSUInteger
 */
- (NSUInteger)sendRequest:(KBRequest *)request
        completionHandler:(nullable KBCompletionHandler)completionHandler;

/**
 Cancel A KBRequest

 @param identifier identifier
 @return KBRequest
 */
- (nullable KBRequest *)cancelRequestByIdentifier:(NSUInteger)identifier;

/**
 Fetch A KBRequest

 @param identifier identifier
 @return KBRequest
 */
- (nullable KBRequest *)getRequestByIdentifier:(NSUInteger)identifier;

/**
 Networking status

 @return status
 */
- (NSInteger)networkReachability;
@end

NS_ASSUME_NONNULL_END
