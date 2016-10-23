//
//  OImageView.h
//  Exclusive
//
//  Created by Jungrak Lee on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OImageView : UIImageView
{
    NSURLConnection *connection;
    NSMutableData *data;
    
    NSString *_url;
}

@property (nonatomic, retain) NSString *url;

- (void)setImageWithUrl:(NSString *)url;
- (void)setImageWithUrl:(NSString *)url defaultImage:(UIImage *)defaultImage;
- (void)setImageWithUrl:(NSString *)url defaultImage:(UIImage *)defaultImage changeImage:(BOOL)change;

@end

@interface ImageCache : NSObject
{
    NSUInteger totalSize;  // total number of bytes
    NSUInteger maxSize;    // maximum capacity
    NSMutableDictionary *myDictionary;
}

@property (nonatomic, readonly) NSUInteger totalSize;

-(id)initWithMaxSize:(NSUInteger) max;
-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key;
-(void)removeImageForKey:(NSString*)key;
-(UIImage*)imageForKey:(NSString*)key;

@end

@interface ImageCacheObject : NSObject
{
    NSUInteger size;    // size in bytes of image data
    NSDate *timeStamp;  // time of last access
    UIImage *image;     // cached image
}

@property (nonatomic, readonly) NSUInteger size;
@property (nonatomic, retain, readonly) NSDate *timeStamp;
@property (nonatomic, retain, readonly) UIImage *image;

-(id)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage;
-(void)resetTimeStamp;

@end
