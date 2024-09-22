import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let viewModel = MapViewModel()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        searchBar.delegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    // MARK: - Zoom In & Zoom Out
    
    @IBAction func zoomInTapped(_ sender: UIButton) {
        let region = mapView.region
        var newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 0.5,
                                       longitudeDelta: region.span.longitudeDelta * 0.5)
        // Set a minimum zoom level to avoid zooming in too much
        newSpan.latitudeDelta = max(newSpan.latitudeDelta, 0.002)
        newSpan.longitudeDelta = max(newSpan.longitudeDelta, 0.002)
        
        let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
        mapView.setRegion(newRegion, animated: true)
    }
    
    @IBAction func zoomOutTapped(_ sender: UIButton) {
        let region = mapView.region
        let newSpan = MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2.0,
                                       longitudeDelta: region.span.longitudeDelta * 2.0)
        let newRegion = MKCoordinateRegion(center: region.center, span: newSpan)
        mapView.setRegion(newRegion, animated: true)
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.fetchStores(query: query) { [weak self] stores in
            DispatchQueue.main.async {
                self?.updateMap(with: stores)
            }
        }
        searchBar.resignFirstResponder()
    }
    
    private func updateMap(with stores: [Store]) {
        mapView.removeAnnotations(mapView.annotations)
        
        for store in stores {
            let annotation = CustomAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: store.lat, longitude: store.lon),
                title: store.name,
                subtitle: ""
            )
            mapView.addAnnotation(annotation)
        }
        
        if !stores.isEmpty {
            let coordinates = stores.map { CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon) }
            let maxLat = coordinates.map { $0.latitude }.max() ?? 0
            let minLat = coordinates.map { $0.latitude }.min() ?? 0
            let maxLon = coordinates.map { $0.longitude }.max() ?? 0
            let minLon = coordinates.map { $0.longitude }.min() ?? 0
            
            let center = CLLocationCoordinate2D(latitude: (maxLat + minLat) / 2, longitude: (maxLon + minLon) / 2)
            let span = MKCoordinateSpan(latitudeDelta: abs(maxLat - minLat) * 1.2, longitudeDelta: abs(maxLon - minLon) * 1.2)
            let region = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        locationManager.stopUpdatingLocation()
        mapView.setCenter(location.coordinate, animated: true)
        
        viewModel.fetchNearbyStores(coordinate: location.coordinate) { [weak self] stores in
            DispatchQueue.main.async {
                self?.updateMap(with: stores)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let customAnnotation = annotation as? CustomAnnotation else { return nil }
        
        let identifier = "CustomAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            let detailButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = detailButton
        } else {
            annotationView?.annotation = customAnnotation
        }
        
        annotationView?.markerTintColor = .red
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = annotationView.annotation as? CustomAnnotation else { return }
        
        let alert = UIAlertController(title: annotation.title, message: "Details not available", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
}
