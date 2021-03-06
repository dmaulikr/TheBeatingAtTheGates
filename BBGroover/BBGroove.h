//
//  BBGroove.h
//  BeatBuilder
//
//  Created by Parker Wightman on 7/25/12.
//  Copyright (c) 2012 Parker Wightman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BBGroover/BBVoice.h>
#import <BBGroover/BBGrooverBeat.h>

NS_ASSUME_NONNULL_BEGIN

@interface BBGroove : NSObject

@property (nonatomic, strong) NSArray <BBVoice *>	*voices;
@property (nonatomic, assign) NSUInteger			tempo;
@property (nonatomic, assign) BBGrooverBeat			beatUnit;
@property (nonatomic, assign) NSUInteger			beats;

#pragma mark Convenience Constructors
+ (instancetype)groove;

#pragma mark Instance Methods
- (void)addVoice:(BBVoice *)object;
- (BBGrooverBeat)maxSubdivision;

@end

NS_ASSUME_NONNULL_END
