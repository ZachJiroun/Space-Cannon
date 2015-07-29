//
//  GameScene.m
//  Space Cannon
//
//  Created by Zach Jiroun on 7/27/15.
//  Copyright (c) 2015 Zach Jiroun. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene
{
    SKNode *_mainLayer;
    SKSpriteNode *_cannon;
    BOOL _didShoot;
}

static const CGFloat kShootSpeed = 1000.f;
static const CGFloat kHaloLowAngle = 200.0 * M_PI / 180.0;
static const CGFloat kHaloHighAngle = 340.0 * M_PI / 180.0;
static const CGFloat kHaloSpeed = 100.0;

static inline CGVector radiansToVector(CGFloat radians)
{
    CGVector vector;
    vector.dx = cosf(radians);
    vector.dy = sinf(radians);
    return vector;
}

static inline CGFloat randomInRange(CGFloat low, CGFloat high)
{
    CGFloat value = arc4random_uniform(UINT32_MAX) / (CGFloat)UINT32_MAX;
    return value * (high - low) + low;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */

    // Turn off gravity
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
    
    // Add background
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Starfield"];
    background.size = self.size;
    background.anchorPoint = CGPointZero;
    background.blendMode = SKBlendModeReplace;
    [self addChild:background];
    
    // Add edges
    SKNode *leftEdge = [[SKNode alloc] init];
    leftEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    leftEdge.position = CGPointZero;
    [self addChild:leftEdge];
    
    SKNode *rightEdge = [[SKNode alloc] init];
    rightEdge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.0, self.size.height)];
    rightEdge.position = CGPointMake(self.size.width, 0.0);
    [self addChild:rightEdge];
    
    // Add main layer
    _mainLayer = [[SKNode alloc] init];
    [self addChild:_mainLayer];
    
    // Add cannon
    _cannon = [SKSpriteNode spriteNodeWithImageNamed:@"Cannon"];
    _cannon.position = CGPointMake(self.size.width * 0.5, 0.0);
    [_mainLayer addChild:_cannon];
    
    // Create cannon rotation actions.
    SKAction *rotateCannon = [SKAction sequence:@[[SKAction rotateByAngle:M_PI duration:2], [SKAction rotateByAngle:-M_PI duration:2]]];
    [_cannon runAction:[SKAction repeatActionForever:rotateCannon]];
    
    // Create spawn halo actions
    SKAction *spawnHalo = [SKAction sequence:@[[SKAction waitForDuration:2 withRange:1], [SKAction performSelector:@selector(spawnHalo) onTarget:self]]];
    [self runAction:[SKAction repeatActionForever:spawnHalo]];
}

-(void)shoot
{
    // Create a ball node
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"Ball"];
    ball.name = @"ball";
    CGVector rotationVector = radiansToVector(_cannon.zRotation);
    ball.position = CGPointMake(_cannon.position.x + (_cannon.size.width * 0.5 * rotationVector.dx), (_cannon.size.width * 0.5 * rotationVector.dy));
    [_mainLayer addChild:ball];
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:6.0];
    ball.physicsBody.velocity = CGVectorMake(rotationVector.dx * kShootSpeed, rotationVector.dy * kShootSpeed);
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.linearDamping = 0.0;
    ball.physicsBody.friction = 0.0;
}

-(void)spawnHalo
{
    // Create halo node
    SKSpriteNode *halo = [SKSpriteNode spriteNodeWithImageNamed:@"Halo"];
    halo.position = CGPointMake(randomInRange(halo.size.width * 0.5, self.size.width - (halo.size.width * 0.5)), self.size.height + (halo.size.height * 0.5));
    halo.physicsBody= [SKPhysicsBody bodyWithCircleOfRadius:16.0];
    CGVector direction = radiansToVector(randomInRange(kHaloLowAngle, kHaloHighAngle));
    halo.physicsBody.velocity = CGVectorMake(direction.dx * kHaloSpeed, direction.dy * kHaloSpeed);
    halo.physicsBody.restitution = 1.0;
    halo.physicsBody.linearDamping = 0.0;
    halo.physicsBody.friction = 0.0;
    [self addChild:halo];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        _didShoot = YES;
    }
}

-(void)didSimulatePhysics
{
    // Shoot
    if (_didShoot) {
        [self shoot];
        _didShoot = NO;
    }
    
    // Remove unused nodes
    [_mainLayer enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (!CGRectContainsPoint(self.frame, node.position)) {
            [node removeFromParent];
        }
    }];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
