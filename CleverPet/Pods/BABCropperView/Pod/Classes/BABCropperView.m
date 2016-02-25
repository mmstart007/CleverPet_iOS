//
//  BABCropperView.m
//  Pods
//
//  Created by Bryn Bodayle on April/17/2015.
//
//

#import "BABCropperView.h"

@import ImageIO;

static const CGFloat BABCropperViewMaximumZoomScale = 4.0f;
static const CGFloat BABCropperViewMaskBackgroundColorAlpha = 0.7f;

static CGSize BABCropperViewScaledSizeToFitSize(CGSize size, CGSize fitSize) {
    
    if(fitSize.width >= size.width && fitSize.height >= size.height) { //already the correct size
        
        return size;
    }
    
    CGSize fittedSize;
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    if(width > height) {
        
        CGFloat ratio = height/width;
        fittedSize =  CGSizeMake(fitSize.width, floorf(fitSize.width * ratio));
    }
    else {
        
        CGFloat ratio = height/width;
        fittedSize = CGSizeMake(fitSize.width, floorf(fitSize.width * ratio));
        
    }
    
    if(fittedSize.height > fitSize.height) {
        
        if(width > height) {
            
            CGFloat ratio = width/height;
            
            fittedSize = CGSizeMake(floorf(fitSize.height * ratio), fitSize.height);
        }
        else {
            
            CGFloat ratio = width/height;
            
            fittedSize = CGSizeMake(floorf(fitSize.height * ratio), fitSize.height);
            
        }
    }
    
    return fittedSize;
}

static CGSize BABFlipedSize(CGSize size) {
    return CGSizeMake(size.height, size.width);
}

static UIImage* BABCropperViewCroppedAndScaledImageWithCropRect(UIImage *image, CGRect cropRect, CGSize scaleSize, BOOL cropToCircle, BOOL transparent) {
    
    CGSize imageSize = image.size;
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat scale = 1.0f;
    
    if(cropRect.size.width > cropRect.size.height) {
        scale = scaleSize.width/cropRect.size.width;
    }
    else {
        scale = scaleSize.height/cropRect.size.height;
    }
    
    CGRect drawRect = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    drawRect = CGRectApplyAffineTransform(drawRect, CGAffineTransformMakeScale(scale, scale));
    
    CGAffineTransform rectTransform;
    CGPoint shift = CGPointMake(cropRect.origin.x, cropRect.origin.y);
    switch (image.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(M_PI_2), 0, -drawRect.size.height);
            shift = CGPointMake(imageSize.height - shift.y - cropRect.size.width, imageSize.width - shift.x - cropRect.size.height);
            scaleSize = BABFlipedSize(scaleSize);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI_2), -drawRect.size.width, 0);
            shift = CGPointMake(shift.y, shift.x);
            scaleSize = BABFlipedSize(scaleSize);
            break;
        case UIImageOrientationUp:
            rectTransform = CGAffineTransformIdentity;
            shift = CGPointMake(shift.x, imageSize.height - shift.y - cropRect.size.height);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -drawRect.size.width, -drawRect.size.height);
            shift = CGPointMake(imageSize.width - shift.x - cropRect.size.height, shift.y);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
            break;
    };
    drawRect = CGRectApplyAffineTransform(drawRect, rectTransform);
    drawRect = CGRectApplyAffineTransform(drawRect, CGAffineTransformMakeTranslation(-shift.x * scale, -shift.y * scale));
    
    CGContextRef bitmap = CGBitmapContextCreate(NULL, scaleSize.width, scaleSize.height, 8, scaleSize.width * 4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    if(cropToCircle) {
        CGContextAddEllipseInRect(bitmap, CGRectMake(0.0f, 0.0f, scaleSize.width, scaleSize.height));
        CGContextClip(bitmap);
    }
    
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    if(!transparent) {
        CGContextFillRect(bitmap, CGRectMake(0.0f, 0.0f, cropRect.size.width, cropRect.size.height));
    }
    
    CGContextDrawImage(bitmap, drawRect, image.CGImage);
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:scale orientation:image.imageOrientation];
    
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    CGColorSpaceRelease(colorspace);
    
    return newImage;
}

