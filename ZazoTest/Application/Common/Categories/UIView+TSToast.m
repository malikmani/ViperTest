/*
  UIView+TSToast.m
  Technosoft Solutions


Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
                                                          "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

***************************************************************************/

#import "UIView+TSToast.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

//#define kMaxWidth                   0.95
//#define kMaxHeight                  0.95
//
//#define kHorizontalPadding          10.0
//#define kVerticalPadding            10.0
//#define kCornerRadius               10.0
//#define kOpacity                    0.8
//#define kFontSize                   10.0
//#define kMaxTitleLines              999
//#define kMaxMessageLines            999
//#define kFadeDuration               0.2
//#define kDisplayShadow              YES
//
//#define kDefaultLength              3.0
//#define kDefaultPosition            @"bottom"
//
//#define kImageWidth                 80.0
//#define kImageHeight                80.0
//
//#define kActivityWidth              100.0
//#define kActivityHeight             100.0
//#define kActivityDefaultPosition    @"center"
//#define kActivityTag                91325

#define kMaxWidth                   1.95
#define kMaxHeight 1.95

#define kHorizontalPadding          10.0
#define kVerticalPadding            10.0
#define kCornerRadius               10.0
#define kOpacity                    1
#define kFontSize                   14.0
#define kMaxTitleLines              999
#define kMaxMessageLines            999
#define kFadeDuration               0.2
#define kDisplayShadow              YES

#define kDefaultLength              3.0
#define kDefaultPosition            @"center"

#define kImageWidth                 80.0
#define kImageHeight                80.0

#define kActivityWidth              200.0
#define kActivityHeight             200.0
#define kActivityDefaultPosition    @"center"
#define kActivityTag                91325

static NSString *kDurationKey = @"CSToastDurationKey";

@interface UIView (ToastPrivate)

- (CGPoint)getPositionFor:(id)position toast:(UIView *)toast;
- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image;

@end

@implementation UIView (Toast)

#pragma mark - Toast Methods

