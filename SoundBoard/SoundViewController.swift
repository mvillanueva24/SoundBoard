//
//  SoundViewController.swift
//  SoundBoard
//
//  Created by Mario Villanueva Linares on 5/20/22.
//  Copyright © 2022 mvillanueva24. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var tiempoGrabacion: UILabel!
    
    var timer:Timer = Timer()
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var grabando:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        // Do any additional setup after loading the view.
        agregarButton.isEnabled = false
    }
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            grabarAudio?.stop()
            grabarButton.setTitle("GRABAR", for: .normal)
            timer.invalidate()
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        }else{
            grabando = true
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(duracion), userInfo: nil, repeats: true)
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    @objc func duracion() -> Void {
        let duracion = Int(grabarAudio!.currentTime)
        let horas = duracion / 3600
        let minutos = (duracion % 3600)/60
        let segundos = (duracion % 3600) % 60
        var tiempo = ""
        tiempo += String(format: "%02d", horas)
        tiempo += ":"
        tiempo += String(format: "%02d", minutos)
        tiempo += ":"
        tiempo += String(format: "%02d", segundos)
        tiempoGrabacion.text = tiempo
   }

    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        grabacion.duracion = tiempoGrabacion.text
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
    }
    
    
    @IBAction func subirVolumen(_ sender: Any) {
        
        reproducirAudio?.stop()
        reproducirAudio?.volume += 1
        reproducirAudio?.prepareToPlay()
        reproducirAudio?.play()
        
    }
    
    @IBAction func bajarVolumen(_ sender: Any) {
        
        reproducirAudio?.stop()
        reproducirAudio?.volume -= 1
        reproducirAudio?.prepareToPlay()
        reproducirAudio?.play()
        
    }
    func configurarGrabacion(){
        do{
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            print("********************")
            print(audioURL!)
            print("********************")
            
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError{
            print(error)
        }
    }
}
