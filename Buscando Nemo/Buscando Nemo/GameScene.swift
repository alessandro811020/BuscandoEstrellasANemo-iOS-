//
//  GameScene.swift
//  Buscando Nemo
//
//  Created by AlejandroMacEstudio on 23/05/2017.
//  Copyright © 2017 AlejandroMacEstudio. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

//Clase principal porque contiene la escena y todos los componentes y su secuencia logica del juego
class GameScene: SKScene {
    //PRIMERO SE HAN DECLARADO TODOS LOS CAMPOS.
    //Fondo del juego
    var fondoJuego = SKSpriteNode()
    //zona Puntuable para las estrellas
    let zonaPuntuable: CGRect
    
    //el papa de nemo es inicializado con una imagen
    let merlin = SKSpriteNode(imageNamed: "merlin1")
    
    //caracteristicas de merlin para su movimiento y accion
    let movimientoMerlinPorSegundo: CGFloat = 480.0
    var velocidad = CGPoint.zero
    
    //para que merlin se mueva a donde se de click
    var ultimaLocalizacionTocada: CGPoint?
    
    //parametro de rotacion de merlin
    let rotarMerlinRadiansPerSec:CGFloat = 4.0 * π
    
    //Animaciones del movimiento de Merlin
    var animacionMerlin = SKAction()
    
    //Variables para las puntuaciones
    var puntuacionLabel = SKLabelNode()
    var puntuacion = 0
    
    //Variables asociadas a las vidas
    var vidasLabel = SKLabelNode()
    var vidas = 3
    
    
    //variables que reflejan el diferencial de tiempo
    var ultimaActualizacionTiempo: TimeInterval = 0
    var dt: TimeInterval = 0
    
    //Los sprites que intentarán que el padre no capture las estrellas
    var pezFondoSK = SKSpriteNode()
    var medusaSK = SKSpriteNode()
    var barracudaSK = SKSpriteNode()
    //El sprite que debe recoger merlin para nemo
    var estrellaSK = SKSpriteNode()
    
    //Variables que tienen que ver con el flujo
    var gameOver = false
    var timer = Timer()
    var play = false
    
    
    //método init de inicializaciónde algunas variables pertinentes
    override init(size: CGSize) {
        //inicializar un area jugable para delimitar la zona donde saldran las estrellas que debe recoger
        //la razon de proporción entre largo por ancho
        let maxAspectRatio: CGFloat = 16.0/9.0
        //ajuste del tamaño asignado a la variable anchura jugable
        let anchuraJugable = size.width/maxAspectRatio
        //margen para jugar
        let margenJugable = (size.height - anchuraJugable)/20
        //asignarle la región jugable a la zona puntuable
        zonaPuntuable = CGRect( x: 0, y: margenJugable, width: size.width, height: anchuraJugable)
        //darle a la super clase el size de la clase
        super.init(size: size)
        
        //INICIALIZAR LA ANIMACIÓN DE MERLIN
        //creamos las texturas de merlin
        let merlin1 = SKTexture(imageNamed: "merlin1")
        let merlin2 = SKTexture(imageNamed: "merlin2")
        let merlin3 = SKTexture(imageNamed: "merlin3")
        
        //creamos la animación de merlin con las texturas anteriormente creadas con un intervalo de 0.25 según el movimiento de todo el juego
        animacionMerlin = SKAction.animate(with: [merlin1, merlin2, merlin3], timePerFrame: 0.25)
        
    }
    
    //método que se debe indicar dentro de la clase siempre que modificamos el init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //método que inicializa el juego
    override func didMove(to view: SKView) {
        //reproducir el sonido del juego
        reproducirMusicaFondo("fondo_musical.wav")
        //cargar la configuración del juego
        configuracionJuego()
    }
    
    
    //MÉTODOS QUE CUENTA LA CLASE QUE SON DE APOYO A LA APP
    
