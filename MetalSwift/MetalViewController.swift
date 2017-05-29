//
//  MetalViewController.swift
//  MetalSwift
//
//  Created by Danny on 5/28/17.
//  Copyright © 2017 Danny. All rights reserved.
//

//https://www.raywenderlich.com/137398/ios-metal-tutorial-swift-part-5-switching-metalkit

/**
In this 5th part, you’ll learn how to update your app to take advantage of the MetalKit framework. In addition, you’ll also be updating the app to use the SIMD (pronounced “sim-dee”) framework for 3D-related math. 
 */

/**
 MetalKit provides three major pieces of functionality:
 
 Texture loading: Allows you to easily load image assets into Metal textures using a MTKTextureLoader.
 
 View management: Reduces the amount of code you need to get Metal to render something on-screen via MTKView.

 Model I/O integration: Allows you to efficiently load model assets into Metal buffers and manage mesh data using built-in containers.
 
 In this tutorial, you’ll be focusing on texture loading and view management. Model I/O integration will be the subject of a future part in the series.
 */


import UIKit
import MetalKit
import simd

protocol MetalViewControllerDelegate: class {
    func updateLogic(timeSinceLastUpdate:CFTimeInterval)
    func renderObjects(drawable:CAMetalDrawable)

}
class MetalViewController: UIViewController {

    var device:MTLDevice!
//    var metalLayer: CAMetalLayer!
    
    var pipelineState : MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
//    var timer:CADisplayLink!
    var projectionMatrix:float4x4!
//    var lastFrameTimestamp: CFTimeInterval = 0.0
    
    weak var metalViewControllerDelegate:MetalViewControllerDelegate?
    var textureLoader:MTKTextureLoader! = nil
    
    @IBOutlet var mtkView: MTKView!{
        didSet {
            mtkView.delegate = self
            mtkView.preferredFramesPerSecond = 60
            mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        device = MTLCreateSystemDefaultDevice()
        
//        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)

        textureLoader = MTKTextureLoader(device: device)
        mtkView.device = device
        
//        metalLayer = CAMetalLayer()
//        metalLayer.device = device
//        metalLayer.pixelFormat = .bgra8Unorm
//        metalLayer.framebufferOnly = true
////        metalLayer.frame = view.layer.frame
//        view.layer.addSublayer(metalLayer)

        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary?.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
     //   An instance of MTKView, by default, will ask for redraws periodically.  So you can remove all the code that sets up a CADisplayLink.
//        timer = CADisplayLink(target: self, selector: #selector(MetalViewController.newFrame(displayLink:)))
//        timer.add(to: RunLoop.main, forMode: .defaultRunLoopMode)

    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        if let window = view.window{
//            let scale = window.screen.nativeScale
//            let layerSize = view.bounds.size
//            
//            view.contentScaleFactor = scale
//            metalLayer.frame = CGRect(x: 0, y: 0, width: layerSize.width, height: layerSize.height)
//            metalLayer.drawableSize = CGSize(width: layerSize.width * scale, height: layerSize.height * scale)
//        }
//    }

    func render(_ drawable:CAMetalDrawable?) {
        guard let drawable = drawable else {return}
      self.metalViewControllerDelegate?.renderObjects(drawable: drawable)
    }
    
//    func newFrame(displayLink:CADisplayLink) {
//        if lastFrameTimestamp == 0.0{
//            lastFrameTimestamp = displayLink.timestamp
//        }
//        
//        let elapsed : CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
//        lastFrameTimestamp = displayLink.timestamp
//        
//        gameloop(timeSinceLastUpdate: elapsed)
//    }
//    
//    func gameloop(timeSinceLastUpdate:CFTimeInterval) {
//        self.metalViewControllerDelegate?.updateLogic(timeSinceLastUpdate: timeSinceLastUpdate)
//        autoreleasepool{
//            self.render()
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MetalViewController:MTKViewDelegate{
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        projectionMatrix = float4x4.makePerspectiveViewAngle(float4x4.degrees(toRad: 85.0), aspectRatio: Float(view.bounds.width/view.bounds.height), nearZ: 0.01, farZ: 100.0)
    }
    func draw(in view: MTKView) {
        render(view.currentDrawable)
    }
}
