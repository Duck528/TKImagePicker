//
//  TKAlbum.swift
//  TKImagePicker
//
//  Created by 안덕환 on 2018. 3. 11..
//  Copyright © 2018년 안덕환. All rights reserved.
//

import Foundation
import Photos


class TKAlbum {
    
    var albumTitle = ""
    var photoAssets: [PHAsset]
    var numberOfPhotoAssets: Int { return photoAssets.count }
    var thumbnailPhotoAsset: PHAsset? {
        return photoAssets.first
    }
    
    init(photoAssets: [PHAsset]) {
        self.photoAssets = photoAssets
    }
    
    func photo(at indexPath: IndexPath) -> PHAsset? {
        guard indexPath.item >= 0, indexPath.item < photoAssets.count else { return nil }
        return photoAssets[indexPath.item]
    }
}


extension TKAlbum {
    
    static func parseTo(_ phAssetCollection: PHAssetCollection, title: String? = nil) -> TKAlbum {
        let fetchedAssets = PHAsset.fetchAssets(in: phAssetCollection, options: PHFetchOptions.sortByTime())
        let photoAssets = fetchedAssets.objects(at: IndexSet(0 ..< fetchedAssets.count))
        let album = TKAlbum(photoAssets: photoAssets)
        if let title = title {
            album.albumTitle = title
        } else {
            album.albumTitle = phAssetCollection.localizedTitle ?? ""
        }
        
        return album
    }
}


class TKAlbumCollection {
    
    var photoAlbums: [TKAlbum] = []
    var currentAlbum: TKAlbum?
    var numberOfPhotoAlbums: Int { return photoAlbums.count }
    var checkedPhotoAssets: [PHAsset] = []
    
    var albumSelected: ((TKAlbum) -> ())?
    
    func fetchPhotoAlbums(onCompletion: @escaping (() -> ())) {
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            
            let fetchedAllPhotoAssetCollections = PHAssetCollection.fetchAssetCollections(
                with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
            let allPhotoAlbum = fetchedAllPhotoAssetCollections.firstObject
            if let allPhotoAlbum = allPhotoAlbum {
                self.photoAlbums.append(TKAlbum.parseTo(allPhotoAlbum, title: "All Photo"))
            }
            
            let fetchedPhotoAssetCollections = PHAssetCollection.fetchAssetCollections(
                with: .album, subtype: .albumRegular, options: nil)
            fetchedPhotoAssetCollections.objects(at: IndexSet(0 ..< fetchedPhotoAssetCollections.count))
                .filter { $0.estimatedAssetCount > 0 }
                .forEach { self.photoAlbums.append(TKAlbum.parseTo($0)) }
            
            self.currentAlbum = self.photoAlbums.first
            DispatchQueue.main.async {
                onCompletion()
            }
        }
    }
    
    func selectAlbum(at indexPath: IndexPath) {
        guard let selectedAlbum = album(at: indexPath) else { return }
        currentAlbum = selectedAlbum
        albumSelected?(selectedAlbum)
    }
    
    func album(at indexPath: IndexPath) -> TKAlbum? {
        guard indexPath.item >= 0, indexPath.item < photoAlbums.count else { return nil }
        return photoAlbums[indexPath.item]
    }
    
    func checkedPhotoAsset(at indexPath: IndexPath) -> PHAsset? {
        guard indexPath.item >= 0, indexPath.item < checkedPhotoAssets.count else { return nil }
        return checkedPhotoAssets[indexPath.item]
    }
}
