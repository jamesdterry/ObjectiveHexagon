//
//  HKHexagon.m
//  ObjectiveHexagon
//
//  Created by Denis Tretyakov on 23.02.15.
//  Copyright (c) 2015 pythongem. All rights reserved.
//

#import "HKHexagon.h"
#import "HKHexagonGrid.h"

@implementation HKHexagon

/// MARK: - Init

- (instancetype) initWithCoordinate:(HKHexagonCoordinate3D)coordinate grid:(HKHexagonGrid *)grid {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.grid = grid;
    }
    return self;
}
+ (instancetype) hexagonWithCoordinate:(HKHexagonCoordinate3D)coordinate grid:(HKHexagonGrid *)grid {
    return [[HKHexagon alloc] initWithCoordinate:coordinate grid:grid];
}
+ (instancetype) hexagonWithCoordinate:(HKHexagonCoordinate3D)coordinate {
    return [[HKHexagon alloc] initWithCoordinate:coordinate grid:nil];
}

- (NSString *)description  {
    return [NSString stringWithFormat:@"Hexagon: %@", self.hash];
}

/// MARK: -  Properties

- (NSString *) hash {
    return NSStringFromHexCoordinate3D(self.coordinate);
}

- (BOOL)valid {
    return self.coordinate.x + self.coordinate.y + self.coordinate.z == 0.0;
}

- (CGRect)frame {
    CGFloat minX = MAXFLOAT;
    CGFloat minY = MAXFLOAT;
    CGFloat maxX = -MAXFLOAT;
    CGFloat maxY = -MAXFLOAT;
    
    for (NSValue *value in self.vertices) {
        CGPoint p = [value CGPointValue];
        if (p.x < minX) { minX = p.x; }
        if (p.y < minY) { minY = p.y; }
        if (p.x > maxX) { maxX = p.x; }
        if (p.y > maxY) { maxY = p.y; }
    }
    
    return CGRectMake(minX, minY, fabs(maxX-minX), fabs(maxY-minY));
}

- (CGRect)bounds {
    CGPoint offsetPoint = CGPointMake(-self.frame.origin.x, -self.frame.origin.y);
    return CGRectOffset(self.frame, offsetPoint.x, offsetPoint.y);
}

- (CGPoint)center {
    
    HKHexagonCoordinate2D hex = hexConvertCubeToAxial(self.coordinate);
    CGPoint s = CGPointZero;
    
    if (self.grid.hexOrientation == HKHexagonGridOrientationPointy) {
        s = CGPointMake(SQRT_3 * hex.q + SQRT_3_2 * hex.r, 1.5 * hex.r);
    } else {
        s = CGPointMake(1.5 * hex.q, SQRT_3_2 * hex.q + SQRT_3 * hex.r);
    }
    
    s = CGPointMultiply(s, self.grid.hexSize);
    return CGPointAdd(s, self.grid.screenCenter);
}

- (NSArray *)vertices {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:6];
    for (NSUInteger i=0; i<6; i++) {
        CGFloat orVal = self.grid.hexOrientation == HKHexagonGridOrientationPointy ? 1 : 0;
        CGFloat angle = 2 * M_PI / 12 * (2 * i - orVal);
        CGFloat x = self.grid.hexSize * cosf(angle);
        CGFloat y = self.grid.hexSize * sinf(angle);
        CGPoint p = CGPointMake(x, y);
        p = CGPointAdd(p, self.center);
        [result addObject:[NSValue valueWithCGPoint:p]];
    }
    return result;
}

@end