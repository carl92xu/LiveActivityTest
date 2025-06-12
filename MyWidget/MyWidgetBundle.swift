//
//  MyWidgetBundle.swift
//  MyWidget
//
//  Created by carl on 6/12/25.
//

import WidgetKit
import SwiftUI

@main
struct MyWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyWidget()
        LiveActivityWidget()
    }
}
