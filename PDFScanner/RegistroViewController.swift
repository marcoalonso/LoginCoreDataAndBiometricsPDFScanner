//
//  RegistroViewController.swift
//  PDFScanner
//
//  Created by Marco Alonso Rodriguez on 26/11/22.
//

import UIKit
import CoreData

class RegistroViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    //Conexion a la bd o al contexto
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var contraseñaTextField: UITextField!
    @IBOutlet weak var usuarioTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Functions
    func guardarContexto(){
        do{
            try contexto.save()
            print("Usuario guardado en BD!")
        }catch {
            print("Debug: Error al guardar en core data \(error.localizedDescription)")
        }
    }
    
    //MARK: Actions
    
    @IBAction func registrarButton(_ sender: UIButton) {
      
        //Guardado de informacion con defaults
//        defaults.set(usuarioTextField.text, forKey: "user")
//        defaults.set(contraseñaTextField.text, forKey: "password")
    
        //Nueva forma de guardar informacion con core data
        if let nombreUsuario = usuarioTextField.text, !nombreUsuario.isEmpty {
            if contraseñaTextField.text != "" {
                let contrasenaUsuario = contraseñaTextField.text
                
                let nuevoUsuario = Usuario(context: self.contexto)
                let uuid = UUID().uuidString
                
                nuevoUsuario.id = uuid
                nuevoUsuario.nombre = nombreUsuario
                nuevoUsuario.password = contrasenaUsuario
                guardarContexto()
                
            } else {
                print("Contraseña no puede estar vacía")
            }
            
        }
        
        let alerta = UIAlertController(title: "ATENCION", message: "Usuario creado con éxito!", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Continuar", style: .default) { _ in
            //Do something
            self.performSegue(withIdentifier: "registro", sender: self)
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
        
    }
    
    
    
    @IBAction func inicioSesionBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    

}
