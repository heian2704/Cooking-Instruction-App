import UIKit
import FirebaseAuth
import GoogleSignIn

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!  // For recipes
    @IBOutlet weak var categoriesCollectionView: UICollectionView!  // For categories
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var signOutButton: UIButton!
    
    let viewModel = HomeViewModel()
    private var searchWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the navigation title
        self.title = "Cook Craft"
        navigationController?.navigationBar.tintColor = .black
        
        // Remove add recipe button if not needed
        // navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRecipe))

        // Setup UI and bind to ViewModel
        setupCollectionViewLayout()
        setupCollectionView()
        bindViewModel()
        
        searchBar.delegate = self
        
        // Fetch initial data (all recipes)
        viewModel.fetchCategories()
        viewModel.fetchRecipes(query: "")
    }
    
    // MARK: - Setup Methods
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        categoriesCollectionView.delegate = self
        categoriesCollectionView.dataSource = self
    }

    private func setupCollectionViewLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let padding: CGFloat = 10
            let itemsPerRow: CGFloat = 2
            let availableWidth = collectionView.frame.width - (padding * (itemsPerRow + 1))
            let itemWidth = availableWidth / itemsPerRow
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 50)
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
        
        if let categoriesLayout = categoriesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            categoriesLayout.scrollDirection = .horizontal
            categoriesLayout.minimumLineSpacing = 10
            categoriesLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
    }
    
    // MARK: - Bind ViewModel
    
    private func bindViewModel() {
        viewModel.onRecipesFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onCategoriesFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.categoriesCollectionView.reloadData()
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoriesCollectionView {
            return viewModel.categories.count
        } else {
            return viewModel.filteredRecipes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoriesCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
                return UICollectionViewCell()
            }
            let category = viewModel.categories[indexPath.row]
            cell.configure(with: category)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecipeCardCell", for: indexPath) as? RecipeCardCell else {
                return UICollectionViewCell()
            }

            let recipe = viewModel.filteredRecipes[indexPath.row]
            cell.configure(with: recipe)
            
            cell.buttonAction = { [weak self] in
                self?.navigateToRecipeDetail(recipe: recipe)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoriesCollectionView {
            let category = viewModel.categories[indexPath.row]
            viewModel.filterRecipes(by: category.name)
        }
    }
    
    // MARK: - Navigation
    
    func navigateToRecipeDetail(recipe: Recipe) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "RecipeDetailViewController") as? RecipeDetailViewController {
            detailVC.recipe = recipe
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - Sign Out Logic
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        viewModel.signOut { [weak self] result in
            switch result {
            case .success:
                self?.navigateToIconAppViewController()
            case .failure(let error):
                self?.showError(error.localizedDescription)
            }
        }
    }
    
    private func navigateToIconAppViewController() {
        guard let window = UIApplication.shared.windows.first else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "IconAppViewController")
        window.rootViewController = signInVC
        window.makeKeyAndVisible()
    }

    // MARK: - Error Handling
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
