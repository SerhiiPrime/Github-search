//
//  GitHubService.swift
//  GitHub search
//
//  Created by Serhii Onopriienko on 12/2/17.
//  Copyright © 2017 Serhii Onopriienko. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

protocol NetworkServiceProtocol: class {
    
    func getRepos(_ query: String) -> Observable<[Repo]>
}

class NetworkService: NetworkServiceProtocol {
    
    private let networkManager: SessionManager!
    
    init() {
        networkManager = Alamofire.SessionManager.default
    }

    func getRepos(_ query: String) -> Observable<[Repo]> {
        
        return Observable<[Repo]>.create { (observer) -> Disposable in
            let request = self.networkManager
                .request(APIRouter.getRepos(query: query))
                .logRequest()
                .validate()
                .responseData { (response) in
                    switch response.result {
                    case .success(let data):
                        
                        do {
                            let repos = try Decoding.decode([Repo].self, topLevelKey: "items", from: data)
                            observer.onNext(repos)
                            observer.onCompleted()
                        } catch {
                            observer.onError(error)
                        }

                    case .failure(let error):
                        
                        observer.onError(error)
                    }
            }
            return Disposables.create { request.cancel() }
        }
    }
    
}
