//
//  GameViewController.swift
//  Planetarium
//
//  Created by iOS Application Design 19/20, Group 4 on 01.11.19.
//

import UIKit
import QuartzCore
import SceneKit
import os.signpost

class GameViewController: UIViewController {
    
    @IBOutlet weak var loader: UIVisualEffectView!
    @IBOutlet weak var scnView: SCNView!

    private let scene = SCNScene()
    
    private var planets: [Planet] = []

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
        
        // configure the SCNView
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
        // ===!===
        // loadPlanets(offset: 0)
        // comment the line below!
        setupTimer()
    }
    
    let log = OSLog(subsystem: "planetarium-renderer", category: .pointsOfInterest)
    
    // (re)loads the planets in the scene
    func loadPlanets(offset: TimeInterval) {
        os_signpost(.begin, log: log, name: "loadPlanets")

        // remove all planets that are currently in the scene - if there are any
        unloadPlanets()

        // create some new planets
        
        addPlanetToScene(Planet(
            name: "mercury",
            radius: 0.66,
            trajectoryRadius: 4,
            content: UIImage(named: "mercury_texture.jpg"),
            offset: offset
        ))
        
        addPlanetToScene(Planet(
            name: "venus",
            radius: 0.9,
            trajectoryRadius: 7,
            content: UIImage(named: "venus_texture.jpg"),
            offset: offset
        ))
        
        addPlanetToScene(Planet(
            name: "earth",
            radius: 1,
            trajectoryRadius: 10,
            content: UIImage(named: "earth_texture.png"),
            offset: offset
        ))
        
        addPlanetToScene(Planet(
            name: "mars",
            radius: 0.75,
            trajectoryRadius: 15,
            content: UIImage(named: "mars_texture.jpg"),
            offset: offset
        ))
        
        addPlanetToScene(Planet(
            name: "jupiter",
            radius: 1.5,
            trajectoryRadius: 23,
            content: UIImage(named: "jupiter_texture.jpg"),
            offset: offset
        ))
        
        addPlanetToScene(Planet(
            name: "pluto",
            radius: 0.25,
            trajectoryRadius: 30,
            content: UIImage(named: "pluto_texture.png"),
            offset: offset
        ))
        
        os_signpost(.end, log: log, name: "loadPlanets")
    }
    
    func addPlanetToScene(_ planet: Planet) {
        planets.append(planet)
        
        // === UNNECESSARRY PLANET RELOAD BUG HERE ===
//        updatePlanetsInScene()
        
        // === BUGFIX HERE ===
        planet.createAndAdd(to: scene.rootNode)
    }
    
    func updatePlanetsInScene() {
        for planet in planets {
            planet.createAndAdd(to: scene.rootNode)
        }
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
    
    // handles the tap gesture.
    // In our case, the planets should be reloaded when a tap is recognized.
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // loadPlanets()
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
    
    func setupTimer() {
        let startTime = NSDate.timeIntervalSinceReferenceDate
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let time = NSDate.timeIntervalSinceReferenceDate - startTime
            self.loadPlanets(offset: time)
        }
        
    }

}
