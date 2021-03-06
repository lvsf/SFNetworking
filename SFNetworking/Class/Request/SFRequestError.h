//
//  SFRequestError.h
//  SFNetworking
//
//  Created by YunSL on 2019/3/21.
//  Copyright © 2019年 YunSL. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,SFURLErrorCustomCode) {
    SFURLErrorCustomCodeInvaildRequest            = -201,
    SFURLErrorCustomCodeFrequently                = -202,
    SFURLErrorCustomCodeNetworkNotReachable       = -203,
    SFURLErrorCustomCodeInitiativeCancelled       = -204
};

typedef NS_ENUM(NSInteger,SFURLErrorCode) {
    SFURLErrorUnknown =             -1,
    SFURLErrorCustom =              -200,
    SFURLErrorCancelled =             -999,
    SFURLErrorBadURL =                 -1000,
    SFURLErrorTimedOut =             -1001,
    SFURLErrorUSFupportedURL =             -1002,
    SFURLErrorCannotFindHost =             -1003,
    SFURLErrorCannotConnectToHost =         -1004,
    SFURLErrorNetworkConnectionLost =         -1005,
    SFURLErrorDSFLookupFailed =         -1006,
    SFURLErrorHTTPTooManyRedirects =         -1007,
    SFURLErrorResourceUnavailable =         -1008,
    SFURLErrorNotConnectedToInternet =         -1009,
    SFURLErrorRedirectToNonExistentLocation =     -1010,
    SFURLErrorBadServerResponse =         -1011,
    SFURLErrorUserCancelledAuthentication =     -1012,
    SFURLErrorUserAuthenticationRequired =     -1013,
    SFURLErrorZeroByteResource =         -1014,
    SFURLErrorCannotDecodeRawData =             -1015,
    SFURLErrorCannotDecodeContentData =         -1016,
    SFURLErrorCannotParseResponse =             -1017,
    SFURLErrorAppTransportSecurityRequiresSecureConnection NS_ENUM_AVAILABLE(10_11, 9_0) = -1022,
    SFURLErrorFileDoesNotExist =         -1100,
    SFURLErrorFileIsDirectory =         -1101,
    SFURLErrorNoPermissioSFToReadFile =     -1102,
    SFURLErrorDataLengthExceedsMaximum NS_ENUM_AVAILABLE(10_5, 2_0) =    -1103,
    
    // SSL errors
    SFURLErrorSecureConnectionFailed =             -1200,
    SFURLErrorServerCertificateHasBadDate =     -1201,
    SFURLErrorServerCertificateUntrusted =         -1202,
    SFURLErrorServerCertificateHasUnknownRoot = -1203,
    SFURLErrorServerCertificateNotYetValid =     -1204,
    SFURLErrorClientCertificateRejected =         -1205,
    SFURLErrorClientCertificateRequired =         -1206,
    SFURLErrorCannotLoadFromNetwork =              -2000,
    
    // Download and file I/O errors
    SFURLErrorCannotCreateFile =         -3000,
    SFURLErrorCannotOpenFile =             -3001,
    SFURLErrorCannotCloseFile =         -3002,
    SFURLErrorCannotWriteToFile =         -3003,
    SFURLErrorCannotRemoveFile =         -3004,
    SFURLErrorCannotMoveFile =             -3005,
    SFURLErrorDownloadDecodingFailedMidStream =  -3006,
    SFURLErrorDownloadDecodingFailedToComplete = -3007,
    
    SFURLErrorInternationalRoamingOff NS_ENUM_AVAILABLE(10_7, 3_0) =         -1018,
    SFURLErrorCallIsActive NS_ENUM_AVAILABLE(10_7, 3_0) =                    -1019,
    SFURLErrorDataNotAllowed NS_ENUM_AVAILABLE(10_7, 3_0) =                  -1020,
    SFURLErrorRequestBodyStreamExhausted NS_ENUM_AVAILABLE(10_7, 3_0) =      -1021,
    
    SFURLErrorBackgroundSessionRequiresSharedContainer NS_ENUM_AVAILABLE(10_10, 8_0) = -995,
    SFURLErrorBackgroundSessionInUseByAnotherProcess NS_ENUM_AVAILABLE(10_10, 8_0) =   -996,
    SFURLErrorBackgroundSessionWasDisconnected NS_ENUM_AVAILABLE(10_10, 8_0)=          -997,
};

NS_ASSUME_NONNULL_BEGIN

@interface SFRequestError : NSObject
@property (nonatomic,assign) SFURLErrorCode code;
@property (nonatomic,assign) SFURLErrorCustomCode customCode;
@property (nonatomic,copy) NSString *message;
+ (instancetype)requestErrorWithError:(NSError *)error;
+ (instancetype)requestErrorWithCode:(SFURLErrorCode)code message:(NSString *)message;
+ (instancetype)requestErrorWithCustomCode:(SFURLErrorCustomCode)customCode message:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
