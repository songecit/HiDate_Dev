//
//  UzysAssetsViewCell.m
//  UzysAssetsPickerController
//
//  Created by Uzysjung on 2014. 2. 12..
//  Copyright (c) 2014년 Uzys. All rights reserved.
//

#import "UzysAssetsViewCell.h"
#import "UzysAppearanceConfig.h"

#define kImageClipWidth  150
#define kImageClipHeight 150

@interface UzysAssetsViewCell()
@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *videoImage;
@end
@implementation UzysAssetsViewCell

static UIFont *videoTimeFont = nil;

static CGFloat videoTimeHeight;
static UIImage *videoIcon;
static UIColor *videoTitleColor;
static UIImage *checkedIcon;
static UIImage *uncheckedIcon;
static UIColor *selectedColor;
static CGFloat thumnailLength;
+ (void)initialize
{
    UzysAppearanceConfig *appearanceConfig = [UzysAppearanceConfig sharedConfig];

    videoTitleColor      = [UIColor whiteColor];
    videoTimeFont       = [UIFont systemFontOfSize:12];
    videoTimeHeight     = 20.0f;
    videoIcon       = [UIImage imageNamed:@"UzysAssetPickerController.bundle/uzysAP_ico_assets_video"];
    
    checkedIcon     = [UIImage Uzys_imageNamed:appearanceConfig.assetSelectedImageName];
    uncheckedIcon   = [UIImage Uzys_imageNamed:appearanceConfig.assetDeselectedImageName];
    selectedColor   = [UIColor colorWithWhite:1 alpha:0.3];
    
    thumnailLength = ([UIScreen mainScreen].bounds.size.width - appearanceConfig.cellSpacing * ((CGFloat)appearanceConfig.assetsCountInALine - 1.0f)) / (CGFloat)appearanceConfig.assetsCountInALine;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.opaque = YES;
        
    }
    return self;
}
- (void)applyData:(ALAsset *)asset
{
    self.asset  = asset;
    
    //modify by lzh
    self.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    self.image = [self scaleToSizeWithOriginalImage:self.image withSize:CGSizeMake(kImageClipWidth, kImageClipHeight) isEqualRatio:NO];
    
    self.type   = [asset valueForProperty:ALAssetPropertyType];
    self.title  = [UzysAssetsViewCell getTimeStringOfTimeInterval:[[asset valueForProperty:ALAssetPropertyDuration] doubleValue]];
}

//截取部分图像
-(UIImage*)getSubImageWithOriginalImage:(UIImage *)originalImage withClipRect:(CGRect)rect
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}

//缩放  isEqualRatio Yes:等比缩放  No:按照长宽来缩放
-(UIImage*)scaleToSizeWithOriginalImage:(UIImage *)originalImage withSize:(CGSize)size isEqualRatio:(BOOL)isEqualRatio
{
    CGFloat width = CGImageGetWidth(originalImage.CGImage);
    CGFloat height = CGImageGetHeight(originalImage.CGImage);
    
    float verticalRadio = size.height*1.0/height;
    float horizontalRadio = size.width*1.0/width;
    
    float radio = 1;
    if(verticalRadio >= 1 && horizontalRadio >= 1) {
        return originalImage;
        //放大
        if (isEqualRatio) {
            radio = verticalRadio >= horizontalRadio ? horizontalRadio : verticalRadio;
        } else {
            radio = verticalRadio >= horizontalRadio ? verticalRadio : horizontalRadio;
        }
    } else {
        //缩小
        if (isEqualRatio) {
            radio = verticalRadio <= horizontalRadio ? verticalRadio : horizontalRadio;
        } else {
            radio = verticalRadio <= horizontalRadio ? horizontalRadio : verticalRadio;
        }
    }
    
    width = width*radio;
    height = height*radio;
    
    int xPos = (size.width - width)/2;
    int yPos = (size.height-height)/2;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    
    // 绘制改变大小的图片
    [originalImage drawInRect:CGRectMake(xPos, yPos, width, height)];
    
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    // 返回新的改变大小后的图片
    return scaledImage;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
    
    if(selected)
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(0.97, 0.97);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
            self.transform = CGAffineTransformMakeScale(1.03, 1.03);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
                self.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
        
    }
}


- (void)drawRect:(CGRect)rect
{
    // Image
    [self.image drawInRect:CGRectMake(-.5f, -1.0f, thumnailLength+1.5f, thumnailLength+1.0f)];
    
    // Video title
    if ([self.type isEqual:ALAssetTypeVideo])
    {
        // Create a gradient from transparent to black
        CGFloat colors [] =
        {
            0.0, 0.0, 0.0, 0.0,
            0.0, 0.0, 0.0, 0.8,
            0.0, 0.0, 0.0, 1.0
        };
        
        CGFloat locations [] = {0.0, 0.75, 1.0};
        
        CGColorSpaceRef baseSpace   = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient      = CGGradientCreateWithColorComponents(baseSpace, colors, locations, 2);
        CGContextRef context    = UIGraphicsGetCurrentContext();
        
        CGFloat height          = rect.size.height;
        CGPoint startPoint      = CGPointMake(CGRectGetMidX(rect), height - videoTimeHeight);
        CGPoint endPoint        = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation);
        
        NSDictionary *attributes = @{NSFontAttributeName:videoTimeFont,NSForegroundColorAttributeName:videoTitleColor};
        CGSize titleSize        = [self.title sizeWithAttributes:attributes];
        [self.title drawInRect:CGRectMake(rect.size.width - (NSInteger)titleSize.width - 2 , startPoint.y + (videoTimeHeight - 12) / 2, thumnailLength, height) withAttributes:attributes];
        
        [videoIcon drawAtPoint:CGPointMake(2, startPoint.y + (videoTimeHeight - videoIcon.size.height) / 2)];
        
    }
    
    if (self.selected)
    {
        CGContextRef context    = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, selectedColor.CGColor);
		CGContextFillRect(context, rect);
        [checkedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - checkedIcon.size.width -2, CGRectGetMinY(rect)+2)];
    }
    else
    {
        [uncheckedIcon drawAtPoint:CGPointMake(CGRectGetMaxX(rect) - uncheckedIcon.size.width -2, CGRectGetMinY(rect)+2)];
        
    }
}


+ (NSString *)getTimeStringOfTimeInterval:(NSTimeInterval)timeInterval
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateRef = [[NSDate alloc] init];
    NSDate *dateNow = [[NSDate alloc] initWithTimeInterval:timeInterval sinceDate:dateRef];
    
    unsigned int uFlags =
    NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour |
    NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;

    NSDateComponents *components = [calendar components:uFlags
                                               fromDate:dateRef
                                                 toDate:dateNow
                                                options:0];
    NSString *retTimeInterval;
    if (components.hour > 0)
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld:%02ld", (long)components.hour, (long)components.minute, (long)components.second];
    }
    
    else
    {
        retTimeInterval = [NSString stringWithFormat:@"%ld:%02ld", (long)components.minute, (long)components.second];
    }
    return retTimeInterval;
}


@end
