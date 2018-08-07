//
//  GameOverScene.swift
//  Buscando Nemo
//
//  Created by AlejandroMacEstudio on 23/05/2017.
//  Copyright © 2017 AlejandroMacEstudio. All rights reserved.
//

import Foundation
import SpriteKit

//Escena que se mostrará según el resultado de la escena anterior. Si ha encontrado las estrellas o si ha perdido
class GameOverScene: SKScene {
    
    //Las dos etiquetas de texto que se mostrarán en la pantalla según el resultado obtenido
    //Etiqueta para a victoria
    var victoriaLabel = SKLabelNode()
    //Etiqueta para la derrota
    var derrotaLabel = SKLabelNode()
    //campo de la escena que informa al ser llamada si ha ganado o no el juego para de esta manera diferenciar la escena a mostrar
    let victoria:Bool
  
    //Inicializador de la escena donde se especifica el tamano y el tipo de escena que se mostrará si ha ganado o no.
    init(tamano: CGSize, victoria: Bool) {
        
        //Se le asignan los valores a los distintos campos de la escena
        self.victoria = victoria
        super.init(size: tamano)
    }
  
    //ESte método es requerido al utilizar el init en caso de que no se implemente
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    //método que carga la escena, segun las especificaciones, la vista que se plantee
    override func didMove(to view: SKView) {
        //variable que se refiere al fondo que se utilizará. Aún no se inicializa porque se realizará en cada una de las pantallas según el resultado
        var background: SKSpriteNode
        //Si se ha ganado el juego
        if (victoria) {
            //Inicializamos el fondo con la imagen de la victoria.
            background = SKSpriteNode(imageNamed: "victoria")
        
            //Se especificarán las características de la etiqueta
            //tipo de letra
            victoriaLabel.fontName = "Helvetica"
            //Tamaño de la letra
            victoriaLabel.fontSize = 50
            //Texto a mostrar
            victoriaLabel.text = "Gracias Papá por las Estrellas"
            //ubicación
            victoriaLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            //Colocar por encima en el eje z
            victoriaLabel.zPosition = 2
            //Agregarlo para que sea mostrado
            addChild(victoriaLabel)
        
            //correr un tiempo de espera y de ahi reproducit el sonido de l victoria
            run(SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.playSoundFileNamed("victoria_sonido.wav",waitForCompletion: false)]))
            //Si no gana, lógicamente pierde
        } else {
            
            //Se especifican las caracteriticas del label
            //Tipo de letra
            derrotaLabel.fontName = "Helvetica"
            //tamaño de la letra
            derrotaLabel.fontSize = 50
            //texto de derrota
            derrotaLabel.text = "Vuelve a intentarlo Papá"
            //posición del texto
            derrotaLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            //ubicación en el eje z más elevado
            derrotaLabel.zPosition = 2
            //agregarlo a la escena
            addChild(derrotaLabel)
            //Establecer el fondo de la derrota
            background = SKSpriteNode(imageNamed: "derrota")
        
            //Sonido que se mostrará por la derrota, antes una ligera parada
            run(SKAction.sequence([SKAction.wait(forDuration: 0.1),SKAction.playSoundFileNamed("derrota.wav",waitForCompletion:false)]))
        }
        //ubicación del fondo
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        //Agregar el fondo
        addChild(background)
    
        //Establecer el tiempo de espera para la transición a jugar nuevamente
        let esperar = SKAction.wait(forDuration: 3.0)
        //bloque de acciones para la transición
        let bloque = SKAction.run {
            let escenaPrincipal = GameScene(size: self.size)
            escenaPrincipal.scaleMode = self.scaleMode
            let revelar = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(escenaPrincipal, transition: revelar)
        }
        //correr la acción
        run(SKAction.sequence([esperar, bloque]))
    }
}
