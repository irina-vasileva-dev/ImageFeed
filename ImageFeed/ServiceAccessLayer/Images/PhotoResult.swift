import Foundation

// MARK: - UrlsResult

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// MARK: - PhotoResult

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String?
    let blurHash: String?
    let likes: Int
    let likedByUser: Bool
    let welcomeDescription: String?
    let urls: UrlsResult

    private enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case welcomeDescription = "description"
        case urls
    }
}
