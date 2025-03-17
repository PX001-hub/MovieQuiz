import Foundation

struct Movie: Codable {
    let id: Int
    let title: String
    let image: String
    let rating: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title = "titleText"
        case image = "primaryImage"
        case rating = "ratingsSummary"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id).hashValue
        
        let titleContainer = try container.decode(TitleText.self, forKey: .title)
        title = titleContainer.text
        
        let imageContainer = try container.decodeIfPresent(PrimaryImage.self, forKey: .image)
        image = imageContainer?.url ?? ""
        
        let ratingContainer = try container.decode(RatingSummary.self, forKey: .rating)
        rating = ratingContainer.aggregateRating
    }
}

struct TitleText: Codable {
    let text: String
}

struct PrimaryImage: Codable {
    let url: String
}

struct RatingSummary: Codable {
    let aggregateRating: Double
} 