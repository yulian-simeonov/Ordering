//
//  OImageView.m
//  Exclusive
//
//  Created by Jungrak Lee on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OImageView.h"

#define kCacheSize  8 * 1024 * 1024

static ImageCache *imageCache = nil;

@implementation OImageView

@synthesize url = _url;

+ (void)removeImageFromCacheWithUrl:(NSString *)url
{
    if (imageCache == nil) {
        return;
    }
    
    [imageCache removeImageForKey:url];
}

- (void)dealloc {
    [connection cancel];
    [connection release];
    [data release];
    
    [super dealloc];
}

- (void)setImageWithUrl:(NSString *)url
{
    [self setImageWithUrl:url defaultImage:nil];
}

- (void)setImageWithUrl:(NSString *)url defaultImage:(UIImage *)defaultImage
{
    [self setImageWithUrl:url defaultImage:defaultImage changeImage:NO];
}

- (void)setImageWithUrl:(NSString *)url defaultImage:(UIImage *)defaultImage changeImage:(BOOL)change
{
    if ([url isKindOfClass:[NSNull class]] == YES || url.length == 0) {
        [self setImage:defaultImage];
        
        return;
    }
    
    self.url = url;
    
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    
    if (data != nil) {
        [data release];
        data = nil;
    }
    
    if (imageCache == nil) {
        imageCache = [[ImageCache alloc] initWithMaxSize:kCacheSize];
    }
    
    UIImage *cachedImage = [imageCache imageForKey:url];
    
    if (cachedImage != nil
        && change == NO) {
        self.image = cachedImage;
        
        return;
    }
    
    [self setImage:defaultImage];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:60.0];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)incrementalData
{
    if (data==nil) {
        data = [[NSMutableData alloc] initWithCapacity:2 * 1024];
    }
    [data appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    UIImage *image = [UIImage imageWithData:data];
    
    [imageCache insertImage:image withSize:[data length] forKey:_url];

    [self setImage:image];
    
    if (connection != nil) {
        [connection cancel];
        [connection release];
        connection = nil;
    }
    
    if (data != nil) {
        [data release];
        data = nil;
    }
}

@end

@implementation ImageCache

@synthesize totalSize;

-(id)initWithMaxSize:(NSUInteger) max  {
    self = [super init];
    
    if (self) {
        totalSize = 0;
        maxSize = max;
        myDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [myDictionary release];

    [super dealloc];
}

-(void)insertImage:(UIImage*)image withSize:(NSUInteger)sz forKey:(NSString*)key
{
    ImageCacheObject *object = [[ImageCacheObject alloc] initWithSize:sz Image:image];
    while (totalSize + sz > maxSize && [myDictionary count] > 0) {
        NSDate *oldestTime = [NSDate date];
        NSString *oldestKey = nil;
        
        for (NSString *key in [myDictionary allKeys]) {
            ImageCacheObject *obj = [myDictionary objectForKey:key];
            if (oldestTime == nil || [obj.timeStamp compare:oldestTime] == NSOrderedAscending) {
                oldestTime = obj.timeStamp;
                oldestKey = key;
            }
        }
        
        if (oldestKey == nil)
            break; // shoudn't happen
        
        [self removeImageForKey:oldestKey];
        //        NSLog(@"[REMOVE] totalSize:%dkb imgSize:%dkb", totalSize / 1024, obj.size / 1024);
    }
    
    totalSize += sz;
    
    [myDictionary setObject:object forKey:key];
    [object release];
    
    //    NSLog(@"[ADD] totalSize:%dkb imgSize:%dkb", totalSize / 1024, sz / 1024);
}

-(void)removeImageForKey:(NSString*)key
{
    ImageCacheObject *obj = [myDictionary objectForKey:key];
    totalSize -= obj.size;
    [myDictionary removeObjectForKey:key];
}

-(UIImage*)imageForKey:(NSString*)key
{
    ImageCacheObject *object = [myDictionary objectForKey:key];
    
    if (object == nil) {
        return nil;
    }
    
    [object resetTimeStamp];
    
    return object.image;
}

@end

@implementation ImageCacheObject

@synthesize size;
@synthesize timeStamp;
@synthesize image;

-(id)initWithSize:(NSUInteger)sz Image:(UIImage*)anImage
{
    if (self = [super init]) {
        size = sz;
        timeStamp = [[NSDate date] retain];
        image = [anImage retain];
    }
    return self;
}

-(void)resetTimeStamp
{
    [timeStamp release];
    timeStamp = [[NSDate date] retain];
}

-(void) dealloc
{
    [timeStamp release];
    [image release];
    [super dealloc];
}

@end
