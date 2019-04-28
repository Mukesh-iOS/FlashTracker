//
//  FTViewController.swift
//  FlashTracker
//
//  Created by Mukesh on 16/03/19.
//  Copyright © 2019 Mukesh. All rights reserved.
//

import UIKit
import MapKit

private enum StringConstants: String {
    
    case annotationIdentifier = "Pin"
    case markerImage = "Marker"
    
    var description: String {
        return self.rawValue
    }
}

class FTViewController: UIViewController {
    
    private var viewModel: FTVehiclesViewModel?
    private var isDetailedAnnotationVisible = false
    private var detailedAnnotationViewVehicleId: Int?
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var activityView: UIActivityIndicatorView = {
        let activitySpinnerView = UIActivityIndicatorView(style: .gray)
        activitySpinnerView.center = view.center
        view.addSubview(activitySpinnerView)
        activitySpinnerView.isHidden = true
        return activitySpinnerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
    }
    
    private func initialSetup() {
        
        viewModel = FTVehiclesViewModel()
        
        viewModel?.infoList.notify(notifier: { [weak self] (info: [VehicleInfo]) in
            self?.activityView.hideActivity()
            self?.updateScreen()
        })
        
        viewModel?.info.notify(notifier: { [weak self] (info: VehicleInfo) in
            self?.activityView.hideActivity()
        })
        
        viewModel?.error.notify(notifier: { [weak self] (error: FTError) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            strongSelf.activityView.hideActivity()
            
            switch error {
                
            case .Invalid(let message):
                
                UIAlertController.showSimpleAlert(message: message, inViewController: strongSelf)
            }
        })
        
        isDetailedAnnotationVisible = false
        fetchVehicleDetailsFromREST()
    }
    
    private func fetchVehicleDetailsFromREST() {
    
        activityView.showActivityIndicator()
        viewModel?.getVehicles()
    }
    
    // MARK: Update Screen
    
    private func updateScreen() {
        
        addAnnotations()
        mapView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    // MARK: Creating Annotation
    
    private func addAnnotations() {

        guard let vehicleList = viewModel?.infoList.value else {
            return
        }
        
        for vehicle in vehicleList {
            
            assert(vehicle.latitude != nil && vehicle.longitude != nil, "Geolocation should not be nil")
        
            let point = FTVehicleAnnotation(coordinate: CLLocationCoordinate2D(latitude: vehicle.latitude! , longitude: vehicle.longitude!))
            point.vehicleID = vehicle.id
            mapView.addAnnotation(point)
        }
    }
}

extension FTViewController: MKMapViewDelegate {
    
    // MARK: MKMapview Delegates

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: StringConstants.annotationIdentifier.rawValue)
        if annotationView == nil{
            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: StringConstants.annotationIdentifier.rawValue)
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(named: StringConstants.markerImage.rawValue)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Needed to track if same annotation is tapped again
        let annotationGesture = UITapGestureRecognizer(target: self, action: #selector(handleAnnotationGesture(sender:)))
        view.addGestureRecognizer(annotationGesture)
        
        let vehicleID = (view.annotation as! FTVehicleAnnotation).vehicleID ?? nil
        
        // Execution will be stopped if same annotation is selected again ( Annotation will be removed in gesture recognizer hanler )
        if isDetailedAnnotationVisible && detailedAnnotationViewVehicleId == vehicleID {
            
            isDetailedAnnotationVisible = false
            return
        }
        
        if view.annotation is MKUserLocation {
            // Don't proceed with custom callout
            return
        }
        
        // Will be executed if vehicle info is already fetched from REST
        if let vehicleInfo = viewModel?.info.value {
            
            let views = Bundle.main.loadNibNamed(FTVehicleDetailedInfoView.reusableId, owner: nil, options: nil)
            
            guard let calloutView = views?[0] as? FTVehicleDetailedInfoView else {
                
                return
            }
            
            calloutView.vehicleName.text = vehicleInfo.name
            calloutView.vehicleType.text = vehicleInfo.description
            calloutView.batteryLevel.text = viewModel?.batteryPercentage
            calloutView.vehicleTime.text = viewModel?.vehicleTime
            calloutView.price.text = viewModel?.cost
            
            calloutView.center = CGPoint(x: view.bounds.size.width / 2, y: -calloutView.bounds.size.height * 0.45)
            view.addSubview(calloutView)
            isDetailedAnnotationVisible = true
            detailedAnnotationViewVehicleId = (view.annotation as? FTVehicleAnnotation)?.vehicleID ?? nil
            mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            return
        }
        
        // Will be executed if vehicle info is not fetched from REST
        if let vehicleAnnotation = view.annotation as? FTVehicleAnnotation {
            
            activityView.showActivityIndicator()
            
            viewModel?.getVehicleInfo(withVehicleId: vehicleAnnotation.vehicleID, completion: { [weak self] in
                
                self?.mapView(mapView, didSelect: view)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        if view.isKind(of: AnnotationView.self) {
            for subview in view.subviews {
                // Empty vehicle info model to get updated value next time during REST call
                viewModel?.info.value = nil
                subview.removeFromSuperview()
            }
        }
    }
    
    // MARK: MKMapview Helpers
    
    @objc private func handleAnnotationGesture(sender: UITapGestureRecognizer?) {
        
        let selectedAnnotations = mapView.selectedAnnotations
        for annotationView: MKAnnotation in selectedAnnotations {
            mapView.deselectAnnotation(annotationView, animated: true)
        }
    }
}
