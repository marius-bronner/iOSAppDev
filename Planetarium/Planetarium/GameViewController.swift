//
//  GameViewController.swift
//  Planetarium
//
//  Created by iOS Application Design 19/20, Group 4 on 01.11.19.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    private let scene = SCNScene()
    
    private var planets: [SCNNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initScene()
    }
    
    /// initializes the scene
    func initScene() {
        // setup the skybox of the scene
        scene.background.contents = [
            "skyboxRT.png",
            "skyboxLF.png",
            "skyboxUP.png",
            "skyboxDN.png",
            "skyboxFT.png",
            "skyboxBK.png",
        ]

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 30, z: 0)
        cameraNode.eulerAngles = SCNVector3(x: -Float.pi / 2, y: 0, z: 0)
        
        // create and add a dim ambient light to the scene,
        // so the parts of the planets that aren't illuminated
        // by the sun can be seen
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        ambientLightNode.light!.intensity = 250
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        scnView.antialiasingMode = .multisampling4X
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // SET THIS TO TRUE to show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // add the sun
        // this is the geometry ...
        let sun_geo = SCNSphere(radius: 2)
        sun_geo.firstMaterial?.emission.contents = UIImage(named: "sun_texture.jpg")
        sun_geo.segmentCount = 64
        
        // ... and this is the scene node
        let sun = SCNNode(geometry: sun_geo)
        sun.name = "sun"
        scene.rootNode.addChildNode(sun)
        
        // configure the sun's light
        sun.light = SCNLight()
        sun.light!.type = .omni
        sun.light!.color = UIColor(red: 1, green: 0.9, blue: 0.8, alpha: 1)
        sun.light!.intensity = 2000
        
        // fill the scene with some planets!
        loadPlanets()
    }
    
    // (re)loads the planets in the scene
    func loadPlanets() {
        // remove all planets that are currently in the scene - if there are any
        unloadPlanets()
        
        // load planetary data
        // (ok, we don't actually load planetary data, we do this for demo reasons ;)
        
        // === MAIN THREAD BUG HERE ===
//        let url = URL(string: "http://slowwly.robertomurray.co.uk/delay/5000/url/https://nssdc.gsfc.nasa.gov/planetary/factsheet/")!
//
//        var req = URLRequest(url: url)
//        req.httpMethod = "GET"
//
//        var res: URLResponse?
//
//        try? NSURLConnection.sendSynchronousRequest(req, returning: &res)

        // create some new planets
        
        createPlanetWithTrajectory(name: "mercury", radius: 0.66, trajectoryRadius: 4, content: UIImage(named: "mercury_texture.jpg"))
        
        createPlanetWithTrajectory(name: "venus", radius: 0.9, trajectoryRadius: 7, content: UIImage(named: "venus_texture.jpg"))
        
        createPlanetWithTrajectory(name: "earth", radius: 1, trajectoryRadius: 10, content: UIImage(named: "earth_texture.png"))
        
        createPlanetWithTrajectory(name: "mars", radius: 0.75, trajectoryRadius: 15, content: UIImage(named: "mars_texture.jpg"))
        
        createPlanetWithTrajectory(name: "jupiter", radius: 1.5, trajectoryRadius: 23, content: UIImage(named: "jupiter_texture.jpg"))
        
        createPlanetWithTrajectory(name: "pluto", radius: 0.25, trajectoryRadius: 30, content: UIImage(named: "pluto_texture.png"))
    }
    
    // deletes all planets in the scene
    func unloadPlanets() {
        // === ARRAY BUG HERE ===
//        var index = 0
//        while index < planets.count {
//            planets[index].removeFromParentNode()
//            planets.remove(at: index)
//            index += 1
//        }
        
        // === BUGFIX ===
        for planet in planets {
            planet.removeFromParentNode()
        }
        planets.removeAll()
    }
    
    /// Creates and adds a new planet with its trajectory to the scene.
    ///
    /// - Parameters:
    ///     - name: Name of the planet (used for the name of the corresponding SCNNode)
    ///     - radius: Radius of the planet
    ///     - trajectoryRadius: Radius of the planet's trajectory along the sun. The speed with which the planet circles around the sun is also calculated by this.
    ///     - content: Texture of the planet
    func createPlanetWithTrajectory(name: String, radius: CGFloat, trajectoryRadius: CGFloat, content: Any? = nil) {
        // Create the planet geometry
        let planet_shape = SCNSphere(radius: radius)
        planet_shape.firstMaterial?.diffuse.contents = content
        planet_shape.segmentCount = 64
        
        // Create the planet node
        let planet_node = SCNNode(geometry: planet_shape)
        
        // Place it on its trajectory
        planet_node.position = SCNVector3(x: 0, y: 0, z: -Float(trajectoryRadius))
        
        // Wrap the planet node into another node.
        // This is needed so that the planet can later be rotated around the sun.
        let rotation_wrapper = SCNNode()
        rotation_wrapper.addChildNode(planet_node)
        
        // Create the visualization of the planet's trajectory
        let traj_shape = SCNTube(innerRadius: trajectoryRadius - 0.05, outerRadius: trajectoryRadius, height: 0.05)
        traj_shape.firstMaterial?.emission.contents = UIColor.white
        traj_shape.radialSegmentCount = 64
        
        let traj_node = SCNNode(geometry: traj_shape)
        traj_node.opacity = 0.25
        
        // Create the node that will hold both the planet and the trajectory visualization,
        // then place it on the scene
        let planet_with_trajectory = SCNNode()
        planet_with_trajectory.name = name
        planet_with_trajectory.addChildNode(rotation_wrapper)
        planet_with_trajectory.addChildNode(traj_node)
        scene.rootNode.addChildNode(planet_with_trajectory)
        
        // Add the planet to the planet list so that it can be easily accessed later
        planets.append(planet_with_trajectory)
        
        // Configure and start the rotation animation
        rotatePlanet(wrapper: rotation_wrapper, planet: planet_node, time: TimeInterval(trajectoryRadius))
    }
    
    /// Configures and starts a new planet's rotation animation
    func rotatePlanet(wrapper: SCNNode, planet: SCNNode, time: TimeInterval) {
        // This is the animation action
        let rotate = SCNAction.rotateBy(x: 0, y: 2 * CGFloat.pi, z: 0, duration: time)
        rotate.timingMode = .linear
        // Configure the rotation to be repeated indefinitiely
        let forever = SCNAction.repeatForever(rotate)
        
        // Then apply the action to both the wrapper and the planet.
        // That way, the planet rotates around the sun and around its own y-axis.
        wrapper.runAction(forever)
        planet.runAction(forever)
    }
    
    // handles the tap gesture.
    // In our case, the planets should be reloaded when a tap is recognized.
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        loadPlanets()
    }
    
    // Show the app in full screen
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
