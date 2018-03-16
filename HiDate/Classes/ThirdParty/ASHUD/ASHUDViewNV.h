
//#import "Utils.h"
@interface ASHUDViewNV : UIView

- (void)dismiss;
- (void)show:(NSString *)status;
- (void)showSuccess:(NSString *)status;
- (void)showError:(NSString *)status;
- (void)showInfo:(NSString *)status;

- (void)showSuccess:(NSString *)status isHide:(BOOL)isHide;
- (void)showError:(NSString *)status isHide:(BOOL)isHide;

- (void)showTipsWithLevel:(NSInteger)tipsLevel tipsMessage:(NSString *)message isHide:(BOOL)isHide;

@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIToolbar *hudToolbar;
@property (nonatomic, strong) UIActivityIndicatorView *hudActivityIV;
@property (nonatomic, strong) UIImageView *hudIV;
@property (nonatomic, strong) UILabel *hudLabel;

@property (nonatomic, assign) CGFloat hudOriginY;

@end
