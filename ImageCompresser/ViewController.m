
#import "ViewController.h"

#import "ImageCompressor.h"


#define B2MB(length) (length / (1024.0 * 1024.0))

#define TIMESTAMP ([[NSDate alloc] init].timeIntervalSince1970 * 1000)


@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UITextView *imageDescVeiw;
@property (strong, nonatomic) NSString *currentImagePath;

@end


@implementation ViewController

# pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *imageURL = info[UIImagePickerControllerImageURL];
    NSString *imagePath = [imageURL relativePath];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.currentImagePath = imagePath;
    [self refreshImage: self.currentImagePath];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *home = NSHomeDirectory();
    NSString *temp = NSTemporaryDirectory();
    NSLog(@"----->>>>>> HOME: %@", home);
    NSLog(@"----->>>>>> TEMP: %@", temp);
    
    // Image Picker
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    
    /// Pick image button
    UIButton *pickImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:pickImageButton];
    [pickImageButton setTitle:@"Pick image" forState:UIControlStateNormal];
    pickImageButton.frame = CGRectMake(1, 120, 120, 45);
    pickImageButton.layer.borderWidth = 1;
    pickImageButton.layer.cornerRadius = 5;
    pickImageButton.layer.borderColor = [[UIColor grayColor] CGColor];
    [pickImageButton addTarget:self action:@selector(pickImage:) forControlEvents:UIControlEventTouchUpInside];
    
    /// Compress image button
    UIButton *compressImageButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:compressImageButton];
    [compressImageButton setTitle:@"Compress image" forState:UIControlStateNormal];
    compressImageButton.frame = CGRectMake(150, 120, 160, 45);
    compressImageButton.layer.borderWidth = 1;
    compressImageButton.layer.cornerRadius = 5;
    compressImageButton.layer.borderColor = [[UIColor grayColor] CGColor];
    [compressImageButton addTarget:self action:@selector(compressImage:) forControlEvents:UIControlEventTouchUpInside];
    
    // Image View
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 180, 180, 180)];
    [self.view addSubview:imageView];
    imageView.clipsToBounds = TRUE;
    imageView.layer.borderWidth = 1;
    imageView.layer.cornerRadius = 5;
    imageView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.imageView = imageView;
    
    // Image description
    UITextView *imageDescVeiw = [[UITextView alloc] initWithFrame:CGRectMake(1, 361, [UIScreen mainScreen].bounds.size.width - 2, 200)];
    [self.view addSubview:imageDescVeiw];
    imageDescVeiw.clipsToBounds = TRUE;
    imageDescVeiw.layer.borderWidth = 1;
    imageDescVeiw.layer.cornerRadius = 5;
    imageDescVeiw.layer.borderColor = [[UIColor grayColor] CGColor];
    self.imageDescVeiw = imageDescVeiw;
}

