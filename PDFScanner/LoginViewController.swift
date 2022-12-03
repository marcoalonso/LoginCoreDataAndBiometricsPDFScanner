//
//  ViewController.swift
//  PDFScanner
//
//  Created by Marco Alonso Rodriguez on 26/11/22.
//

import UIKit
import CoreData
import LocalAuthentication

class LoginViewController: UIViewController {
    
    @IBOutlet weak var biometricLabel: UILabel!
    @IBOutlet weak var biometricsImage: UIImageView!
    @IBOutlet weak var usuarioTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    //MARK: Variables
    var usuarios: [Usuario] = []
    var usuarioRegistrado = false
    
    let defaults = UserDefaults.standard
    
    //Conexion a la bd o al contexto
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Biometrics
    let contextoBiometrico = LAContext()
    var error: NSError? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        configurarUI()
    }
    
    private func configurarUI() {
        biometricsImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loginBiometricos)))
        biometricsImage.isUserInteractionEnabled = true
    }
    
    @objc func loginBiometricos() {
        print("Login ")
        biometrics()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        leerUsuarios()
        print("usuarios.count \(usuarios.count)")
        print("usuarios : \(usuarios)")
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if defaults.string(forKey: "sesionIniciada") != nil  {
            performSegue(withIdentifier: "login", sender: self)
            print("Debug: sesionIniciada")
        }
        
        //Saber si tiene face id / touch id
        if contextoBiometrico.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            evaluateBiometryType()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        usuarioRegistrado = false
    }
    
    //MARK: Functions
    func biometrics() {
        if contextoBiometrico.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reasen = "Por favor autoriza el inicio de sesion con touchID o FaceID"
            contextoBiometrico.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasen) { succes, error in
                DispatchQueue.main.async {
                    guard succes, error == nil else {
                        print("error no se detecto huella o rostro")
                        return
                    }
                    //Avanzar o iniciar sesion
                    self.performSegue(withIdentifier: "login", sender: self)
                }
            }
            
        }else {
            print("Error en la autenticacion, al usar biometricos")
        }
    }
    
    
    func evaluateBiometryType() {
        switch contextoBiometrico.biometryType {
        case .faceID:
            print("Face ID")
            biometricsImage.image = UIImage(named: "face")
            biometricLabel.text = "Inicia sesion con Face ID"
            
        case .touchID:
            print("Touch ID")
            biometricsImage.image = UIImage(named: "touch")
            biometricLabel.text = "Inicia sesion con Touch ID"
            
        case .none:
            print("No esta configurado")
            print("Iniciar sesion con contraseña")
                
        default:
            print("Desconocido")
        }
    }
    
    func leerUsuarios(){
        let solicitud: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        do{
            usuarios = try contexto.fetch(solicitud)
            print("Debug: Se leyo correctamente de la BD !")
        } catch {
            print("error al leer de la BD")
        }
    }
    
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }

    //MARK: Actions
    
    @IBAction func iniciarSesionButton(_ sender: UIButton) {
        //lectura de informacion con defaults
        //        if usuarioTF.text == defaults.string(forKey: "user") && passwordTF.text == defaults.string(forKey: "password") {
        
        //Consulta usuarios previamente cargados en core data
        for user in usuarios {
            print("user: \(user.nombre)")
            if user.nombre == usuarioTF.text && user.password == passwordTF.text {
                print("usuario encontrado, login exitoso!")
                performSegue(withIdentifier: "login", sender: self)
                usuarioRegistrado = true
            }
        }
        if !usuarioRegistrado {
            mostrarAlerta(titulo: "ERROR AL INICIAR SESION", mensaje: "Combinacion de usuario y contraseña incorrecta")
        }
    }
    
}

