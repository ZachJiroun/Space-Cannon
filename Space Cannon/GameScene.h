//
//  GameScene.h
//  Space Cannon
//

//  Copyright (c) 2015 Zach Jiroun. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>

@property (nonatomic) int ammo;
@property (nonatomic) int score;

@end
