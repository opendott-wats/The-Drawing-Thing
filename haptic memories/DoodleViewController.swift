//
//  DoodleViewController.swift
//  haptic memories
//
//  Created by Jens Alexander Ewald on 15/12/2020.
//

import UIKit
import SwiftUI


public class DoodleViewController : UIViewController {
    var lastPoint = CGPoint.zero
    var color:UIColor = .white
    var brushWidth: CGFloat = 1.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    var rhythm: RhythmProvider!
    
    var tempImageView: UIImageView!
    var mainImageView: UIImageView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillLayoutSubviews() {
        adjustCanvas()
    }
    
    override public func updateViewConstraints() {
        adjustCanvas()
    }
    
    public func adjustCanvas() {
        tempImageView.frame = view.frame
        mainImageView.frame = view.frame
        debug()
    }
    
    func debug() {
        print("----")
        print(tempImageView.frame)
        print(mainImageView.frame)
        print(view.frame)
        print(view.bounds)
    }
    
    public override func loadView() {
        
        self.rhythm = RandomRhythmProvider()
        
        let view = UIView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFill
        view.isMultipleTouchEnabled = true
        
        // Setup the image view
        tempImageView = UIImageView(frame: view.frame)
        mainImageView = UIImageView(frame: view.frame)
                
        view.addSubview(mainImageView)
        
        self.view = view
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        if touches.count == 2 {
            reset()
        }
        swiped = false
        lastPoint = touch.location(in: self.view)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            return
        }
        guard let touch = touches.first else { return }
        
        let currentPoint = touch.location(in: self.view)
        let distance = hypotf(Float(lastPoint.x - currentPoint.x), Float(lastPoint.y - currentPoint.y))

        if rhythm.match(value: distance) {
            color = .white
        } else {
            color = .black
        }
        
        swiped = true

        drawLine(from: lastPoint, to: currentPoint)
        compose()

        lastPoint = currentPoint
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if swiped {
            compose()
        }
    }
    
    // Internal Drawing Functions
    func drawLine(from: CGPoint, to: CGPoint) {
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        tempImageView.image?.draw(in: view.bounds)
        
        context.move(to: from)
        context.addLine(to: to)
        
        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(brushWidth)
        context.setStrokeColor(color.cgColor)
        
        context.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity

        UIGraphicsEndImageContext()
    }
    
    func compose() {
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        
        mainImageView.image?.draw(in: mainImageView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: mainImageView.bounds, blendMode: .normal, alpha: opacity)
        
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }
    
    public func reset() {
        lastPoint = .zero
        tempImageView.image = nil
        mainImageView.image = nil
        compose()
    }
}

struct DoodleView: View {
    @Binding var doodleView: DoodleViewController
}

extension DoodleView: UIViewControllerRepresentable {
    
  public func makeUIViewController(context: Context) -> DoodleViewController {
    return doodleView
  }

  public func updateUIViewController(_ uiViewController: DoodleViewController, context: Context) {
  }
}
