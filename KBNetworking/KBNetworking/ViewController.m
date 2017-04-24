//
//  ViewController.m
//  KBNetworking
//
//  Created by kobe on 2017/4/18.
//  Copyright © 2017年 kobe. All rights reserved.
//

#import "ViewController.h"
#import "KBNetworking.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    [KBNetworkManager setupConfig:^(KBNetworkManagerConfig * _Nonnull config) {
////        config.generalServer = @"http://120.25.234.4/";
//        config.generalHeaders = @{@"app_version":@"3.0"};
//        config.callbackQueue = dispatch_get_main_queue();
//        
//    }];
    
    [self testDemo];
//    [self testBatchDemo];
//    [self testChainRequest];

//    [self demoDownloadRequest];
}


- (void)testDemo{
    [KBNetworkManager sendRequest:^(KBRequest * _Nonnull request) {
//        request.server = @"http://120.25.234.4/";
        request.api = @"api/index.htm";
        request.parameters = @{@"userid":@""};
//        request.headers = @{@"app_version":@"3.0"};
//        request.httpMethod = KBHTTPMethodPOST;
//        request.requestSerializerType = KBRequestSerializerJSON;
//        request.requestSerializerType = KBResponseSerializerJSON;
        
    } onSuccess:^(id  _Nullable responseObject) {
        NSLog(@"%@",responseObject);
    } onFailure:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
}



- (void)testBatchDemo{
    
    KBBatchRequest *batchRequest = [KBNetworkManager sendBatchRequest:^(KBBatchRequest * _Nonnull batchRequest) {
        KBRequest *one = [KBRequest request];
        one.server = @"http://120.25.234.4/";
        one.api = @"api/index.htm";
        one.parameters = @{@"userid":@""};
        
        KBRequest *two = [KBRequest request];
        two.server = @"http://120.25.234.4/";
        two.api = @"api/index.htm";
        two.parameters = @{@"userid":@""};

        [batchRequest.requestArray addObject:one];
        [batchRequest.requestArray addObject:two];
        
        
    } onSuccess:^(NSArray<id> * _Nonnull responseObject) {
        
        NSLog(@"--------%@----------",responseObject);
        
    } onFailure:^(NSArray<id> * _Nonnull errors) {
        
    } onFinished:^(NSArray<id> * _Nullable responseObjects, NSArray<id> * _Nullable errors) {
        
    }];
}

- (void)testChainRequest{
    KBChainRequest *chainRequest = [KBNetworkManager sendChainRequest:^(KBChainRequest * _Nonnull chainRequest) {
        [[chainRequest onFirst:^(KBRequest * _Nonnull request) {
            request.server = @"http://120.25.234.4/";
            request.api = @"api/index.htm";
            request.parameters = @{@"userid":@""};
        }]onNext:^(KBRequest * _Nonnull request, id  _Nullable responseObject, BOOL * _Nonnull sendNext) {
            request.server = @"http://120.25.234.4/";
            request.api = @"api/index.htm";
            request.parameters = @{@"userid":@""};
        }];
        
    } onSuccess:^(NSArray<id> * _Nonnull responseObject) {
        NSLog(@"-------------%@-----------", responseObject);
    } onFailure:^(NSArray<id> * _Nonnull errors) {
        
    } onFinished:^(NSArray<id> * _Nullable responseObjects, NSArray<id> * _Nullable errors) {
        
    }];
}


- (void)uploadDemo{
    UIImage *image = [UIImage imageNamed:@"cart"];
    NSData *originImgData=UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgStr=[originImgData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [KBNetworkManager sendRequest:^(KBRequest * _Nonnull request) {
        request.server = @"http://example.com/v1/";
        request.api = @"foo/bar";
        request.requestType = KBRequestUpload;
        [request addFormDataWithName:@"image_test" fileName:@"temp.png" mimeType:@"image/png" fileData:originImgData];
        
    } onProgress:^(NSProgress * _Nonnull progress) {
        if (progress) {
            NSLog(@"onProgress: %f", progress.fractionCompleted);
        }
    } onSuccess:^(id  _Nullable responseObject) {
        
    } onFailure:^(NSError * _Nullable error) {
        
    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        
    }];
}



- (void)demoDownloadRequest {
    
    [KBNetworkManager sendRequest:^(KBRequest *request) {
        request.url = @"https://ayera.dl.sourceforge.net/project/subtext/OldFiles/SubText-2.1.1.1.zip";
        request.downloadSavePath = [NSHomeDirectory() stringByAppendingString:@"/Documents/"];
        request.requestType = KBRequestDownload;
    } onProgress:^(NSProgress *progress) {
        // the progress block is running on the session queue.
        if (progress) {
            NSLog(@"onProgress: %f", progress.fractionCompleted);
        }
    } onSuccess:^(id responseObject) {
        NSLog(@"onSuccess: %@", responseObject);
    } onFailure:^(NSError *error) {
        NSLog(@"onFailure: %@", error);
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