- (void)pickImage:(id)sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePicker animated:YES completion:nil];
    return;
    
    UIAlertAction *choosePhotoAction = [UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:choosePhotoAction];
    [alertController addAction:takePhotoAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)refreshImage:(NSString *)imagePath {
    NSString *temp = NSTemporaryDirectory();
    
    // Clear Temp Directory
    [self clearTemp:^BOOL(NSString *path) {
        return ![path containsString:@"jj"];
    }];
    
    //
    NSData *fileData = [NSData dataWithContentsOfFile:imagePath];
    int length = (int) fileData.length;
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    // self.imageView.image = image;
    self.imageView.image = [UIImage imageWithData:fileData];
    
    NSString *desc = nil;
    desc = [NSString stringWithFormat:@"file length: %d Bytes, %.2f MB, %d X %d \n", length, B2MB(length), (int)image.size.width, (int)image.size.height];
    
    NSData *imageData = nil;
    if ([ImageCompressor isPNG:fileData]) {
        // PNG
        imageData = UIImagePNGRepresentation(image);
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_png", TIMESTAMP]] atomically:YES];
        [fileData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_file", TIMESTAMP]] atomically:YES];
        
        NSData *pngData = nil;
        
        //
        imageData = UIImageJPEGRepresentation(image, 1.0);
        desc = [NSString stringWithFormat:@"%@ \n1.0 JPEG length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_1.0", TIMESTAMP]] atomically:YES];
        
        pngData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
        desc = [NSString stringWithFormat:@"%@ \n1.0 PNG length: %d Bytes, %.2fMB \n", desc, (int) pngData.length, B2MB((int) pngData.length)];
        [pngData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_1.0", TIMESTAMP]] atomically:YES];
        
        //
        imageData = UIImageJPEGRepresentation(image, 0.8);
        desc = [NSString stringWithFormat:@"%@ \n0.8 JPEG length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.8", TIMESTAMP]] atomically:YES];
        
        pngData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
        desc = [NSString stringWithFormat:@"%@ \n0.8 PNG length: %d Bytes, %.2fMB \n", desc, (int) pngData.length, B2MB((int) pngData.length)];
        [pngData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_0.8", TIMESTAMP]] atomically:YES];
        
        //
        imageData = UIImageJPEGRepresentation(image, 0.5);
        desc = [NSString stringWithFormat:@"%@ \n0.5 JPEG length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.5", TIMESTAMP]] atomically:YES];
        
        pngData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
        desc = [NSString stringWithFormat:@"%@ \n0.5 PNG length: %d Bytes, %.2fMB \n", desc, (int) pngData.length, B2MB((int) pngData.length)];
        [pngData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_0.5", TIMESTAMP]] atomically:YES];
        
        //
        imageData = UIImageJPEGRepresentation(image, 0.1);
        desc = [NSString stringWithFormat:@"%@ \n0.1 JPEG length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.1", TIMESTAMP]] atomically:YES];
        
        pngData = UIImagePNGRepresentation([UIImage imageWithData:imageData]);
        desc = [NSString stringWithFormat:@"%@ \n0.1 PNG length: %d Bytes, %.2fMB \n", desc, (int) pngData.length, B2MB((int) pngData.length)];
        [pngData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.PNG", temp, @"jj_0.1", TIMESTAMP]] atomically:YES];
        
    } else {
        // JPEG
        [fileData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_file", TIMESTAMP]] atomically:YES];
        
        imageData = UIImageJPEGRepresentation(image, 1.0);
        desc = [NSString stringWithFormat:@"%@ \n1.0 image length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_1.0", TIMESTAMP]] atomically:YES];
        
        imageData = UIImageJPEGRepresentation(image, 0.8);
        desc = [NSString stringWithFormat:@"%@ \n0.8 image length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.8", TIMESTAMP]] atomically:YES];
        
        imageData = UIImageJPEGRepresentation(image, 0.5);
        desc = [NSString stringWithFormat:@"%@ \n0.5 image length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.5", TIMESTAMP]] atomically:YES];
        
        imageData = UIImageJPEGRepresentation(image, 0.1);
        desc = [NSString stringWithFormat:@"%@ \n0.1 image length: %d Bytes, %.2fMB \n", desc, (int) imageData.length, B2MB((int) imageData.length)];
        [imageData writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@_%.0f.JPEG", temp, @"jj_0.1", TIMESTAMP]] atomically:YES];
    }
    
    self.imageDescVeiw.text = desc;
}


- (void)clearTemp:(BOOL (^)(NSString *path))shouldIgnoreBlock {
    // Clear Temp Directory
    NSString *temp = NSTemporaryDirectory();
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:temp];
    for (int i = 0; i < files.count; i++) {
        NSString *f = [files objectAtIndex:i];
        NSString *p = [NSString stringWithFormat:@"%@%@", temp, f];
        if (shouldIgnoreBlock != nil && shouldIgnoreBlock(p)) {
            continue;
        }
        NSError *error = nil;
        BOOL isDeleted = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:p] error:&error];
        NSLog(@"delete result %d, %@", isDeleted, error);
    }
}

- (void)compressImage:(UIButton *)button {
    [self clearTemp:^BOOL(NSString *path) {
        return ![path containsString:@"dd"];
    }];
    
    NSString *home = NSHomeDirectory();
    NSString *temp = NSTemporaryDirectory();
    NSLog(@"----->>>>>> HOME: %@", home);
    NSLog(@"----->>>>>> TEMP: %@", temp);
    
//    NSString *imageName = @"icon";
//    NSString *suffix = @"png";
    NSString *imageName = @"Inspector";
    NSString *suffix = @"zip";
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:suffix];
    self.currentImagePath = imagePath;
    [self refreshImage: self.currentImagePath];
    
    UIImage *image = [UIImage imageWithContentsOfFile:self.currentImagePath];
    float w = image.size.width;
    float h = image.size.height;
    NSLog(@"----->>>>>> image: %.2f X %.2f", w, h);
    
    // NSData *data = [ImageCompressor compress:image minResolution:w/4 * h/4 maxSize:32 * 1024];
    NSData *data = [ImageCompressor autoCompressToSize:image size:32 * 1024];
    [data writeToURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@.jpeg", temp, @"dd_oo"]] atomically:YES];
    
    UIImage *newImage = [UIImage imageWithData:data];
    NSLog(@"----->>>>>> newImage: %d X %d", (int)newImage.size.width, (int)newImage.size.height);
}


@end