@interface BABCropperView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *borderView;

@property (nonatomic, assign) CGSize scaledCropSize;
@property (nonatomic, assign) CGSize displayCropSize;
@property (nonatomic, assign) CGRect displayCropRect;
@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation BABCropperView

- (void)dealloc {
    
    [_operationQueue cancelAllOperations];
    _scrollView.delegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self sharedInit];
    }
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self sharedInit];
}

- (void)sharedInit {
    
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.cropDisplayScale = 1.0f;
    self.cropDisplayOffset = UIOffsetZero;
    
    self.backgroundColor = [UIColor blackColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];
    
    self.imageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:self.imageView];
    
    self.cropMaskView = [[UIView alloc] initWithFrame:self.bounds];
    self.cropMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.cropMaskView.userInteractionEnabled = NO;
    self.cropMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:BABCropperViewMaskBackgroundColorAlpha];
    [self addSubview:self.cropMaskView];
    
    self.borderView = [[UIView alloc] initWithFrame:self.cropMaskView.bounds];
    self.borderView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.borderView.layer.borderWidth = [UIScreen mainScreen].scale/4.0f;
    self.borderView.userInteractionEnabled = NO;
    [self addSubview:self.borderView];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.cropMaskView.frame;
    maskLayer.fillColor = self.cropMaskView.backgroundColor.CGColor;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    self.cropMaskView.layer.mask = maskLayer;
}


#pragma mark - Setters & Getters

- (void)setImage:(UIImage *)image {
    
    _image = image;
    _imageView.image = image;
    [_imageView sizeToFit];
    
    [self setNeedsLayout];
}

- (void)setCropSize:(CGSize)cropSize {
    
    _cropSize = cropSize;
    
    [self setNeedsLayout];
}

- (void)setCropsImageToCircle:(BOOL)cropsImageToCircle {
    
    _cropsImageToCircle = cropsImageToCircle;
    
    [self setNeedsLayout];
}

#pragma mark - View Configuration

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if(self.cropSize.width > 0 && self.cropSize.height > 0) {
        
        CGSize scaledSize = BABCropperViewScaledSizeToFitSize(self.cropSize, self.bounds.size);
        self.scaledCropSize = scaledSize;
        
        CGAffineTransform cropDisplayScaleTransform = CGAffineTransformMakeScale(self.cropDisplayScale, self.cropDisplayScale);
        self.displayCropSize = CGSizeApplyAffineTransform(scaledSize, cropDisplayScaleTransform);
        
        CGRect displayCropRect = CGRectMake(CGRectGetMidX(self.bounds) - self.displayCropSize.width/2.0f, CGRectGetMidY(self.bounds) - self.displayCropSize.height/2.0f, self.displayCropSize.width, self.displayCropSize.height);
        displayCropRect.origin.x += self.cropDisplayOffset.horizontal;
        displayCropRect.origin.y += self.cropDisplayOffset.vertical;
        self.displayCropRect = displayCropRect;
        
        
        if(self.cropsImageToCircle) {
            
            self.borderView.layer.cornerRadius = CGRectGetWidth(self.borderView.bounds)/2.0f;
            self.borderView.clipsToBounds = YES;
        }
        else {
            
            self.borderView.layer.cornerRadius = 0;
            self.borderView.clipsToBounds = NO;
        }
        
        [self updateScrollViewZoomScales];
        [self updateMaskView];
        [self updateScrollViewContentInset];
        [self centerImageInScrollView:self.scrollView];
    }
}