- (void)makeToast:(NSString *)message disableView:(BOOL)option{
	[self makeToast:message duration:kDefaultLength position:kDefaultPosition disableView:option];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval disableView:(BOOL)option {
	[self makeToast:message duration:interval position:kDefaultPosition disableView:option];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position disableView:(BOOL)option {
	UIView *toast = [self makeViewForMessage:message title:nil image:nil];
	[self showToast:toast duration:interval position:position disableView:option];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position title:(NSString *)title disableView:(BOOL)option {
	UIView *toast = [self makeViewForMessage:message title:title image:nil];
	[self showToast:toast duration:interval position:position disableView:option];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval position:(id)position image:(UIImage *)image disableView:(BOOL)option {
	UIView *toast = [self makeViewForMessage:message title:nil image:image];
	[self showToast:toast duration:interval position:position disableView:option];
}

- (void)makeToast:(NSString *)message duration:(CGFloat)interval  position:(id)position title:(NSString *)title image:(UIImage *)image disableView:(BOOL)option {
	UIView *toast = [self makeViewForMessage:message title:title image:image];
	[self showToast:toast duration:interval position:position disableView:option];
}

- (void)showToast:(UIView *)toast disableView:(BOOL)option {
	[self showToast:toast duration:kDefaultLength position:kDefaultPosition disableView:option];
}

- (void)showToast:(UIView *)toast duration:(CGFloat)interval position:(id)point disableView:(BOOL)option {
	
	// Disable background view if needed
	[self setUserInteractionEnabled:!option];
	
	// Display a view for a given duration & position.
	
	CGPoint toastPoint = [self getPositionFor:point toast:toast];
	
	// use an associative reference to associate the toast view with the display interval
	objc_setAssociatedObject (toast, &kDurationKey, [NSNumber numberWithFloat:interval], OBJC_ASSOCIATION_RETAIN);
	
	[toast setCenter:toastPoint];
	[toast setAlpha:0.0];
	[self addSubview:toast];
	
#if !__has_feature(objc_arc)
	[UIView beginAnimations:@"fade_in" context:toast];
#else
	[UIView beginAnimations:@"fade_in" context:(__bridge void*)toast];
#endif
	[UIView setAnimationDuration:kFadeDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[toast setAlpha:1.0];
	[UIView commitAnimations];
	
}

#pragma mark - Toast Activity Methods

- (void)makeToastActivity {
	[self makeToastActivity:kActivityDefaultPosition];
}

- (void)makeToastActivity:(id)position {
	// prevent more than one activity view
	UIView *existingToast = [self viewWithTag:kActivityTag];
	if (existingToast != nil) {
		[existingToast removeFromSuperview];
	}
	
	UIView *activityContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kActivityWidth, kActivityHeight)];
#if !__has_feature(objc_arc)
	[activityContainer autorelease];
#endif
	[activityContainer setCenter:[self getPositionFor:position toast:activityContainer]];
	[activityContainer setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
	[activityContainer setAlpha:0.0];
	[activityContainer setTag:kActivityTag];
	[activityContainer setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
	[activityContainer.layer setCornerRadius:kCornerRadius];
	if (kDisplayShadow) {
		[activityContainer.layer setShadowColor:[UIColor blackColor].CGColor];
		[activityContainer.layer setShadowOpacity:0.8];
		[activityContainer.layer setShadowRadius:6.0];
		[activityContainer.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
	}
	
	UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
#if !__has_feature(objc_arc)
	[activityView autorelease];
#endif
	[activityView setCenter:CGPointMake(activityContainer.bounds.size.width / 2, activityContainer.bounds.size.height / 2)];
	[activityContainer addSubview:activityView];
	[activityView startAnimating];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kFadeDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[activityContainer setAlpha:1.0];
	[UIView commitAnimations];
	
	[self addSubview:activityContainer];
}

- (void)hideToastActivity {
	UIView *existingToast = [self viewWithTag:kActivityTag];
	if (existingToast != nil) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:kFadeDuration];
		[UIView setAnimationDelegate:existingToast];
		[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[existingToast setAlpha:0.0];
		[UIView commitAnimations];
	}
}

#pragma mark - Animation Delegate Method

- (void)animationDidStop:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
#if !__has_feature(objc_arc)
	UIView *toast = (UIView *)context;
#else
	UIView *toast = (UIView *)(__bridge id)context;
#endif
	
	// retrieve the display interval associated with the view
	CGFloat interval = [(NSNumber *)objc_getAssociatedObject(toast, &kDurationKey) floatValue];
	
	if([animationID isEqualToString:@"fade_in"]) {
		
#if !__has_feature(objc_arc)
		[UIView beginAnimations:@"fade_out" context:toast];
#else
		[UIView beginAnimations:@"fade_out" context:(__bridge void*)toast];
#endif
		[UIView setAnimationDelay:interval];
		[UIView setAnimationDuration:kFadeDuration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[toast setAlpha:0.0];
		[UIView commitAnimations];
		
	} else if ([animationID isEqualToString:@"fade_out"]) {
		
		[toast removeFromSuperview];
		
	}
	
}

#pragma mark - Private Methods

- (CGPoint)getPositionFor:(id)point toast:(UIView *)toast {
	// Convert string literals @"top", @"bottom", @"center", or any point wrapped in an
	// NSValue object into a CGPoint
	
	if([point isKindOfClass:[NSString class]]) {
		
		if( [point caseInsensitiveCompare:@"top"] == NSOrderedSame ) {
			return CGPointMake(self.bounds.size.width/2, (toast.frame.size.height / 2) + kVerticalPadding);
		} else if( [point caseInsensitiveCompare:@"bottom"] == NSOrderedSame ) {
			return CGPointMake(self.bounds.size.width/2, (self.bounds.size.height - (toast.frame.size.height / 2)) - kVerticalPadding);
		} else if( [point caseInsensitiveCompare:@"center"] == NSOrderedSame ) {
			return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
		}
		
	} else if ([point isKindOfClass:[NSValue class]]) {
		return [point CGPointValue];
	}
	
	NSLog(@"Error: Invalid position for toast.");
	return [self getPositionFor:kDefaultPosition toast:toast];
}

- (UIView *)makeViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image {
	// sanity
	if((message == nil) && (title == nil) && (image == nil)) return nil;
	
	// Dynamically build a toast view with any combination of message, title, & image.
	UILabel *messageLabel = nil;
	UILabel *titleLabel = nil;
	UIImageView *imageView = nil;
	
	// create the parent view
	UIView *wrapperView = [[UIView alloc] init];
#if !__has_feature(objc_arc)
	[wrapperView autorelease];
#endif
	[wrapperView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
	[wrapperView.layer setCornerRadius:kCornerRadius];
	if (kDisplayShadow) {
		[wrapperView.layer setShadowColor:[UIColor blackColor].CGColor];
		[wrapperView.layer setShadowOpacity:0.8];
		[wrapperView.layer setShadowRadius:6.0];
		[wrapperView.layer setShadowOffset:CGSizeMake(4.0, 4.0)];
	}
	
	[wrapperView setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:kOpacity]];
	
	if(image != nil) {
		imageView = [[UIImageView alloc] initWithImage:image];
#if !__has_feature(objc_arc)
		[imageView autorelease];
#endif
		[imageView setContentMode:UIViewContentModeScaleAspectFit];
		[imageView setFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kImageWidth, kImageHeight)];
	}
	
	CGFloat imageWidth, imageHeight, imageLeft;
	
	// the imageView frame values will be used to size & position the other views
	if(imageView != nil) {
		imageWidth = imageView.bounds.size.width;
		imageHeight = imageView.bounds.size.height;
		imageLeft = kHorizontalPadding;
	} else {
		imageWidth = imageHeight = imageLeft = 0.0;
	}
	
	if (title != nil) {
		titleLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
		[titleLabel autorelease];
#endif
		[titleLabel setNumberOfLines:kMaxTitleLines];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:kFontSize]];
		[titleLabel setTextAlignment:NSTextAlignmentCenter];
		[titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[titleLabel setTextColor:[UIColor whiteColor]];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setAlpha:1.0];
		[titleLabel setText:title];
		
		// size the title label according to the length of the text
		
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
		CGSize expectedSizeTitle = [title
									  boundingRectWithSize:CGSizeMake(260, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin)
									  attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:kFontSize]} context:nil].size;
#else
		CGSize maxSizeTitle = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
		CGSize expectedSizeTitle = [title sizeWithFont:titleLabel.font constrainedToSize:maxSizeTitle lineBreakMode:titleLabel.lineBreakMode];
#endif
		
		[titleLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height)];
	}
	
	if (message != nil) {
		messageLabel = [[UILabel alloc] init];
#if !__has_feature(objc_arc)
		[messageLabel autorelease];
#endif
		[messageLabel setNumberOfLines:kMaxMessageLines];
		[messageLabel setFont:[UIFont systemFontOfSize:kFontSize]];
		[messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[messageLabel setTextAlignment:NSTextAlignmentJustified];
		[messageLabel setTextColor:[UIColor whiteColor]];
		[messageLabel setBackgroundColor:[UIColor clearColor]];
		[messageLabel setAlpha:1.0];
		[messageLabel setText:message];
		
		
#if  __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
		CGSize expectedSizeMessage = [message
									  boundingRectWithSize:CGSizeMake(260, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin)
									  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kFontSize]} context:nil].size;
