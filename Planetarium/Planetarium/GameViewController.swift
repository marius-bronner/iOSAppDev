//
//  GameViewController.swift
//  Planetarium
//
//  Created by Marius Bronner on 01.11.19.
//  Copyright © 2019 Marius Bronner. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    private let scene = SCNScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        // scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi / 2, y: 0, z: 0)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.light!.intensity = 250
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        // let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // scnView.addGestureRecognizer(tapGesture)
        
        let sun_geo = SCNSphere(radius: 2)
        sun_geo.firstMaterial?.emission.contents = UIImage(named: "sun_texture.jpg")
        sun_geo.segmentCount = 64
        
        let sun = SCNNode(geometry: sun_geo)
        sun.name = "sun"
        scene.rootNode.addChildNode(sun)
        
        sun.light = SCNLight()
        sun.light!.type = .omni
        sun.light!.color = UIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1)
        sun.light!.intensity = 2000
        
        createPlanetWithTrajectory(name: "mercury", radius: 0.66, trajectoryRadius: 4, content: UIImage(named: "mercury_texture.jpg"))
        
        createPlanetWithTrajectory(name: "venus", radius: 0.9, trajectoryRadius: 7, content: UIImage(named: "venus_texture.jpg"))
        
        createPlanetWithTrajectory(name: "earth", radius: 1, trajectoryRadius: 10, content: UIImage(named: "earth_texture.png"))
        
        createPlanetWithTrajectory(name: "mars", radius: 0.75, trajectoryRadius: 15, content: UIImage(named: "mars_texture.jpg"))
        
        createPlanetWithTrajectory(name: "jupiter", radius: 1.5, trajectoryRadius: 23, content: UIImage(named: "jupiter_texture.jpg"))
        
        createPlanetWithTrajectory(name: "pluto", radius: 0.25, trajectoryRadius: 30, content: UIImage(named: "pluto_texture.png"))
    }
    
    func createPlanetWithTrajectory(name: String, radius: CGFloat, trajectoryRadius: CGFloat, content: Any? = nil) -> SCNNode {
        let planet_shape = SCNSphere(radius: radius)
        planet_shape.firstMaterial?.diffuse.contents = content
        planet_shape.segmentCount = 64
        
        let planet_node = SCNNode(geometry: planet_shape)
        planet_node.name = name
        
        planet_node.position = SCNVector3(x: 0, y: 0, z: -Float(trajectoryRadius))
        
        let wrapper_node = SCNNode()
        wrapper_node.addChildNode(planet_node)
        
        scene.rootNode.addChildNode(wrapper_node)
        
        let traj_shape = SCNTube(innerRadius: trajectoryRadius - 0.05, outerRadius: trajectoryRadius, height: 0.05)
        traj_shape.firstMaterial?.emission.contents = UIColor.white
        traj_shape.radialSegmentCount = 64
        
        let traj_node = SCNNode(geometry: traj_shape)
        scene.rootNode.addChildNode(traj_node)
        
        rotatePlanet(wrapper: wrapper_node, planet: planet_node, time: TimeInterval(trajectoryRadius))
        
        return wrapper_node
    }
    
    func rotatePlanet(wrapper: SCNNode, planet: SCNNode, time: TimeInterval) {
        let rotate = SCNAction.rotateBy(x: 0, y: 2 * CGFloat.pi, z: 0, duration: time)
        rotate.timingMode = .linear
        let forever = SCNAction.repeatForever(rotate)
        wrapper.runAction(forever)
        planet.runAction(forever)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
