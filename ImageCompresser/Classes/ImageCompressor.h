
#import <UIKit/UIKit.h>

@interface ImageCompressor : NSObject

+ (UIImage *)compressImage:(UIImage *)image minResolution:(int)minResolution maxSize:(int)maxSize;

+ (UIImage *)compressImage:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio minResolution:(int)minResolution maxSize:(int)maxSize;

+ (NSData *)compress:(UIImage *)image minResolution:(int)minResolution maxSize:(int)maxSize;

+ (NSData *)compress:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio minResolution:(int)minResolution maxSize:(int)maxSize;

+ (NSData *)autoCompressToSize:(UIImage *)image size:(int)maxSize;

// MARK: Scale & Rotate

+ (UIImage *)scale:(UIImage*)image size:(CGSize)newSize;

+ (UIImage *)rotate:(UIImage*)image degree:(CGFloat)degree;

// MARK: Utils Methods

+ (BOOL)isWebP:(NSData *)data ;

+ (BOOL)isPNG:(NSData *)data ;

@end

