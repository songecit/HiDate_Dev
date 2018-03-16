#import "ASHUDViewNV.h"

@implementation ASHUDViewNV

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.hudOriginY = 64.0f;
        self.hudToolbar = nil;
        self.hudActivityIV = nil;
        self.hudIV = nil;
        self.hudLabel = nil;
        self.alpha = 0;
    }
    return self;
}

//
- (void)dismiss
{
    [self hudHide];
}

//
- (void)show:(NSString *)status
{
	[self hudMake:status imgage:nil spin:YES hide:NO];
}

//
- (void)showSuccess:(NSString *)status
{
    [self showSuccess:status isHide:YES];
}

//
- (void)showError:(NSString *)status
{
    [self showError:status isHide:YES];
}

- (void)showInfo:(NSString *)status
{
    [self hudMake:status imgage:[UIImage imageNamed:@"hud_notify"] spin:NO hide:YES];
}

- (void)showSuccess:(NSString *)status isHide:(BOOL)isHide
{
    [self hudMake:status imgage:[UIImage imageNamed:@"hud_success"] spin:NO hide:isHide];
}

- (void)showError:(NSString *)status isHide:(BOOL)isHide
{
    [self hudMake:status imgage:[UIImage imageNamed:@"hud_error"] spin:NO hide:isHide];
}

- (void)showTipsWithLevel:(NSInteger)tipsLevel tipsMessage:(NSString *)message isHide:(BOOL)isHide
{
    //SUCCESS:1,
    //INFO:2,
    //WARNING:3,
    //FAILED:4
        
    if (tipsLevel == 1) {
        [self showSuccess:message isHide:isHide];
    } else if (tipsLevel == 2) {
        [self showError:message isHide:isHide]; //待添加
    } else if (tipsLevel == 3) {
        [self showError:message isHide:isHide]; //待添加
    } else {
        [self showError:message isHide:isHide];
    }
}


//
- (void)hudMake:(NSString *)status imgage:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide
{
	[self hudCreate];

	self.hudLabel.text = status;
	self.hudLabel.hidden = (status == nil) ? YES : NO;

	self.hudIV.image = img;
	self.hudIV.hidden = (img == nil) ? YES : NO;

	if (spin) [self.hudActivityIV startAnimating]; else [self.hudActivityIV stopAnimating];

	[self hudOrient];
	[self hudSize];
	[self hudShow];

    if (hide) {
        NSUInteger length = self.hudLabel.text.length;
        NSTimeInterval sleep = length * 0.04 + 2.5;
        [self performSelector:@selector(hudHide) withObject:nil afterDelay:sleep];
    }
    
}

//
- (void)hudCreate
{
	if (self.hudToolbar == nil){
		self.hudToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        // eac180 234 193 128
        self.hudToolbar.barTintColor= [UIColor colorWithRed:234.0 / 255.0 green:193 / 255.0 blue:128 / 255.0 alpha:0.95];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}
    
	if (self.hudToolbar.superview == nil){
        [self.superView addSubview:self.hudToolbar];
    }
    
	if (self.hudActivityIV == nil){
		self.hudActivityIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		self.hudActivityIV.hidesWhenStopped = YES;
	}
    
    if (self.hudActivityIV.superview == nil) {
        [self.hudToolbar addSubview:self.hudActivityIV];
    }

	if (self.hudIV == nil){
		self.hudIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
	}
    
    if (self.hudIV.superview == nil){
        [self.hudToolbar addSubview:self.hudIV];
    }

	if (self.hudLabel == nil)
	{
		self.hudLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.hudLabel.font = [UIFont systemFontOfSize:13.0f];
		self.hudLabel.textColor = [UIColor blackColor];
		self.hudLabel.backgroundColor = [UIColor clearColor];
		self.hudLabel.textAlignment = NSTextAlignmentCenter;
		self.hudLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		self.hudLabel.numberOfLines = 0;
	}
    
    if (self.hudLabel.superview == nil) {
        [self.hudToolbar addSubview:self.hudLabel];
    }
}

//
- (void)hudDestroy
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[self.hudLabel removeFromSuperview];
    self.hudLabel = nil;
	[self.hudIV removeFromSuperview];
    self.hudIV = nil;
	[self.hudActivityIV removeFromSuperview];
    self.hudActivityIV = nil;
	[self.hudToolbar removeFromSuperview];
    self.hudToolbar = nil;
}

//
- (void)rotate:(NSNotification *)notification
{
	[self hudOrient];
}

//
- (void)hudOrient
{
	CGFloat rotate = 0.0;
	//
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	//
	if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
	//
	self.hudToolbar.transform = CGAffineTransformMakeRotation(rotate);
}

//
- (void)hudSize
{
	CGRect labelRect = CGRectZero;
	if (self.hudLabel.text != nil)
	{
		NSDictionary *attributes = @{NSFontAttributeName:self.hudLabel.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [self.hudLabel.text boundingRectWithSize:CGSizeMake([[UIScreen mainScreen]bounds].size.width, 300) options:options attributes:attributes context:NULL];
        if (labelRect.size.width>[[UIScreen mainScreen]bounds].size.width-25) {
            labelRect.size.width=[[UIScreen mainScreen]bounds].size.width-25;
        }
		labelRect.origin.x = ([[UIScreen mainScreen]bounds].size.width-labelRect.size.width)/2.0;
		labelRect.origin.y = 0;
        labelRect.size.height=35.0;
        self.hudIV.frame=CGRectMake(labelRect.origin.x-20, (35.0-16.0)/2.0, 16, 16);
        self.hudActivityIV.frame=CGRectMake(labelRect.origin.x-34, (35.0-30.0)/2.0, 30, 30);
	}
	//
	CGSize screen = [UIScreen mainScreen].bounds.size;
	self.hudToolbar.frame = CGRectMake(0, self.hudOriginY,screen.width, 35);
	self.hudLabel.frame = labelRect;
}

//
- (void)hudShow
{
	if (self.alpha == 0)
	{
		self.alpha = 1;

		self.hudToolbar.alpha = 0;
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			self.hudToolbar.alpha = 1;
		} completion:^(BOOL finished){
            
        }];
	}
}

//
- (void)hudHide
{
	if (self.alpha == 1)
	{
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			self.hudToolbar.alpha = 0;
		} completion:^(BOOL finished) {
            self.alpha = 0;
			[self hudDestroy];
		}];
	}
}

//
- (void)timedHide
{
	@autoreleasepool
	{
		double length = self.hudLabel.text.length;
		NSTimeInterval sleep = length * 0.04 +2.5;
		
		[NSThread sleepForTimeInterval:sleep];

		[self hudHide];
	}
}


@end
