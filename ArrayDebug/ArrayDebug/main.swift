//
//  main.swift
//  ArrayDebug
//
//  Created by Marius Bronner on 01.11.19.
//  Copyright © 2019 Marius Bronner. All rights reserved.
//

import Foundation

func sayHi() {
    print("hi")
}

var array = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

var index = 4

while index < array.count {
    array.remove(at: index)
    index += 1
}

print(array)
