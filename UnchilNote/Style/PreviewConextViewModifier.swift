//
//  PreviewConextViewModifier.swift
//  UnchilNote
//
//  Created by 여운칠 on 2022/07/12.
//
import Foundation
import SwiftUI

struct PreviewContextViewModifier<Preview: View, Destination: View>: ViewModifier {
    @State private var isActive: Bool = false
    private let previewContent: Preview?
    private let destination: Destination?
    private let preferredContentSize: CGSize?
    private let actions: [UIAction]
    private let presentAsSheet: Bool

    init(
        destination: Destination,
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) {
        self.destination = destination
        self.previewContent = preview
        self.preferredContentSize = preferredContentSize
        self.presentAsSheet = presentAsSheet
        self.actions = actions().map(\.uiAction)
    }

    init(
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) {
        self.destination = destination
        self.previewContent = nil
        self.preferredContentSize = preferredContentSize
        self.presentAsSheet = presentAsSheet
        self.actions = actions().map(\.uiAction)
    }

    init(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) {
        self.destination = nil
        self.previewContent = preview
        self.preferredContentSize = preferredContentSize
        self.presentAsSheet = presentAsSheet
        self.actions = actions().map(\.uiAction)
    }

    @ViewBuilder
    public func body(content: Content) -> some View {

        ZStack {
            if !presentAsSheet, destination != nil {

                NavigationLink(
                    destination: destination,
                    isActive: $isActive,
                    label: { EmptyView() }
                )
                .hidden()
				.frame(width: 0, height: 0)

            }
            content
                .overlay(

                    PreviewContextView(
                        preview: preview,
                        preferredContentSize: preferredContentSize,
                        actions: actions,
                        isPreviewOnly: destination == nil,
                        isActive: $isActive
                    )
					.opacity(0.05)
                    .if(presentAsSheet) {
                        $0.sheet(isPresented: $isActive) {
                            destination
                        }
                    }
                )
        }
    }

    @ViewBuilder
    private var preview: some View {
        if let preview = previewContent {
            preview
        } else {
            destination
        }
    }
}

struct PreviewContextAction {

    private let image: String?
    private let systemImage: String?
    private let attributes: UIMenuElement.Attributes
    private let action: (() -> ())?
    private let title: String

    init(
        title: String
    ) {
        self.init(title: title, image: nil, systemImage: nil, attributes: .disabled, action: nil)
    }

    init(
        title: String,
        attributes: UIMenuElement.Attributes = [],
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: nil, systemImage: nil, attributes: attributes, action: action)
    }

    init(
        title: String,
        systemImage: String,
        attributes: UIMenuElement.Attributes = [],
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: nil, systemImage: systemImage, attributes: attributes, action: action)
    }

    init(
        title: String,
        image: String,
        attributes: UIMenuElement.Attributes = [],
        action: @escaping () -> ()
    ) {
        self.init(title: title, image: image, systemImage: nil, attributes: attributes, action: action)
    }

    private init(
        title: String,
        image: String?,
        systemImage: String?,
        attributes: UIMenuElement.Attributes,
        action: (() -> ())?
    ) {
        self.title = title
        self.image = image
        self.systemImage = systemImage
        self.attributes = attributes
        self.action = action
    }

    private var uiImage: UIImage? {
        if let image = image {
            return UIImage(named: image)
        } else if let systemImage = systemImage {
            return UIImage(systemName: systemImage)
        } else {
            return nil
        }
    }

    fileprivate var uiAction: UIAction {
        UIAction(
            title: title,
            image: uiImage,
            attributes: attributes) { _ in
            action?()
        }
    }
}

//@_functionBuilder
@resultBuilder
struct ButtonBuilder {
    public static func buildBlock(_ buttons: PreviewContextAction...) -> [PreviewContextAction] {
        buttons
    }
}



extension View {

	func previewContextMenu<Preview:View, Destination:View> (
        preview: Preview,
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier(
                destination: destination,
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

    func previewContextMenu<Preview: View>(
        preview: Preview,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier<Preview, EmptyView>(
                preview: preview,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

 func previewContextMenu<Destination: View>(
        destination: Destination,
        preferredContentSize: CGSize? = nil,
        presentAsSheet: Bool = false,
        @ButtonBuilder actions: () -> [PreviewContextAction] = { [] }
    ) -> some View {
        modifier(
            PreviewContextViewModifier<EmptyView, Destination>(
                destination: destination,
                preferredContentSize: preferredContentSize,
                presentAsSheet: presentAsSheet,
                actions: actions
            )
        )
    }

	@ViewBuilder
    func `if`<Content: View>(
        _ conditional: Bool,
        @ViewBuilder content: (Self) -> Content
    ) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ conditional: Bool,
        @ViewBuilder if ifContent: (Self) -> TrueContent,
        @ViewBuilder else elseContent: (Self) -> FalseContent
    ) -> some View {
        if conditional {
            ifContent(self)
        } else {
            elseContent(self)
        }
    }

    @ViewBuilder
    func ifLet<Value, Content: View>(
        _ value: Value?,
        @ViewBuilder content: (Self, Value) -> Content
    ) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }

}
