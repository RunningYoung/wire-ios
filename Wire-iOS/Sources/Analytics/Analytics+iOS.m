// 
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
// 


#import "Analytics+iOS.h"
#import "Analytics+Metrics.h"
#import "AnalyticsLocalyticsProvider.h"
#import <AVSFlowManager.h>
#import "Settings.h"


@implementation Analytics (iOS)

+ (instancetype)shared
{
    static Analytics *sharedAnalytics = nil;
    BOOL useAnalytics = USE_ANALYTICS;
    // Don’t track events in debug configuration.
    if (useAnalytics && ![[Settings sharedSettings] disableAnalytics]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            AnalyticsLocalyticsProvider *provider = [AnalyticsLocalyticsProvider new];
            sharedAnalytics = [[Analytics alloc] initWithProvider:provider];
        });
    }
    else {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self updateAVSMetricsSettingsWithActiveProvider:nil];
        });
    }
    
    return sharedAnalytics;
}

@end
