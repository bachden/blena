//
//  AutoCompleteSearch.swift
//  blena
//
//  Created by Lê Vinh on 11/03/2025.
//

import Foundation

/// Fetches DuckDuckGo autocomplete suggestions.
/// - Parameter query: The user-typed text.
/// - Returns: An array of suggestion strings (the second element in the JSON).
/// - Throws: Networking or parsing errors.
func autoCompleteSuggestion(for query: String) async throws -> [String] {
    // 1. Construct the URL with percent-encoding of the query,
    //    plus "type=list" as requested by DuckDuckGo.
    let searchQuery = query.isEmpty ? "google" : query  // If query is empty, use "google"
    guard let encodedQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://duckduckgo.com/ac/?q=\(encodedQuery)&type=list") else {
        throw URLError(.badURL)
    }
    
    // 2. Use an ephemeral session (no caching) for efficiency
    let config = URLSessionConfiguration.ephemeral
    config.timeoutIntervalForRequest = 10
    config.timeoutIntervalForResource = 10
    let session = URLSession(configuration: config)
    
    // 3. Make the request (async/await)
    let (data, response) = try await session.data(from: url)
    
    // 4. Check the HTTP status code
    if let httpResponse = response as? HTTPURLResponse,
       !(200...299).contains(httpResponse.statusCode) {
        throw URLError(.badServerResponse)
    }
    
    // 5. Parse JSON. The response is an array like:
    //    [
    //      "the typed text",
    //      ["facebook","facebook login", ...]  // <— we want this array
    //    ]
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    
    // 6. Convert to a Swift array. We expect two elements: [String, [String]].
    guard let rootArray = jsonObject as? [Any], rootArray.count >= 2 else {
        return []
    }
    
    // 7. Extract the second element as an array of strings
    let suggestions = rootArray[1] as? [String] ?? []
    
    return suggestions
}
