
#import "ImageCompressor.h"

@implementation ImageCompressor

+ (UIImage *)compressImage:(UIImage *)image minResolution:(int)minResolution maxSize:(int)maxSize
{
    
    return [UIImage imageWithData:[self compress:image minResolution:minResolution maxSize:maxSize]];
}

+ (UIImage *)compressImage:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio minResolution:(int)minResolution maxSize:(int)maxSize
{
    
    return [UIImage imageWithData:[self compress:image compressRatio:ratio maxCompressRatio:maxRatio minResolution:minResolution maxSize:maxSize]];
}

+ (NSData *)compress:(UIImage *)image minResolution:(int)minResolution maxSize:(int)maxSize
{
    
    return [self compress:image compressRatio:0.8f maxCompressRatio:0.1f minResolution:minResolution maxSize:maxSize];
}

+ (NSData *)compress:(UIImage *)image compressRatio:(CGFloat)ratio maxCompressRatio:(CGFloat)maxRatio minResolution:(int)minResolution maxSize:(int)maxSize
{
    
    //We define the max and min resolutions to shrink to
    int MIN_UPLOAD_RESOLUTION = minResolution; // i.e. image.size.width/4 * image.size.height/4
    int MAX_UPLOAD_SIZE = maxSize; // 50 * 1024 -> 50KB;
    
    float factor;
    float currentResolution = image.size.height * image.size.width;
    
    //We first shrink the image a little bit in order to compress it a little bit more
    if (currentResolution > MIN_UPLOAD_RESOLUTION && MIN_UPLOAD_RESOLUTION != 0) {
        factor = sqrt(currentResolution / MIN_UPLOAD_RESOLUTION) * 2;
        image = [self scale:image size:CGSizeMake(image.size.width / factor, image.size.height / factor)];
    }
    
    //Compression settings
    CGFloat compression = ratio;
    CGFloat maxCompression = maxRatio;
    
    //We loop into the image data to compress accordingly to the compression ratio
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > MAX_UPLOAD_SIZE && compression > maxCompression) {
        compression -= 0.10;
        if (compression <= 0) break;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

+ (NSData *)autoCompressToSize:(UIImage *)image size:(int)maxSize
{
    
    if (image == nil) {
        return nil;
    }
    //Compression settings
    CGFloat ratio = 0.9f;
    CGFloat maxRatio = 0.1f;
    
    //We loop into the image data to compress accordingly to the compression ratio
    NSData *imageData = UIImageJPEGRepresentation(image, ratio);
    while ([imageData length] > maxSize) {
        ratio -= 0.10;
        if (ratio <= maxRatio) break;
        imageData = UIImageJPEGRepresentation(image, ratio);
    }
    
    if ([imageData length] <= maxSize) {
        return imageData;
    }
    
    //Not enough, reduce the width and height
    UIImage *newImage = [UIImage imageWithData:imageData];
    float w = newImage.size.width;
    float h = newImage.size.height;
    float r = 0.8;
    
    while ([imageData length] > maxSize) {
        r -= 0.1f;
        if (r <= 0.1f) {
            r -= 0.01f;
        };
        
        if (r <= 0.01f) {
            break;
        }
        
        UIImage *image = [self scale:newImage size:CGSizeMake(w * r, h * r)];
        imageData = UIImageJPEGRepresentation(image, 0.8f);
    }
    
    return imageData;
}

// MARK: Scale & Rotate

+ (UIImage *)scale:(UIImage*)image size:(CGSize)newSize
{
    
    //We prepare a bitmap with the new size
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0.0);
    
    //Draws a rect for the image
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    
    //We set the scaled image from the context
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

+ (UIImage *)rotate:(UIImage*)image degree:(CGFloat)degree
{
    
    UIImage *oldImage = image;
    
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degree * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, (degree * M_PI / 180));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


// MARK: Utils Methods

+ (BOOL)isWebP:(NSData *)data {
    if (data.length < 12) return false;
    
    NSData *riff = [data subdataWithRange:NSMakeRange(8, 4)];
    NSString* format = [[NSString alloc] initWithData:riff encoding:(NSASCIIStringEncoding)];
    
    return [format isEqualToString:@"WEBP"];
}

+ (BOOL)isPNG:(NSData *)data {
    if (data.length < 8) return false;
    
    NSData *png = [data subdataWithRange:NSMakeRange(1, 3)];
    NSString* format = [[NSString alloc] initWithData:png encoding:(NSASCIIStringEncoding)];
    
    return [format isEqualToString:@"PNG"];
}

@end