- (void)updateScrollViewZoomScales {
    
    if(self.image) {
        
        CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.bounds);
        CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.bounds);
        CGFloat imageViewWidth = CGRectGetWidth(self.imageView.bounds);
        CGFloat imageViewHeight = CGRectGetHeight(self.imageView.bounds);
        CGFloat imageWidth = self.image.size.width;
        CGFloat imageHeight = self.image.size.height;
        
        CGFloat scaleBasedOnHeight = self.displayCropSize.height/imageHeight;
        CGFloat scaleBasedOnWidth = self.displayCropSize.width/imageWidth;
        
        if(imageViewHeight > imageViewWidth) { //portrait image
            
            if(scrollViewHeight > scrollViewWidth && self.cropSize.width/self.cropSize.height < imageViewWidth/imageViewHeight) {
                
                self.scrollView.minimumZoomScale = scaleBasedOnHeight;
            }
            else {
                
                self.scrollView.minimumZoomScale = scaleBasedOnWidth;
            }
        }
        else { //landscape image
            
            if((scrollViewHeight >= scrollViewWidth) || (self.cropSize.width/self.cropSize.height < imageViewWidth/imageViewHeight)) {
                
                self.scrollView.minimumZoomScale = scaleBasedOnHeight;
            }
            else {
                
                self.scrollView.minimumZoomScale = scaleBasedOnWidth;
            }
        }
        
        self.scrollView.maximumZoomScale = BABCropperViewMaximumZoomScale;
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    }
}

- (void)updateScrollViewContentInset {
    
    CGFloat verticalInset = (CGRectGetHeight(self.bounds) - self.displayCropSize.height)/2.0f;
    CGFloat horizontalInset = (CGRectGetWidth(self.bounds) - self.displayCropSize.width)/2.0f;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalInset + self.cropDisplayOffset.vertical, horizontalInset + self.cropDisplayOffset.horizontal, verticalInset - self.cropDisplayOffset.vertical, horizontalInset - self.cropDisplayOffset.horizontal);
}

- (void)updateMaskView {
    
    self.borderView.frame = self.displayCropRect;
    
    CAShapeLayer *maskLayer = (CAShapeLayer *)self.cropMaskView.layer.mask;
    maskLayer.frame = self.cropMaskView.bounds;
    
    if(self.cropsImageToCircle){
        
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.displayCropRect];
        [path appendPath:[UIBezierPath bezierPathWithRect:maskLayer.frame]];
        maskLayer.path = path.CGPath;
    }
    else {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.displayCropRect];
        [path appendPath:[UIBezierPath bezierPathWithRect:maskLayer.frame]];
        maskLayer.path = path.CGPath;
    }
}

- (void)centerImageInScrollView:(UIScrollView *)scrollView {
    
    CGFloat contentSizeWidth = scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right;
    CGFloat contentSizeHeight = scrollView.contentSize.height + scrollView.contentInset.top + scrollView.contentInset.bottom;
    
    CGFloat offsetX = (scrollView.bounds.size.width > contentSizeWidth)? (scrollView.bounds.size.width - contentSizeWidth) * 0.5f : 0.0f;
    CGFloat offsetY = (scrollView.bounds.size.height > contentSizeHeight)? (scrollView.bounds.size.height - contentSizeHeight) * 0.5f : 0.0f;
    
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}


#pragma mark - Public Methods

- (void)renderCroppedImage:(void (^)(UIImage *croppedImage, CGRect cropRect))completionBlock {
    
    CGRect cropFrameRect;
    cropFrameRect.origin.x = self.scrollView.bounds.origin.x + self.scrollView.contentInset.left;
    cropFrameRect.origin.y = self.scrollView.bounds.origin.y + self.scrollView.contentInset.top;
    cropFrameRect.size.width = self.displayCropRect.size.width;
    cropFrameRect.size.height = self.displayCropRect.size.height;
    
    CGRect cropRect = [self.scrollView convertRect:cropFrameRect toView:self.imageView];
    
    UIImage *image = self.image;
    CGSize cropSize = self.cropSize;
    BOOL cropToCircle = self.cropsImageToCircle;
    BOOL leavesUnfilledRegionsTransparent = self.leavesUnfilledRegionsTransparent;
    
    [self.operationQueue addOperationWithBlock:^{
        
        UIImage *croppedImage = BABCropperViewCroppedAndScaledImageWithCropRect(image, cropRect, cropSize, cropToCircle, leavesUnfilledRegionsTransparent);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            completionBlock(croppedImage, cropRect);
        });
    }];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    [self centerImageInScrollView:scrollView];
}

@end
