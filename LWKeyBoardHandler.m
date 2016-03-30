//
//  LWKeyBoardHandler.m
//  KeyBoradTestDemo
//
//  Created by HotelGGmin on 16/2/26.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import "LWKeyBoardHandler.h"

@interface LWKeyBoardHandler () <UIGestureRecognizerDelegate>

@property (nonatomic, weak  ) UIView                    *textFieldView;
@property (nonatomic, assign) float                     keyboardHeight;
@property (nonatomic, assign) CGSize                    kbSize;
@property (nonatomic, weak  ) UIScrollView              *superScrollView;
@property (nonatomic, weak  ) UIScrollView              *lastScrollView;
@property (nonatomic, assign) UIEdgeInsets              initialContentInsets;
@property (nonatomic, assign) UIEdgeInsets              initialIndicatorInsets;
@property (nonatomic, strong) UITapGestureRecognizer    *tapGesture;
@property (nonatomic, weak  ) UIWindow                  *window;

@end

@implementation LWKeyBoardHandler
{
    NSInteger _animationCurve;
    BOOL _showKeyboard;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        self.tapGesture.cancelsTouchesInView = NO;
        self.tapGesture.delegate = self;
    
        [self addKeyBoardObserver];
    }
    return self;
}

- (void)addKeyBoardObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:UITextViewTextDidEndEditingNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHiddenNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    if (_window) [_window addGestureRecognizer:self.tapGesture];
}

- (void)removeKeyBoardObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_window) [_window removeGestureRecognizer:self.tapGesture];
}

#pragma mark - textField Notification
-(void)textFieldViewDidBeginEditing:(NSNotification *)notification
{
    NSLog(@"Begin : --- textField ---");
    _textFieldView = notification.object;
    if (!_window)
    {
        _window = _textFieldView.window;
    }
    [_textFieldView.window addGestureRecognizer:self.tapGesture];
    
    _lastScrollView = _superScrollView;
    _superScrollView = [self getTableViewWithView:_textFieldView];
    
    if (_lastScrollView != _superScrollView)
    {
        _lastScrollView = _superScrollView;
        _initialContentInsets = _superScrollView.contentInset;
        _initialIndicatorInsets = _superScrollView.scrollIndicatorInsets;
    }
    
    if (!_showKeyboard && _superScrollView)
    {
        if ([_textFieldView isKindOfClass:[UITextView class]])
        {
            UIWindow *window = _textFieldView.window;
            CGRect textFieldViewFrame = [[_textFieldView superview] convertRect:_textFieldView.frame toView:window];
            float move =  CGRectGetMaxY(textFieldViewFrame) + _kbSize.height - window.frame.size.height;
            
            [UIView animateWithDuration:0.25 delay:0 options:_animationCurve animations:^{
                _superScrollView.contentInset = UIEdgeInsetsMake(_initialContentInsets.top, _initialContentInsets.left, _keyboardHeight, _initialContentInsets.right);
                _superScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(_initialIndicatorInsets.top, _initialIndicatorInsets.left, _keyboardHeight, _initialIndicatorInsets.right);
                if (move > 0)
                {
                    _superScrollView.contentOffset = CGPointMake(_superScrollView.contentOffset.x, _superScrollView.contentOffset.y+move);
                }
            } completion:^(BOOL finished) {
                _showKeyboard = YES;
            }];
        }
    }
}

