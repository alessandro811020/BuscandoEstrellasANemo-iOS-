//
//  GameViewController.swift
//  Buscando Nemo
//
//  Created by AlejandroMacEstudio on 23/05/2017.
//  Copyright © 2017 AlejandroMacEstudio. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

//Es el game controller del juego donde se cargarán la vista del juego, así como la escena principal
class GameViewController: UIViewController {

    //lo que debe ser cargado. en este caso especificar la escena y caracteristicas.
    override func viewDidLoad() {
        super.viewDidLoad()
        //crear la escena que mostrará el juego y el tamaño de esta
        let escena = GameScene(size: CGSize(width: 1334, height: 750))
        //crear la variable vista que se le asigna la vista del juego
        let vista = self.view as! SKView
        //activar algunos campos de la vista
        vista.showsFPS = true
        vista.ignoresSiblingOrder = true
        //a la escena la imagen se ajuste
        escena.scaleMode = .aspectFit
        //a la vista agregarle la escena
        vista.presentScene(escena)
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        //hacer que el juego siempre se juegue horizontal, esto se establecio aqui en el plist tambien
        return .landscape
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
