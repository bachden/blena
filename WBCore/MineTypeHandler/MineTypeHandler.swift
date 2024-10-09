//
//  MineTypeHandler.swift
//  Blena
//
//  Created by Lê Vinh on 10/8/24.
//

import Foundation

class MimeTypeHandler {
    
    // List of downloadable MIME types
    private let downloadableMimeTypes: Set<String> = [
        // Archives and Compressed Files
        "application/zip",
        "application/x-tar",
        "application/x-7z-compressed",
        "application/x-rar-compressed",
        "application/gzip",
        "application/vnd.rar",
        "application/x-bzip",
        "application/x-bzip2",
        "application/x-lzip",
        
        // Documents
        "application/pdf",
        "application/msword",
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document", // DOCX
        "application/vnd.ms-excel",
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // XLSX
        "application/vnd.ms-powerpoint",
        "application/vnd.openxmlformats-officedocument.presentationml.presentation", // PPTX
        "application/rtf",
        "application/x-latex",
        "application/vnd.oasis.opendocument.text", // ODT
        "application/vnd.oasis.opendocument.spreadsheet", // ODS
        "application/vnd.oasis.opendocument.presentation", // ODP
        
        // Images
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/bmp",
        "image/webp",
        "image/svg+xml",
        "image/tiff",
        "image/x-icon", // ICO
        "image/vnd.microsoft.icon", // Microsoft Icon Format
        
        // Audio Files
        "audio/mpeg",
        "audio/wav",
        "audio/aac",
        "audio/ogg",
        "audio/webm",
        "audio/mp4",
        "audio/x-aiff",
        "audio/x-wav",
        "audio/midi",
        "audio/x-midi",
        
        // Video Files
        "video/mp4",
        "video/x-msvideo", // AVI
        "video/x-ms-wmv", // WMV
        "video/mpeg",
        "video/webm",
        "video/ogg",
        "video/quicktime", // MOV
        
        // Text Files
        "text/csv",
        "text/plain",
        "text/markdown",
        "text/vcard",
        "text/calendar",
        
        // Executables and Installers
        "application/octet-stream", // Binary files
        "application/x-msdownload", // Windows EXE files
        "application/x-dosexec",
        "application/x-sh", // Shell script
        "application/x-msdos-program"
    ]
    
    // Function to check if a given MIME type string matches one of the downloadable types
    func isDownloadable(mimeType: String) -> Bool {
        return downloadableMimeTypes.contains(mimeType)
    }
}
