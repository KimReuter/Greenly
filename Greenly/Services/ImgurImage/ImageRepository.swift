//
//  ImageRepository.swift
//  Greenly
//
//  Created by Kim Reuter on 06.03.25.
//

import Foundation

protocol ImageRepository {
    func uploadImage(data: Data) async throws -> ImageRef
    func deleteImage(_ imageRef: ImageRef) async throws
}
