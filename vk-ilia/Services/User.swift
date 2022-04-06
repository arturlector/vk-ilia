//
//  User.swift
//  vk-ilia
//
//  Created by Artur Igberdin on 06.04.2022.
//

import Foundation

//Синглтон - объект который имеет глобальную точку доступа

final class User {
    
    private init() {}
    
    static let shared = User() //Глобальная статическая память
    
    var userId: String = ""
    var token: String = ""
    var expiresIn: String = ""
}
