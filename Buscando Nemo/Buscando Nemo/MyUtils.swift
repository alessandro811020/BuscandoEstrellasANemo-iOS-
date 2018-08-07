//
//  MyUtils.swift
//  Buscando Nemo
//
//  Created by AlejandroMacEstudio on 23/05/2017.
//  Copyright © 2017 AlejandroMacEstudio. All rights reserved.
//

import Foundation
import CoreGraphics

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left: inout CGPoint, right: CGPoint) {
  left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left: inout CGPoint, right: CGPoint) {
  left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (left: inout CGPoint, right: CGPoint) {
  left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point: inout CGPoint, scalar: CGFloat) {
  point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (left: inout CGPoint, right: CGPoint) {
  left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point: inout CGPoint, scalar: CGFloat) {
  point = point / scalar
}

#if !(arch(x86_64) || arch(arm64))
func atan2(y: CGFloat, x: CGFloat) -> CGFloat {
  return CGFloat(atan2f(Float(y), Float(x)))
}

func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
  
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
  
  func normalized() -> CGPoint {
    return self / length()
  }
  
  var angle: CGFloat {
    return atan2(y, x)
  }
}

extension CGFloat{
    static func random()-> CGFloat{
        return CGFloat(Float(arc4random())/Float(UInt32.max))
    }
    static func random(min: CGFloat, max: CGFloat)->CGFloat{
        assert(min<max)
        return CGFloat.random()*(max-min)*min
    }
    static func random2(min: CGFloat, max: CGFloat)->CGFloat{
        assert(min<max)
        return (CGFloat.random()*(max-min)*min)/10
    }

}

let π = CGFloat.pi
func shortestAngleBetween(angle1: CGFloat,
                          angle2: CGFloat) -> CGFloat {
    let twoπ = π * 2.0
    var angle = (angle2 - angle1)
        .truncatingRemainder(dividingBy: twoπ)
    if angle >= π {
        angle = angle - twoπ
    }
    if angle <= -π {
        angle = angle + twoπ
    }
    return angle
}
extension CGFloat {
    func sign() -> CGFloat {
        return self >= 0.0 ? 1.0 : -1.0
    }
}

import AVFoundation

var fondoReproductorMusica: AVAudioPlayer!

func reproducirMusicaFondo(_ archivo: String) {
    let urlRecurso = Bundle.main.url(forResource: archivo, withExtension: nil)
    guard let url = urlRecurso else {
        print("No se pudo reproducir el archivo: \(archivo)")
        return
    }
    
    do {
        try fondoReproductorMusica = AVAudioPlayer(contentsOf: url)
        fondoReproductorMusica.numberOfLoops = -1
        fondoReproductorMusica.prepareToPlay()
        fondoReproductorMusica.play()
    } catch {
        print("No se pudo reproducir el audio")
        return
    }
}





