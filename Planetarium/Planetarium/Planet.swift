//
//  Planet.swift
//  Planetarium
//
//  Created by Marius Bronner on 10.11.19.
//  Copyright © 2019 Marius Bronner. All rights reserved.
//

import Foundation
import SceneKit

public class Planet {
    
    private struct SceneKitPlanetObjects {
        public let rootNode: SCNNode
        
        public let rotationWrapperNode: SCNNode

        public let planetShape: SCNSphere
        public let planetNode: SCNNode

        public let trajectoryShape: SCNTube
        public let trajectoryNode: SCNNode
    }
    
    public let name: String
    public let radius: Float
    public let trajectoryRadius: Float
    public let content: Any?
    
    public let offset: TimeInterval?
    
    public var placedOnScene: Bool {
        return objects != nil
    }
    
    private var objects: SceneKitPlanetObjects?
    
    public init(name: String, radius: Float, trajectoryRadius: Float, content: Any?, offset: TimeInterval?) {
        self.name = name
        self.radius = radius
        self.trajectoryRadius = trajectoryRadius
        self.content = content
        self.offset = offset
    }
    
    public func createAndAdd(to parent: SCNNode) {
        // make sure there isn't an old version of this planet
        // in a scene somewhere
        removeFromParentNode()
        
        // create the SceneKit planet objects
        objects = createPlanetWithTrajectory()
        
        // add them to the parent node
        parent.addChildNode(objects!.rootNode)
        
        if offset != nil {
            setInitialRotation()
        }
        
        // last but not least, configure the rotation
        // animation of the planet
        // ===!===
        // configureAnimations()
    }
    
    /// Creates the SceneKit objects for the planet and its trajectory
    private func createPlanetWithTrajectory() -> SceneKitPlanetObjects {
        // Create the planet geometry
        let planetShape = SCNSphere(radius: CGFloat(radius))
        planetShape.firstMaterial?.diffuse.contents = content
        planetShape.segmentCount = 64
        
        // Create the planet node
        let planetNode = SCNNode(geometry: planetShape)
        
        // Place it on its trajectory
        planetNode.position = SCNVector3(x: 0, y: 0, z: -Float(trajectoryRadius))
        
        // Wrap the planet node into another node.
        // This is needed so that the planet can later be rotated around the sun.
        let rotationWrapperNode = SCNNode()
        rotationWrapperNode.addChildNode(planetNode)
        
        // Create the visualization of the planet's trajectory
        let trajectoryShape = SCNTube(
            innerRadius: CGFloat(trajectoryRadius - 0.05),
            outerRadius: CGFloat(trajectoryRadius),
            height: 0.05
        )
        trajectoryShape.firstMaterial?.emission.contents = UIColor.white
        trajectoryShape.radialSegmentCount = 64
        
        let trajectoryNode = SCNNode(geometry: trajectoryShape)
        trajectoryNode.opacity = 0.25
        
        // Create the node that will hold both the planet and the trajectory visualization,
        // then place it on the scene
        let rootNode = SCNNode()
        rootNode.name = name
        rootNode.addChildNode(rotationWrapperNode)
        rootNode.addChildNode(trajectoryNode)
        
        return SceneKitPlanetObjects(
            rootNode: rootNode,
            rotationWrapperNode: rotationWrapperNode,
            planetShape: planetShape,
            planetNode: planetNode,
            trajectoryShape: trajectoryShape,
            trajectoryNode: trajectoryNode
        )
    }
    
    /// Configures and starts the planets rotation animation
    private func configureAnimations() {
        guard let objects = self.objects else {
            return
        }
        
        // This is the animation action
        let rotate = SCNAction.rotateBy(x: 0, y: 2 * CGFloat.pi, z: 0, duration: TimeInterval(trajectoryRadius))
        rotate.timingMode = .linear
        // Configure the rotation to be repeated indefinitiely
        let forever = SCNAction.repeatForever(rotate)
        
        // Then apply the action to both the wrapper and the planet.
        // That way, the planet rotates around the sun and around its own y-axis.
        objects.rotationWrapperNode.runAction(forever)
        objects.planetNode.runAction(forever)
    }
    
    private func setInitialRotation() {
        guard let offset = self.offset, let objects = self.objects else {
            return
        }
        
        let relativeOffset = (offset / Double(trajectoryRadius)).truncatingRemainder(dividingBy: 1)
        let rotationY = Float(relativeOffset * 2 * Double.pi)
        let angles = SCNVector3(x: 0, y: rotationY, z: 0)
        
        objects.planetNode.eulerAngles = angles
        objects.rotationWrapperNode.eulerAngles = angles
    }
    
    /// Removes the planet from its parent node in the scene (if it's actually in a parent node)
    public func removeFromParentNode() {
        guard let objects = self.objects else {
            return
        }

        objects.rootNode.removeFromParentNode()
        self.objects = nil
    }
}
