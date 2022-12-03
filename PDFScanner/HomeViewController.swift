//
//  HomeViewController.swift
//  PDFScanner
//
//  Created by Marco Alonso Rodriguez on 26/11/22.
//

import UIKit
import Vision
import VisionKit
import PDFKit
import PhotosUI

class HomeViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var permisoVerFotos = false
    
    @IBOutlet weak var previewDoc: UIImageView!
    @IBOutlet weak var terminarButton: UIButton!
    
    let pdfVista = PDFView() //crear archivos PDF
    
    //Camara
    let scanVC = VNDocumentCameraViewController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults.set("logueado", forKey: "sesionIniciada")
        print("Sesion guardada!")
        
        //Validar el permiso de acceder a las fotos
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] status in
            DispatchQueue.main.async { [unowned self] in
                showUI(for: status)
            }
        }
        
        pdfVista.delegate = self
        scanVC.delegate = self
        
        
    }
    //MARK: Funciones
    func mostrarAlerta(titulo: String, mensaje: String) {
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "OK", style: .default) { _ in
            //Do something
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func showUI(for status: PHAuthorizationStatus) {
        
        switch status {
        case .authorized:
            permisoVerFotos = true

        case .limited:
            print("limited")

        case .restricted:
            print("restricted")
            mostrarAlerta(titulo: "Error", mensaje: "Necesitamos el permiso para acceder a tus fotos y poder escanear documentos.")

        case .denied:
            permisoVerFotos = false

        case .notDetermined:
            break

        @unknown default:
            break
        }
    }

    func varFotos() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    //TRabajar con PDFVista
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pdfVista.frame = view.bounds
    }
    
    func cargarPDF(){
        previewDoc.addSubview(pdfVista)
        //crear el documento a mostrar
        let documento = PDFDocument()
        guard let pagina = PDFPage(image: previewDoc.image ?? UIImage(systemName: "car")!) else { return
        }
        documento.insert(pagina, at: 0)
        
        pdfVista.document = documento
        
        //diseño y visualizacion *opcional
        pdfVista.autoScales = true
        pdfVista.usePageViewController(true)
    }
    
    //MARK:  Actions
    
    @IBAction func fotoCamaraButton(_ sender: UIBarButtonItem) {
        present(scanVC, animated: true)
    }
    
    
    @IBAction func seleccionFotoGaleria(_ sender: UIBarButtonItem) {
        if permisoVerFotos {
            varFotos()
        } else {
            print("No hay permiso para ver tus fotos")
        }
    }
    
    
    
    @IBAction func cerrarSesion(_ sender: UIBarButtonItem) {
        defaults.removeObject(forKey: "sesionIniciada")
        print("Sesion borrada")
        mostrarAlerta(titulo: "ATENCION", mensaje: "Cerrando sesion ... ")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.present(vc, animated: true)
        }
        
    }
    
    
    @IBAction func terminarActionButton(_ sender: UIButton) {
        cargarPDF()
        
        //ViewController que me permite guardar, compartir, o mandar por correo
        let vc = UIActivityViewController(activityItems: [self.pdfVista.document?.dataRepresentation()!], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = sender
        vc.popoverPresentationController?.sourceRect = sender.frame
        self.present(vc, animated: true)
    }
}

extension HomeViewController: PDFViewDelegate, VNDocumentCameraViewControllerDelegate {
    //Trabajar con la foto tomada
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if scan.pageCount > 0 {
            previewDoc.image = scan.imageOfPage(at: 0)
            controller.dismiss(animated: true)
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //hacer algo cuando el usuario termina de elegir una foto de la galeria
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Foto seleccionada")
        
        if let imagenSeleccionada = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            previewDoc.image = imagenSeleccionada
        }
        
        cargarPDF()
        
        dismiss(animated: true)
    }
}
