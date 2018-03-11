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
    
    init(photoAssets: [PHAsset]) {
        self.photoAssets = photoAssets
    }
    
    func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        
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
    
    func fetchPhotoAlbums(onCompletion: (() -> ())?) {
        let fetchedAllPhotoAssetCollections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        let allPhotoAlbum = fetchedAllPhotoAssetCollections.firstObject
        if let allPhotoAlbum = allPhotoAlbum {
            photoAlbums.append(TKAlbum.parseTo(allPhotoAlbum, title: "All Photo"))
        }
        
        let fetchedPhotoAssetCollections = PHAssetCollection.fetchAssetCollections(
            with: .album, subtype: .albumRegular, options: nil)
        fetchedPhotoAssetCollections.objects(at: IndexSet(0 ..< fetchedPhotoAssetCollections.count))
            .filter { $0.estimatedAssetCount > 0 }
            .forEach { photoAlbums.append(TKAlbum.parseTo($0)) }
        
        currentAlbum = photoAlbums.first
        onCompletion?()
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
