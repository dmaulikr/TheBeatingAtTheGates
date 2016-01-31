//
//  SkeletonEntity.swift
//  The Beating at the Gates
//
//  Created by Grant Butler on 1/30/16.
//  Copyright © 2016 Grant J. Butler. All rights reserved.
//

import GameplayKit
import SpriteKit

enum WhatsAhead {
    case Empty
    case Friendly
    case Enemy(GKEntity)
}

public class SkeletonEntity: GKEntity, EntityType, MovementRulesComponentDelegate {
	
	var renderComponent: RenderComponent {
		guard let renderComponent = componentForClass(RenderComponent.self) else { fatalError("A SkeletonEntity must have a RenderComponent.") }
		return renderComponent
	}
    
    var movementRulesComponent: MovementRulesComponent
    var intelligenceComponent: IntelligenceComponent
	
	public let team: Team
	
	var size: EntitySize {
		return .OneByOne
	}
	
	public init(team: Team) {
		self.team = team
		
        intelligenceComponent = IntelligenceComponent(states: [
            MonsterIdleState(),
            MonsterMoveState(),
            MonsterAttackState()
            ])
        
        var rules: [GKRule] = []
        
        let enemyPredicate = NSPredicate(format: "$forwardIsEnemy==true")
        let enemyRule = GKRule(predicate: enemyPredicate, assertingFact: "attack", grade: 1.0)
        rules.append(enemyRule)
        
        let emptyPredicate = NSPredicate(format: "$forwardIsEmpty==true")
        let emptyRule = GKRule(predicate: emptyPredicate, assertingFact: "move", grade: 1.0)
        rules.append(emptyRule)
        
        movementRulesComponent = MovementRulesComponent(rules: rules)
        
        
		super.init()
		
        let healthComponent = HealthComponent(health: 10)
        
        addComponent(healthComponent)
        
		let renderComponent = RenderComponent(entity: self)
		addComponent(renderComponent)
		
		let orientationComponent = OrientationComponent(node: renderComponent.node)
		orientationComponent.direction = team.direction
		addComponent(orientationComponent)
		
		
		addComponent(intelligenceComponent)
        addComponent(movementRulesComponent)
        
        
        movementRulesComponent.delegate = self
		
		let spriteNode = SKSpriteNode(imageNamed: "\(team)Skeleton")
		renderComponent.node.addChild(spriteNode)
	}
    
    public func rulesComponent(rulesComponent: MovementRulesComponent, didFinishEvaluatingRuleSystem ruleSystem: GKRuleSystem) {
        if ruleSystem.gradeForFact("attack") == 1.0 {
            self.intelligenceComponent.stateMachine.enterState(MonsterAttackState.self)
        }
        if ruleSystem.gradeForFact("move") == 1.0 {
            self.intelligenceComponent.stateMachine.enterState(MonsterMoveState.self)
        }
    }
    
    func lookAhead() -> WhatsAhead {
        let point = ahead()
        let unknownNode = self.renderComponent.node.parent?.nodeAtPoint(point)
        guard let node =  unknownNode?.parent as? EntityNode else {
            return .Empty
        }
        guard let entity = node.entity as? SkeletonEntity else {
            return .Empty
        }
        if entity.team == self.team {
            return .Friendly
        } else {
            return .Enemy(entity)
        }
    }
    
    
    public override func updateWithDeltaTime(seconds: NSTimeInterval) {
        guard let state = self.intelligenceComponent.stateMachine.currentState else {
            return
        }
        defer {
            self.intelligenceComponent.enterInitialState()
        }
        if let _ = state as? MonsterMoveState {
            self.renderComponent.node.position = ahead()
        }
        else if let _ = state as? MonsterAttackState {
            let enemyAhead = lookAhead()
            switch enemyAhead{
            case .Enemy(let entity):
                let healthComponent = entity.componentForClass(HealthComponent.self)
                healthComponent?.damage(1)
            default:
                return
            }
            if let health = self.componentForClass(HealthComponent.self) where health.isDead() {
                self.renderComponent.node.removeFromParent()
                
            }
        }
    }
    
    public func ahead() -> CGPoint {
        let currentX = self.renderComponent.node.position.x
        var deltaX = self.renderComponent.node.children.first!.frame.width
        if self.team.direction == .Left {
            deltaX *= -1
        }
        let x = currentX + deltaX
        return CGPoint(x: x, y: self.renderComponent.node.position.y)
    }

	
}
