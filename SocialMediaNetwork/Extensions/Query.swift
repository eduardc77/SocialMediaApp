//
//  Query+EXT.swift
//  SocialMedia
//

import Combine
import FirebaseFirestore

public extension Query {
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        try await getDocumentsWithSnapshot(as: type).posts
    }
    
    func getDocumentsWithSnapshot<T>(as type: T.Type) async throws -> (posts: [T], lastDocument: DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let posts = try snapshot.documents.map({ document in
            try document.data(as: T.self)
        })
        return (posts, snapshot.documents.last)
    }
    
    func getDocumentIDsWithSnapshot() async throws -> (postIDs: [String], lastDocument: DocumentSnapshot?) {
        let snapshot = try await self.getDocuments()
        let documentIds = snapshot.documents.map({ $0.documentID })
        return (documentIds, snapshot.documents.last)
    }
    
    func startOptionally(afterDocument lastDocument: DocumentSnapshot?) -> Query {
        guard let lastDocument else { return self }
        return self.start(afterDocument: lastDocument)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<(DocChangeType<T>, DocumentSnapshot?), Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<(DocChangeType<T>, DocumentSnapshot?), Error>()
        
        let listener = self.addSnapshotListener(includeMetadataChanges: false) { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No documents")
                return
            }
            var documentChangeType: DocChangeType<T> = .none
           
            var newDocuments: [T] = []
            var newDocumentsAdded: Bool = false
            var postGotRemoved: Bool = false
            querySnapshot?.documentChanges.forEach { documentChange in
                if documentChange.type == .modified, let postModified = try? documentChange.document.data(as: T.self) {
                    documentChangeType = .modified(post: postModified)
                }
                if documentChange.type == .removed, let postRemoved = try? documentChange.document.data(as: T.self) {
                    documentChangeType = .removed(post: postRemoved)
                    postGotRemoved = true
                }
                if documentChange.type == .added, let postAdded = try? documentChange.document.data(as: T.self), !postGotRemoved {
              
                    if !newDocumentsAdded {
                        newDocuments = documents.compactMap({ try? $0.data(as: T.self) })
                        print(newDocuments.count)
                        documentChangeType = .added(posts: newDocuments)
                        newDocumentsAdded = true
                    }
                }
            }
            
            
            publisher.send((documentChangeType, documents.last))
        }
        return (publisher.eraseToAnyPublisher(), listener)
    }
}

public enum DocChangeType<T> {
    case none
    case added(posts: [T])
    case modified(post: T)
    case removed(post: T)
}
