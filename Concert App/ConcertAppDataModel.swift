//
//  ConcertAppDataModel.swift
//  Concert App
//
//  Created by Michael Tempestini on 2/26/26.
//

/*
 CORE DATA MODEL SETUP INSTRUCTIONS:
 
 You'll need to create a Core Data Model file in Xcode:
 1. File > New > File > Data Model
 2. Name it "ConcertApp"
 3. Create three entities with the following attributes:
 
 ENTITY: Concert
 Attributes:
   - id: UUID
   - date: Date
   - venueName: String (Optional)
   - city: String (Optional)
   - state: String (Optional)
   - concertDescription: String (Optional)
   - setlistURL: String (Optional)
   - concertType: String (Optional) // "standard" or "festival"
   - friendsTags: String (Optional)
 
 Relationships:
   - artists: To-Many relationship to Artist, Delete Rule: Cascade
   - photos: To-Many relationship to ConcertPhoto, Delete Rule: Cascade
 
 ENTITY: Artist
 Attributes:
   - id: UUID
   - name: String (Optional)
   - isHeadliner: Boolean (default: false)
 
 Relationships:
   - concert: To-One relationship to Concert, Delete Rule: Nullify
 
 ENTITY: ConcertPhoto
 Attributes:
   - id: UUID
   - photoIdentifier: String (Optional) // Photos framework local identifier
   - dateAdded: Date (Optional)
   - isVideo: Boolean (default: false)
 
 Relationships:
   - concert: To-One relationship to Concert, Delete Rule: Nullify
*/

import Foundation
