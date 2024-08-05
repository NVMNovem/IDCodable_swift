import Foundation
import IDCodable

@IDCodable
enum Itemgroup {
    
    @Codable(id: "M5Q1Q7CA7P", codable: "Test 1") case TEST_1
    @Codable(id: "OA1G29Y2D5", codable: "Test 2") case TEST_2
}

@IDCodable
enum Status {
    
    @Codable(id: "TB4AKAOM84", codable: 1) case created
    @Codable(id: "DJX3SZZVCN", codable: 2) case started
}
