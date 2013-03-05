//
//  ChaosDownload.h
//  Chaos
//
//  Created by Albert Zhao on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChaosPhotoDownloadDelegate;

@interface ChaosPhotoDownload : NSObject {
	id<ChaosPhotoDownloadDelegate>	delegate;
	id<NSObject>	identifier;
	
	NSMutableData	*photoData;
    NSURLConnection *photoConnection;
	NSString		*url;
	
	long long	expectedSize;
	NSData		*downloadedPhotoData;
}

@property (nonatomic, assign) id<ChaosPhotoDownloadDelegate> delegate;
@property (nonatomic, readonly) id<NSObject> identifier;
@property (nonatomic, assign) NSInteger httpStatusCode;

@property (nonatomic, readonly) NSString *url;
@property (nonatomic, retain) NSMutableData *photoData;
@property (nonatomic, retain) NSURLConnection *photoConnection;
@property (nonatomic, readonly) NSData *downloadedPhotoData;

- (id)initWithIdentifier:(id)identifierParam withURL:(NSString *)urlParam;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol ChaosPhotoDownloadDelegate<NSObject>
@optional
- (void)photoDidDownload:(id)identifier;
@end