    //Método que configura la el inicio de la aplicación con sus características
    func configuracionJuego(){
        //Fondo del juego, la textura del mar
        let texturaFondo = SKTexture(imageNamed: "fondo")
        //Dos acciones que se utilizarán para darle movimiento al fondo del mar
        let animacionFondo1 = SKAction.move(by: CGVector(dx: -texturaFondo.size().width, dy: 0), duration: 60)
        let animacionFondo2 = SKAction.move(by: CGVector(dx: texturaFondo.size().width, dy: 0), duration: 0)
        //crear la animación de movimiento
        let moverFondo = SKAction.repeatForever(SKAction.sequence([animacionFondo1,animacionFondo2]))
        //variable para el bucle que se trabajará
        var i: CGFloat = 0
        //bucle para el movimiento del fondo del mar
        while i<3{
            //asignarle al fondo su textura
            fondoJuego = SKSpriteNode(texture: texturaFondo)
            //ubicación del fondo con la indicación del parámetro del bucle incluido
            fondoJuego.position = CGPoint(x: texturaFondo.size().width*i, y: self.frame.midY)
            //al ancho de la imagen, darle la anchura de la pantalla
            fondoJuego.size.height = self.frame.height
            //darle la animación a todo fondo que se vaya creando dentro de la app
            fondoJuego.run(moverFondo)
            //ubicación en el eje z, para que esté al fondo del todo
            fondoJuego.zPosition = -3
            //agregar el fondo
            addChild(fondoJuego)
            //aumentar la variable
            i+=1
        }
        //crear la barra superior donde se colocarán los resultados y las vidas del juego
        barraSuperior()
        //colocar la imagen y la cantidad de vidas que va teniendo el juegador
        colocarVidas()
        //colocar la imagen y la puntuación del jugador
        colocarPuntuacion()
        
        //colocar a merlin dentro de la pantalla
        merlin.position = CGPoint(x: 400, y: 400)
        //como la imagen es muy pequeña, la aumento, para que así el pez sea mas grande y a su vez un poco mas complejo
        merlin.scale(to: CGSize(width: 3*merlin.size.width, height: 3*merlin.size.height))
        //se repita la animación de merlin nadando
        merlin.run(SKAction.repeatForever(animacionMerlin))
        //asignarle un nombre a merlin, para las colisiones, sus identificaciones
        merlin.name = "Merlin"
        //agregar a merlin ya a la pantalla del juego
        addChild(merlin)
        
        //colocar la animación y que salga el pez del fondo de los mares
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(pezFondo), SKAction.wait(forDuration: 0.7)])))
        //colocar la animación y que salga la medusa
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(medusa), SKAction.wait(forDuration: 0.7)])))
        //colocar la animación y que salga la barracuda
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(barracuda), SKAction.wait(forDuration: 0.7)])))
        
        //estrellas para la puntuación, que vaya saliendo aleatoriamente
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(estrella), SKAction.wait(forDuration: 3.0)])))
    }
    
    //Funciones que se refieren a los objetos que van apareciendo en pantalla
    //Función para crear el pez del fondo
    func pezFondo(){
        //crear las texturas del pez del fondo
        let textura1PezFondo = SKTexture(imageNamed: "malo_fondo1")
        let textura2PezFondo =  SKTexture(imageNamed: "malo_fondo2")
        //crear la animación constante del pez para que parezca que está nadando
        let animacionPezfondo = SKAction.animate(with: [textura1PezFondo,textura2PezFondo], timePerFrame: 0.3)
        //hacer que se repita constantemente la animación
        let movimientoPezFondo =  SKAction.repeatForever(animacionPezfondo)
        //asignarle el nombre al pez para las colisiones, lo identifique
        pezFondoSK.name = "Perder"
        //creamos el nodo del pez
        pezFondoSK = SKSpriteNode(texture: textura1PezFondo)
        //colocar de manera aleatoria el pez a lo ancho de la pantalla para que vaya saliendo. el metodo aleatorio ha sido especificado en my Utils
        pezFondoSK.position = CGPoint(x: size.width+pezFondoSK.size.height/2, y: CGFloat.random(min: self.frame.minY+pezFondoSK.size.height/2, max: self.frame.maxY-pezFondoSK.size.height/2))
        //al pez que que coja la animación de movimiento para que parezca que está nadando.
        pezFondoSK.run(movimientoPezFondo)
        //la acción de qu se mueva hacia la izquierda
        let movimientoPez = SKAction.moveTo(x: -pezFondoSK.size.width/2, duration: 20)
        //acción que desaparezca
        let movimientoRemover = SKAction.removeFromParent()
        //juntar las acciones y que estas sean realizadas por el pez creado
        pezFondoSK.run(SKAction.sequence([movimientoPez,movimientoRemover]))
        //le damos más tamaño al pez porque su tamaño es bastante pequeño
        pezFondoSK.scale(to: CGSize(width: 3*pezFondoSK.size.width , height: 3*pezFondoSK.size.height))
        //Agregamos al pez a la pantalla
        addChild(pezFondoSK)
    }
    
    //función para crear la medusa que viene desde abajo
    func medusa(){
        //creamos las texturas de las medusas
        let textura1Medusa = SKTexture(imageNamed: "medusa1")
        let textura2Medusa =  SKTexture(imageNamed: "medusa2")
        let textura3Medusa =  SKTexture(imageNamed: "medusa2")
        //juntarlas en una animación para darles efecto de movimiento, con su intervalo de tiempo entre texturas
        let animacionMedusa = SKAction.animate(with: [textura1Medusa,textura2Medusa, textura3Medusa], timePerFrame: 0.3)
        //crear la animación constante del movimiento
        let movimientoMedusa =  SKAction.repeatForever(animacionMedusa)
        //darle valor a la medusa para las futuras colisiones
        medusaSK.name = "Perder"
        //creamos el nodo de la medusa
        medusaSK = SKSpriteNode(texture: textura1Medusa)
        //colocamos a la medusa en la posiciçon 2 en el eje z para que no se contrasten las imagenes con otras animaciones de ojetos dentro del juego.
        medusaSK.zPosition = 2
        //colocamos la medusa de manera aleatoria en el fondo del mar
        medusaSK.position = CGPoint(x: CGFloat.random(min: self.frame.minX+medusaSK.size.width/2, max: self.frame.maxX-medusaSK.size.width/2), y: self.frame.minY-medusaSK.size.width/2)
        //asignarle la animación del constante movimiento de la medusa
        medusaSK.run(movimientoMedusa)
        //decirle a la medusa que una vez creada se desplace hacia arriba
        let movimientoTraslMedusa = SKAction.moveTo(y: self.frame.maxY+medusaSK.size.width/2, duration: 20)
        //que desaparezca despues de que llegue arriba
        let movimientoRemoverMedusa = SKAction.removeFromParent()
        //unir ambas acciones creando de esta manera su animación
        medusaSK.run(SKAction.sequence([movimientoTraslMedusa,movimientoRemoverMedusa]))
        //escalamos la medusa por la misma razón de que las imágenes eran muy pequeñas
        medusaSK.scale(to: CGSize(width: 3*medusaSK.size.width , height: 3*medusaSK.size.height))
        //agregar la medusa
        addChild(medusaSK)
    }
    
    //Creamos la barracuda
    func barracuda(){
        //creamos las texturas de la barracuda
        let textura1Barracuda = SKTexture(imageNamed: "barracuda1")
        let textura2Barracuda =  SKTexture(imageNamed: "barracuda2")
        //unimos las texturas para crear efecto de animación para que parezca de que está nadando
        let animacionBarracuda = SKAction.animate(with: [textura1Barracuda,textura2Barracuda], timePerFrame: 0.3)
        //crear la animación de efecto nado constante
        let movimientoBarracuda =  SKAction.repeatForever(animacionBarracuda)
        //crear el nombre para las colisiones que tendrá la barracuda, que lo identificará
        barracudaSK.name = "Perder"
        //creamos el nodo de la barracuda
        barracudaSK = SKSpriteNode(texture: textura1Barracuda)
        //la posición de la barracuda donde será creada aleatoriamente a la derecha de la pantalla
        barracudaSK.position = CGPoint(x: size.width+barracudaSK.size.height/2, y: CGFloat.random(min: self.frame.minY+barracudaSK.size.height/2, max: self.frame.maxY-barracudaSK.size.height/2))
        //asignarle la animación de movimiento a la barracuda
        barracudaSK.run(movimientoBarracuda)
        //la acciónde que se mueva hacia la izqueirda luego de creado
        let movimientoBarracudaMar = SKAction.moveTo(x: -barracudaSK.size.width/2, duration: 7)
        //qeu desaparezca la barracuda al final del camino
        let movimientoRemoverBarracuda = SKAction.removeFromParent()
        //crear a la barracuda la union de las dos acciones como si fuera el efecto de una animacion, una secuencia de acciones
        barracudaSK.run(SKAction.sequence([movimientoBarracudaMar,movimientoRemoverBarracuda]))
        //colocación de la barracuda en la posición del eje z en 1, para que no se monten las imágenes
        barracudaSK.zPosition = 1
        //aumentarle el tamaño a la barracuda por la pequeña imagen que era
        barracudaSK.scale(to: CGSize(width: 5*barracudaSK.size.width , height: 5*barracudaSK.size.height))
        //agregar la barracuda
        addChild(barracudaSK)
    }
    
    //Funcion para crear estrellas
    func estrella(){
        //la estrella tiene una sola textura pero es creada
        estrellaSK = SKSpriteNode(imageNamed: "estrella_recolectar")
        //colocar la estrella de manera aleatoria dentro de la zona puntuable anteriormente creada. se modificó el método random que se usaba para los sprites anteriores para así garantizar una ubicación dentro de la pantalla
        estrellaSK.position = CGPoint(
            x: CGFloat.random2(min: zonaPuntuable.minX+estrellaSK.size.width/2,
                               max: zonaPuntuable.maxX-estrellaSK.size.width/2),
            y: CGFloat.random2(min: zonaPuntuable.minY+estrellaSK.size.height/2,
                               max: zonaPuntuable.maxY-estrellaSK.size.height/2))
        //asignarle el nombre al nodo para que de esta manera identifique las colisiones
        estrellaSK.name = "Estrella"
        //después de ubicar, decirle que crezca y el tiempo que demora el crecer
        let aparecer = SKAction.scale(to: 1.5, duration: 1)
        //espere cuatro segundos para que merlin pueda llegar
        let esperar = SKAction.wait(forDuration: 4)
        //efecto desaparecer en el escalado cero y l duración de la disminución
        let desaparecer = SKAction.scale(to: 0, duration: 0.5)
        //desaparecer a la estrella
        let borrarCompleto = SKAction.removeFromParent()
        //juntar las acciones
        let acciones = [aparecer, esperar, desaparecer, borrarCompleto]
        //crear la secuencia de la anumación de las acciones anteriormente creadas
        estrellaSK.run(SKAction.sequence(acciones))
        //asignarle la estrella a la vista
        addChild(estrellaSK)
    }
    
    //metodo para crear la barra donde colocaremos la vida y las puntuaciones
    func barraSuperior(){
        //crear el nodo de tipo forma, en este caaso será un retángulo con sus dimensiones
        let barra = SKShapeNode(rectOf: CGSize(width: self.frame.width, height: 80))
        //rellenarlo de color, en este caso azul
        barra.fillColor = SKColor(colorLiteralRed: 28/255, green: 57/255, blue: 136/255, alpha: 1)
        //posición de la barra en el eje z, que esté por encima, para que no se mezclen en el mismo plano de otras animaciones
        barra.zPosition = 5
        //posición de la barra
        barra.position = CGPoint(x: self.frame.midX, y: (self.frame.maxY)-40)
        //agregar la barra
        addChild(barra)
    }
    
    //metodo para colocar la puntuacion dentro de la pantalla
    func colocarPuntuacion(){
        //al label donde se expresará la puntuación se le agregan sus características
        //tipo de letra
        puntuacionLabel.fontName = "Helvetica"
        //tamaaño de la letra
        puntuacionLabel.fontSize = 60
        //el texto que rellenará el label de la puntuación
        puntuacionLabel.text = "\(puntuacion)"
        //ubicación del label de la puntuación
        puntuacionLabel.position = CGPoint(x: (self.frame.minX)+70, y: (self.frame.maxY)-60)
        //colocar la puntuación por encima de la barra anteriormente creada
        puntuacionLabel.zPosition = 6
        //el color del label del texto
        puntuacionLabel.color = SKColor(colorLiteralRed: 179/255, green: 180/255, blue: 180/255, alpha: 1)
        //agregar la puntuación
        self.addChild(puntuacionLabel)
        
        //Agregar la estrella comos símbolo de la puntuación
        //crear la textura de la estrella aquí
        let estrellaBarra = SKTexture(imageNamed: "estrella_recolectar")
        //crear el nodo con la textura de la estrella
        let estrellaBarraNodo = SKSpriteNode(texture: estrellaBarra)
        //ubicar la estrella en la posicióne specífica
        estrellaBarraNodo.position = CGPoint(x: self.frame.minX+140, y: self.frame.maxY-38)
        //colocarlo encima de la barra
        estrellaBarraNodo.zPosition = 6
        //aumentar la estrella de tamaño porque la imagen original es pequeña
        estrellaBarraNodo.scale(to: CGSize(width: 1.3*estrellaBarra.size().width, height: 1.3*estrellaBarra.size().height))
        //agregar la estrella
        self.addChild(estrellaBarraNodo)
    }
    
    //metodo para colocar las vidas y el simbolo dentro del programa
    func colocarVidas(){
        //creamos las características del texto que se agregará la cantidad de vidas
        //el tipo de letra
        vidasLabel.fontName = "Helvetica"
        //tamaño del texto
        vidasLabel.fontSize = 60
        //colocar la cantidad de vidas como texto dentro del label
        vidasLabel.text = "\(vidas)"
        //posición del texto que se ha agregado
        vidasLabel.position = CGPoint(x: self.frame.maxX-40, y: self.frame.maxY-60)
        //colocarlo por encima de la barra
        vidasLabel.zPosition = 6
        //darle el color al texto
        vidasLabel.color = SKColor(colorLiteralRed: 179/255, green: 180/255, blue: 182/255, alpha: 1)
        //colocar el label de la puntuación
        self.addChild(vidasLabel)
        
        //simbolo de vidas
        //creamos la textura del corazón como símbolo de la vida
        let merlinVidasTextura = SKTexture(imageNamed: "vidas_merlin")
        //creamos el nodo de las vidas
        let merlinVidaNodo = SKSpriteNode(texture: merlinVidasTextura)
        //posicionamos el nodo dentro de la pantalla
        merlinVidaNodo.position = CGPoint(x: self.frame.maxX-100, y: self.frame.maxY-38)
        //colocarlo por encima de la barra que especifica las cosas
        merlinVidaNodo.zPosition = 6
        //escalar el corazón porque el tamaño de la imagen era muy pequeña
        merlinVidaNodo.scale(to: CGSize(width: 0.72*merlinVidasTextura.size().width, height: 0.72*merlinVidasTextura.size().height))
        //agregar el nodo de las vidas como símbolo de estas en el juego.
        self.addChild(merlinVidaNodo)
    }
    
    //metodos especificos que habla de efectos que tendrán los nodos dentro del juego
    //metodo para mover a merlin, la dirección
    func moverMerlinDireccion(_ localizacion: CGPoint){
        //se calcula el trayecto del movimiento restando el lugar pulsado menos la posicion que se encuentra
        let trayecto = CGPoint(x: localizacion.x - merlin.position.x, y: localizacion.y-merlin.position.y)
        //calcular el modulo del vector desplazamiento, que es el largo del recorrido
        let moduloDesplazamiento = sqrt(Double(trayecto.x*trayecto.x + trayecto.y*trayecto.y))
        //calculo de la direccion que no es mas que el vector unitario del recorrido
        let direccion = CGPoint(x: trayecto.x/CGFloat(moduloDesplazamiento), y: trayecto.y/CGFloat(moduloDesplazamiento))
        //moverse segun el sentido del vector unitario, multiplicado por el movimiento de merlin que es el rango de desplazamiento
        velocidad = CGPoint(x: direccion.x*movimientoMerlinPorSegundo, y: direccion.y*movimientoMerlinPorSegundo)
    }
    //para girar a Merlin
    func rotarSprite(_ sprite: SKSpriteNode, direccion: CGPoint, rotarRadianesPorSeg: CGFloat) {
        //punto inicial donde se establece la diferencia de grados entre ambos angulos
        let puntoInicio = shortestAngleBetween(angle1: sprite.zRotation, angle2: velocidad.angle)
        //calculo de cuanto se rotara
        let cantidadARotar = min(rotarRadianesPorSeg * CGFloat(dt), abs(puntoInicio))
        //rotar el sprite
        sprite.zRotation += puntoInicio.sign() * cantidadARotar
    }
    
    //Luego de rotar que se mueva en esa dirección y sentido
    func moverSprite(_ sprite:SKSpriteNode, velocidad: CGPoint){
        //cantidad a mover que no es mas que multiplicar por cada eje la velocidad por el tiempo, para hallar el espacio por cada eje.
        let cantidadAMover = CGPoint(x: velocidad.x*CGFloat(dt), y: velocidad.y*CGFloat(dt))
        //darle al sprite la posicion que se ha optenido sumandole a la posicion, la cantidad a mover
        sprite.position = CGPoint(x: sprite.position.x+cantidadAMover.x, y: sprite.position.y+cantidadAMover.y)
    }
    
    //método para que chequee las colisiones entre los sprites y según lo que ocurra entonces los sucesos dentro del juego
    func chequearColisiones(){
        //Array que acumulará las estrellas que se han recolectado, las vaacumulando.
        var golpearEstrellas: [SKSpriteNode] = []
        //Array que acunulará a los malos según el golpe que tenga merlin
        var golpearMalos: [SKSpriteNode] = []
        //enumerar los nodos que cuando se choquen sean identificados como Estrella
        enumerateChildNodes(withName: "Estrella"){ node, _ in
            //crear la constante valor que es el nodo golpeado
            let valor = node as! SKSpriteNode
            //si quien chocó la estrella es merlin agregar a golpear estrellas el nodo que ha sido golpeado por merlin
            if valor.frame.intersects(self.merlin.frame){
                golpearEstrellas.append(valor)
            }
        }
        //para todos los valor que han sido agregados, realizar
        for valor in golpearEstrellas{
            //hacer el choque introduciendole el nodo
            choquesMerlin(valor)
            //sumar un punto a la puntuacion
            self.puntuacion+=1
            //imprimir el resultado
            self.puntuacionLabel.text = "\(self.puntuacion)"
        }
        //enumerar los nodos que son cuando hay colisiones identificados con Perder
        enumerateChildNodes(withName: "Perder"){ node, _ in
            //crear la constante enemigo que identifica al nodo que choco con merlin
            let enemigo = node as! SKSpriteNode
            //porque si es que viene de interseptar a merlin con el enemigo entonces agregar el enemigo al array de los enemigos golpeados
            if enemigo.frame.intersects(self.merlin.frame){
                golpearMalos.append(enemigo)
            }
        }
        //para cada uno de los enemigos que ha golpeado a merlin
        for enemigo in golpearMalos{
            //disminuir una vida
            self.vidas-=1
            //imprimir las vidas que hay
            self.vidasLabel.text = "\(vidas)"
            //el metodo de los chocques de merlin, se le introduce al nodo que lo choco, entonces se le introduce para que el metodo decida que va hacer el programa
            choquesMerlin(enemigo)
        }
    }
    //método que se refiere a las acciones qeu se hará en el programa según lo que suceda, según a quien ha chocado merlin
    func choquesMerlin(_ sprite: SKSpriteNode){
        //si el nodo golpeado ha sido una estrella
        if sprite.name == "Estrella" {
            //remover la estrella
            sprite.removeFromParent()
            //reproducir el sonido de haer chocado la estrella
            run(SKAction.playSoundFileNamed("estrella_capturada.wav",
                                        waitForCompletion: false))
            //en caso de que la puntuación sea 15 se ha ganado el juego
            if puntuacion == 15 && !gameOver{
                //se acaba el juego
                gameOver = true
                //ir a la escena de se acaba el juego, indicando la victoria y el tamaño
                let gameOverScene = GameOverScene(tamano: size, victoria: true)
                //igualar la escala de cada uno de las escenas
                gameOverScene.scaleMode = scaleMode
                //constante que se refiere a la transicion entre escenas
                let revelar =  SKTransition.flipHorizontal(withDuration: 0.5)
                //realizar la transicion a la otra escena, según la transición creada.
                view?.presentScene(gameOverScene, transition: revelar)
            }
        }
        //Si se ha golpeado al nodo perder
        if sprite.name == "Perder"{
            //reproducir el sonido de haber chocado con uno de los enemigos
            run(SKAction.playSoundFileNamed("contacto_malo.wav",waitForCompletion: false))
            //eliminar el sprite enemigo golpeado
            sprite.removeFromParent()
            //crear una constante de parpadeo
            let parpadear = 10.0
            //la duracion del parpadeo
            let duracion = 3.0
            //hacer una animación que refiere al parpadeo para merlin
            let animacionParpadeo = SKAction.customAction(withDuration: duracion){ node, elapsedTime in
                let slice = duracion/parpadear
                let recordatorio = Double(elapsedTime).truncatingRemainder(dividingBy: slice)
                node.isHidden = recordatorio > slice/2
            }
            //accion que se le indica a merlin para que sea oculto en el instante del parpadeo
            let oculto = SKAction.run() {
                self.merlin.isHidden = false
            }
            //darle la secuencoa de acciones a merlin
            merlin.run(SKAction.sequence([animacionParpadeo,oculto]))
        }
    }
    
    //MÉTODOS DE LA APP
    //método que se refiere al tocar la pantalla
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //reproducir el sonido de tocar
        run(SKAction.playSoundFileNamed("burbujas.mp3",
                                        waitForCompletion: false))
        //si se ha tocado, devolverlo
        guard let tocado = touches.first else{
            
            return
        }
        //hacer la constante de la localización del lugar tocado
        let localizacionTocada = tocado.location(in: self)
        //lo ultimo tocado sera el lugar que se tocó
        ultimaLocalizacionTocada = localizacionTocada
        //mover a merlin en la dirección que ha sido tocada
        moverMerlinDireccion(localizacionTocada)
    }
    
    //método que se refiere al tocar la pantalla
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //reproducir el sonido de tocar
        run(SKAction.playSoundFileNamed("burbujas.mp3",
                                        waitForCompletion: false))
        //si se ha tocado, devolverlo
        guard let tocado = touches.first else{
            
            return
        }
        //hacer la constante de la localización del lugar tocado
        let localizacionTocada = tocado.location(in: self)
        //lo ultimo tocado sera el lugar que se tocó
        ultimaLocalizacionTocada = localizacionTocada
        //mover a merlin en la dirección que ha sido tocada
        moverMerlinDireccion(localizacionTocada)
    }
    
    //para cuando esté la transición entre escenas se detenga la reproducción del sonido de fondo
    override func willMove(from view: SKView) {
        //detener la música
        fondoReproductorMusica.stop()
    }
    
    //método que refleja la actualización constante que va chequeando las siguientes cosas
    override func update(_ currentTime: TimeInterval) {
        //actualizacion del tiempo para el clickeo de la pantalla
        if ultimaActualizacionTiempo>0{
            dt = currentTime-ultimaActualizacionTiempo
        }else{
            dt = 0
        }
        //va actualizando el tiempo ultimo con el tiempo actual
        ultimaActualizacionTiempo = currentTime
        
        //se actualice las localizaciones tocadas por el usuario
        if let ultimoTocado = ultimaLocalizacionTocada{
            //obtener la diferencia entre el lugar del nodo merlin y loq ue se ha tocado
            let diferencial = ultimoTocado - merlin.position
            //si la longitud es menor que el movimiento pues la ubicación de merlin es igual al lugar tocado
            if (diferencial.length()<=movimientoMerlinPorSegundo*CGFloat(dt)){
                //igualar la posicion de merlin a lo tocado
                merlin.position = ultimoTocado
                //detener a merlin
                velocidad = CGPoint.zero
            }else{
                //sino mover a merlin segun la velocidad y al lugar
                moverSprite(merlin, velocidad: velocidad)
                //rotar a merlin segun el movimiento clickeado
                rotarSprite(merlin, direccion: velocidad, rotarRadianesPorSeg: rotarMerlinRadiansPerSec)
            }
        }
        
        //chequear las colisiones constantementes
        chequearColisiones()
        //si las vidas estan por debajo de cero
        if vidas<=0 && !gameOver {
            //activar el gameover de que se acaba el juego
            gameOver = true
            //ir a la escena de que se ha acabado el juego porque se ha perdido
            let gameOverScene = GameOverScene(tamano: size, victoria: false)
            //igualar las escalas
            gameOverScene.scaleMode = scaleMode
            //declarar la transicion para el cambio de escenas
            let revelar = SKTransition.flipHorizontal(withDuration: 0.5)
            //cambiar la escena con la transicion declarada
            view?.presentScene(gameOverScene, transition: revelar)
        }
    }
}
