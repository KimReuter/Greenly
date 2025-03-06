//
//  UploadResponse.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

struct UploadResponse: Codable {
    let data: UploadResponseData
    let success: Bool
    let status: Int
}

struct UploadResponseData: Codable {
    let id: String
    let deletehash: String
    let link: String
}