#else
		CGSize maxSizeMessage = CGSizeMake((self.bounds.size.width * kMaxWidth) - imageWidth, self.bounds.size.height * kMaxHeight);
		
		CGSize expectedSizeMessage = [message sizeWithFont:messageLabel.font constrainedToSize:maxSizeMessage lineBreakMode:messageLabel.lineBreakMode];
#endif
		
		// size the message label according to the length of the text
		[messageLabel setFrame:CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height)];
	}
	
	// titleLabel frame values
	CGFloat titleWidth, titleHeight, titleTop, titleLeft;
	
	if(titleLabel != nil) {
		titleWidth = titleLabel.bounds.size.width;
		titleHeight = titleLabel.bounds.size.height;
		titleTop = kVerticalPadding;
		titleLeft = imageLeft + imageWidth + kHorizontalPadding;
	} else {
		titleWidth = titleHeight = titleTop = titleLeft = 0.0;
	}
	
	// messageLabel frame values
	CGFloat messageWidth, messageHeight, messageLeft, messageTop;
	
	if(messageLabel != nil) {
		messageWidth = messageLabel.bounds.size.width;
		messageHeight = messageLabel.bounds.size.height;
		messageLeft = imageLeft + imageWidth + kHorizontalPadding;
		messageTop = titleTop + titleHeight + kVerticalPadding;
	} else {
		messageWidth = messageHeight = messageLeft = messageTop = 0.0;
	}
	
	
	CGFloat longerWidth = MAX(titleWidth, messageWidth);
	CGFloat longerLeft = MAX(titleLeft, messageLeft);
	
	// wrapper width uses the longerWidth or the image width, whatever is larger. same logic applies to the wrapper height
	CGFloat wrapperWidth = MAX((imageWidth + (kHorizontalPadding * 2)), (longerLeft + longerWidth + kHorizontalPadding));
	CGFloat wrapperHeight = MAX((messageTop + messageHeight + kVerticalPadding), (imageHeight + (kVerticalPadding * 2)));
	
	[wrapperView setFrame:CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight)];
	
	if(titleLabel != nil) {
		[titleLabel setFrame:CGRectMake(titleLeft, titleTop, titleWidth, titleHeight)];
		[wrapperView addSubview:titleLabel];
	}
	
	if(messageLabel != nil) {
		[messageLabel setFrame:CGRectMake(messageLeft, messageTop, messageWidth, messageHeight)];
		[wrapperView addSubview:messageLabel];
	}
	
	if(imageView != nil) {
		[wrapperView addSubview:imageView];
	}
	
	return wrapperView;
}

@end