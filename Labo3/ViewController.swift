import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pokemonInfoLabel: UILabel! // Assurez-vous que ce UILabel est connecté dans votre storyboard ou xib
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: "https://th.bing.com/th/id/R.760e909e4a58282d4bfa18c48fabe1f9?rik=HAXJvbrA8nJ9jA&pid=ImgRaw&r=0")!
        ImageDownloader.shared.downloadImage(from:url) { image in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.onClick))
        tapGesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(tapGesture)
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func onClick() {
        // Génère un identifiant aléatoire pour un Pokemon.
        let randomId = Int.random(in: 1...100)

        PokemonDownloader.shared.getPokemon(id: randomId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self?.pokemonInfoLabel.text = """
                    ID: \(pokemon.id)
                    Name: \(pokemon.name)
                    Height: \(pokemon.heightInMeters) m
                    Weight: \(pokemon.weightInKilograms) kg
                    """

                    if let imageUrl = URL(string: pokemon.sprites.front_default) {
                        ImageDownloader.shared.downloadImage(from: imageUrl) { image in
                            self?.imageView.image = image
                        }
                    }

                case .failure(let error):
                    self?.pokemonInfoLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
}
