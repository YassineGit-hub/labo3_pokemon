import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pokemonInfoLabel: UILabel!
    
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
        let randomId = Int.random(in: 1...100)

        PokemonDownloader.shared.getPokemon(id: randomId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let pokemon):
                    self?.pokemonInfoLabel.text = """
                    ID: \(pokemon.id)
                    Name: \(pokemon.name)
                    Height: \(pokemon.heightInHectometers) décimètres
                    Weight: \(pokemon.weightInDecagrams) hectogrammes
                    """

                    if let frontImageUrl = URL(string: pokemon.sprites.front_default) {
                        ImageDownloader.shared.downloadImage(from: frontImageUrl) { [weak self] image in
                            self?.imageView.image = image
                        }
                    }
                    
                    // Check if the Pokemon has a back image URL
                    if let backImageUrl = URL(string: pokemon.sprites.back_default) {
                        ImageDownloader.shared.downloadImage(from: backImageUrl) { [weak self] image in
                            if let frontImage = self?.imageView.image, let backImage = image {
                                // Combine the front and back images side by side
                                let combinedImage = self?.combineImages(frontImage: frontImage, backImage: backImage)
                                self?.imageView.image = combinedImage
                            }
                        }
                    }

                case .failure(let error):
                    self?.pokemonInfoLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func combineImages(frontImage: UIImage, backImage: UIImage) -> UIImage {
        let spacing: CGFloat = 5.0 // Espace désiré entre les deux photos
        let yOffset: CGFloat = 10.0 // Décalage désiré sur l'axe des y pour l'image dorsale
        let size = CGSize(width: frontImage.size.width + backImage.size.width + spacing, height: max(frontImage.size.height, backImage.size.height))
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        frontImage.draw(in: CGRect(x: 0, y: 0, width: frontImage.size.width, height: frontImage.size.height))
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        backImage.draw(in: CGRect(x: frontImage.size.width + spacing, y: yOffset, width: backImage.size.width, height: backImage.size.height))
        
        context?.restoreGState()
        
        let combinedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return combinedImage ?? frontImage
    }

}
