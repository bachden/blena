//
//  CustomHomePage.swift
//  Blena
//
//  Created by Lê Vinh on 10/4/24.
//

import Foundation
import UIKit

let homePageHTMLPage = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blena</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .logo {
            font-size: 48px;
            font-weight: bold;
            color: blue;
            text-align: center;
            padding: 10px 30px;
            margin-bottom: 50px;
        }

        .icon-grid {
            display: flex;
            justify-content: center;
            gap: 20px;
        }
        
        .homepage_link{
            border-radius: 16px;
            text-decoration: none; /* Remove underline */
        }

        .icon-box {
            text-align: center;
            border-radius: 16px;
            padding: 10px;
            width: 60px; /* Width adjusted for content */
            height: 80px; /* Height adjusted for content */
            color: grey;
            display: column;
            flex-direction: column;
            justify-content: center;
        }

        .icon-box img {
            width: 60px;
            height: 60px;
            object-fit: contain; /* Ensure images fit without stretching */
        }

        .icon-box p {
            margin-top: 5px;
            font-size: 14px;
            color: black;
        }
    </style>
</head>
<body>

    <div class="logo">BLENA</div>

    <div class="icon-grid">
        <a href="https://google.com" class="homepage_link">
            <div class="icon-box">
                <img src="https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png" alt="Google">
                <p>Google</p>
            </div>
        </a>
        <a href="https://youtube.com" class="homepage_link">
            <div class="icon-box">
                <img src="https://cdn.pixabay.com/photo/2021/09/11/18/21/youtube-6616310_1280.png" alt="YouTube">
                <p>Youtube</p>
            </div>
        </a>
        <a href="https://wikipedia.org" class="homepage_link">
            <div class="icon-box">
                <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Notification-icon-Wikipedia-logo.svg/1200px-Notification-icon-Wikipedia-logo.svg.png" alt="Wikipedia">
                <p>Wikipedia</p>
            </div>
        </a>
        <a href="https://apple.com" class="homepage_link">
            <div class="icon-box">
                <img src="https://purepng.com/public/uploads/large/purepng.com-apple-logologobrand-logoiconslogos-251519938788qhgdl.png" alt="Apple">
                <p>Apple</p>
            </div>
        </a>
    </div>

</body>
</html>

"""
