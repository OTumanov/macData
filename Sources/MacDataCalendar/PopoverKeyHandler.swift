import AppKit
import SwiftUI

/// Captures arrow keys and T without drawing a focus ring on the popover.
struct PopoverKeyHandler: NSViewRepresentable {
    var onPreviousMonth: () -> Void
    var onNextMonth: () -> Void
    var onToday: () -> Void

    func makeNSView(context: Context) -> PopoverKeyNSView {
        let view = PopoverKeyNSView()
        view.onPreviousMonth = onPreviousMonth
        view.onNextMonth = onNextMonth
        view.onToday = onToday
        return view
    }

    func updateNSView(_ nsView: PopoverKeyNSView, context: Context) {
        nsView.onPreviousMonth = onPreviousMonth
        nsView.onNextMonth = onNextMonth
        nsView.onToday = onToday
    }
}

final class PopoverKeyNSView: NSView {
    var onPreviousMonth: (() -> Void)?
    var onNextMonth: (() -> Void)?
    var onToday: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        DispatchQueue.main.async { [weak self] in
            guard let self, let window = self.window else { return }
            window.makeFirstResponder(self)
        }
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            onPreviousMonth?()
        case 124:
            onNextMonth?()
        default:
            if event.charactersIgnoringModifiers?.lowercased() == "t" {
                onToday?()
            } else {
                super.keyDown(with: event)
            }
        }
    }
}
