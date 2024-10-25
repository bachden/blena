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
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Blena</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: rgb(255,255,255);
            color: #333;
        }

        .logo {
            font-size: 36px;
            font-weight: bold;
            color: blue;
            text-align: center;
            padding: 10px 20px;
            margin-bottom: 20px;
            text-shadow: 1px 1px 6px rgba(0, 0, 0, 0.3);
        }

        .icon-grid {
            display: flex;
            justify-content: center;
            gap: 10px;
            overflow-x: auto; /* Allows horizontal scrolling if necessary */
            flex-wrap: nowrap; /* Prevents icons from wrapping to a new line */
            padding: 10px;
            width: 100%;
        }

        .homepage_link {
            border-radius: 12px;
            text-decoration: none;
            transition: transform 0.2s, box-shadow 0.2s;
            flex-shrink: 0; /* Prevents icons from shrinking when overflowing */
        }

        .homepage_link:hover {
            transform: translateY(-4px);
            box-shadow: 0 3px 15px rgba(0, 0, 0, 0.2);
        }

        .icon-box {
            text-align: center;
            background: white;
            border-radius: 12px;
            padding: 10px;
            width: 60px;
            height: 90px;
            color: grey;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: background 0.3s;
        }

        .icon-box:hover {
            background: #f0f0f0;
        }

        .icon-box img {
            width: 50px;
            height: 50px;
            object-fit: contain;
            margin-bottom: 6px;
        }

        .icon-box p {
            font-size: 12px;
            color: #555;
            margin: 0;
        }

        @media (max-width: 375px) {
            .icon-grid {
                gap: 5px;
            }

            .icon-box {
                width: 55px;
                height: 80px;
            }

            .logo {
                font-size: 32px;
                margin-bottom: 15px;
            }
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
                <p>YouTube</p>
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
