import Foundation

struct Pokemon: Decodable {
    let name: String
    let sprites: Sprites
    let id: Int
    let weight: Int
    let height: Int

    // hauteur en decimetre et poids en decagramme au kilogramme
    var heightInHectometers: Float {
        return Float(height)
    }

    var weightInDecagrams: Float {
        return Float(weight)
    }

}

struct Sprites: Decodable {
    let front_default: String
    let back_default: String

    enum CodingKeys: String, CodingKey {
        case front_default
        case back_default = "back_default"
    }
}

class PokemonDownloader {
    static let shared = PokemonDownloader()
    private init() {}

    func getPokemon(id: Int, completion: @escaping (Result<Pokemon, Error>) -> Void) {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let decoder = JSONDecoder()
                do {
                    let pokemon = try decoder.decode(Pokemon.self, from: data)
                    completion(.success(pokemon))
                } catch {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }
}
