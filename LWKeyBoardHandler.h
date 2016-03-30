//
//  LWKeyBoardHandler.h
//  KeyBoradTestDemo
//
//  Created by HotelGGmin on 16/2/26.
//  Copyright © 2016年 Leo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWKeyBoardHandler : NSObject

- (void)resignFirstResponder;
- (void)addKeyBoardObserver;
- (void)removeKeyBoardObserver;

@end