- (void)textFieldViewDidEndEditing:(NSNotification *)notification
{
    NSLog(@"End   : --- textField ---");
    [_textFieldView.window removeGestureRecognizer:self.tapGesture];
    _textFieldView = nil;
    _showKeyboard = NO;
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    NSLog(@"Will show Keyboard!");
    NSDictionary *userInfo  = [notification userInfo];
    NSNumber *duration      = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    _animationCurve         = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue]<<16;
    _kbSize                 = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float height            = _kbSize.height;
    
    if (height <= 0) height = 218;
    _keyboardHeight = height;
    if (!_textFieldView) return;
    _lastScrollView = _superScrollView;
    _superScrollView = [self getTableViewWithView:_textFieldView];
    if (!_superScrollView) return;
    
    if (_lastScrollView != _superScrollView)
    {
        _lastScrollView = _superScrollView;
        _initialContentInsets = _superScrollView.contentInset;
        _initialIndicatorInsets = _superScrollView.scrollIndicatorInsets;
    }
    
    UIWindow *window = _textFieldView.window;
    CGRect textFieldViewFrame = [[_textFieldView superview] convertRect:_textFieldView.frame toView:window];
    float move =  CGRectGetMaxY(textFieldViewFrame) + _kbSize.height - window.frame.size.height;
    
    [UIView animateWithDuration:[duration floatValue]?:0.25 delay:0 options:_animationCurve animations:^{
        _superScrollView.contentInset = UIEdgeInsetsMake(_initialContentInsets.top, _initialContentInsets.left, height, _initialContentInsets.right);
        _superScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(_initialIndicatorInsets.top, _initialIndicatorInsets.left, height, _initialIndicatorInsets.right);
        if (move > 0 && [_textFieldView isKindOfClass:[UITextView class]])
        {
            _superScrollView.contentOffset = CGPointMake(_superScrollView.contentOffset.x, _superScrollView.contentOffset.y+move);
        }
    } completion:^(BOOL finished) {
        _showKeyboard = YES;
    }];
}

- (void)keyboardWillHiddenNotification:(NSNotification *)notification
{
    NSLog(@"Will hidden Keyboard!");
    
    if (!_superScrollView) return;
    NSDictionary *userInfo  = [notification userInfo];
    NSNumber *duration      = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:[duration floatValue] animations:^{
        _superScrollView.contentInset = _initialContentInsets;
        _superScrollView.scrollIndicatorInsets = _initialContentInsets;
    } completion:^(BOOL finished) {
        
    }];
    
    _superScrollView = nil;
    _lastScrollView = nil;
    _initialContentInsets   = UIEdgeInsetsZero;
    _initialIndicatorInsets = UIEdgeInsetsZero;
    _kbSize = CGSizeZero;
}

- (UIScrollView *)getTableViewWithView:(UIView *)responder
{
//    while (responder)
//    {
//        if ([responder isKindOfClass:[UITableView class]])
//        {
//            return (UITableView *)responder;
//        } else
//        {
//            responder = [responder superview];
//        }
//    }
    
    UIView *superview = responder.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:[UIScrollView class]] &&
            ([superview isKindOfClass:NSClassFromString(@"UITableViewCellScrollView")] == NO) &&
            ([superview isKindOfClass:NSClassFromString(@"UITableViewWrapperView")] == NO) &&
            ([superview isKindOfClass:NSClassFromString(@"_UIQueuingScrollView")] == NO))
        {
            return (UIScrollView *)superview;
        }
        else    superview = superview.superview;
    }
    
    return nil;
}

- (void)resignFirstResponder
{
    if (self.textFieldView && [self.textFieldView isFirstResponder])
    {
        BOOL temp = [self.textFieldView resignFirstResponder];
        if (!temp) {
            NSLog(@"reject resign!");
        } else
        {
            NSLog(@"resign First Responder!");
        }
        self.textFieldView = nil;
    }
}

- (void)tapRecognized:(UITapGestureRecognizer*)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self resignFirstResponder];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    NSLog(@"-----Simultaneously------<%@, %@>", gestureRecognizer, otherGestureRecognizer);
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")])
    {
        [self resignFirstResponder];
    }
    
    return NO;
}

/** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"touch");
    return (/*[[touch view] isKindOfClass:[UIControl class]] || */[[touch view] isKindOfClass:[UINavigationBar class]]) ? NO : YES;
}

- (void)dealloc
{
    NSLog(@"keyboardHandler dealloc!");
    if (_window) [_window removeGestureRecognizer:self.tapGesture];
    self.tapGesture.delegate = nil;
    self.tapGesture = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
