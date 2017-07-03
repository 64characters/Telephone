//
//  CallHistoryViewController.swift
//  Telephone
//
//  Copyright © 2008-2016 Alexey Kuznetsov
//  Copyright © 2016-2017 64 Characters
//
//  Telephone is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Telephone is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//

import Cocoa

final class CallHistoryViewController: NSViewController {
    var keyView: NSView {
        return tableView
    }
    weak var target: CallHistoryViewEventTarget? {
        didSet {
            target?.shouldReloadData()
        }
    }
    fileprivate var records: [PresentationCallHistoryRecord] = []
    @IBOutlet fileprivate weak var tableView: NSTableView!

    init() {
        super.init(nibName: "CallHistoryViewController", bundle: nil)!
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        target?.shouldReloadData()
    }

    override func keyDown(with event: NSEvent) {
        if isReturnKey(event) {
            pickRecord()
        } else if isDeleteKey(event) {
            deleteRecord()
        } else {
            super.keyDown(with: event)
        }
    }

    func updateNextKeyView(_ view: NSView) {
        keyView.nextKeyView = view
    }

    @IBAction func didDoubleClick(_ sender: NSTableView) {
        guard sender.clickedRow != -1 else { return }
        pickRecord()
    }

    private func pickRecord() {
        guard !records.isEmpty else { return }
        target?.didPickRecord(withIdentifier: records[tableView.selectedRow].identifier)
    }

    private func deleteRecord() {
        guard !records.isEmpty else { return }
        let record = records[tableView.selectedRow]
        makeAlert(recordName: record.date).beginSheetModal(for: view.window!) { response in
            if response == NSAlertFirstButtonReturn {
                self.target?.shouldRemoveRecord(withIdentifier: record.identifier)
            }
        }
    }

    private func isReturnKey(_ event: NSEvent) -> Bool {
        return event.keyCode == 0x24
    }

    private func isDeleteKey(_ event: NSEvent) -> Bool {
        return event.keyCode == 0x33 || event.keyCode == 0x75
    }
}

extension CallHistoryViewController: CallHistoryView {
    func show(_ records: [PresentationCallHistoryRecord]) {
        let oldRecords = self.records
        let oldIndex = tableView.selectedRow
        self.records = records
        reloadTableView(old: oldRecords, new: records)
        restoreSelection(oldIndex: oldIndex, old: oldRecords, new: records)
    }

    private func reloadTableView(old: [PresentationCallHistoryRecord], new: [PresentationCallHistoryRecord]) {
        if case let diff = ArrayDifference(before: old, after: new), diff.isPrepended, diff.count <= 2 {
            tableView.insertRows(at: IndexSet(integersIn: 0..<diff.count), withAnimation: .slideDown)
        } else {
            tableView.reloadData()
        }
    }

    private func restoreSelection(oldIndex: Int, old: [PresentationCallHistoryRecord], new: [PresentationCallHistoryRecord]) {
        guard !records.isEmpty else { return }
        tableView.selectRowIndexes(
            IndexSet(integer: RestoredSelectionIndex(indexBefore: oldIndex, before: old, after: new).value),
            byExtendingSelection: false
        )
    }
}

extension CallHistoryViewController: NSTableViewDataSource {
    func numberOfRows(in view: NSTableView) -> Int {
        return records.count
    }

    func tableView(_ view: NSTableView, objectValueFor column: NSTableColumn?, row: Int) -> Any? {
        return records[row]
    }
}

private func makeAlert(recordName name: String) -> NSAlert {
    let a = NSAlert()
    a.messageText = String(
        format: NSLocalizedString(
            "Are you sure you want to delete the record “%@”?", comment: "Call history record removal alert."
        ), name
    )
    a.informativeText = NSLocalizedString(
        "This action cannot be undone.", comment: "Call history record removal alert informative text."
    )
    a.addButton(withTitle: NSLocalizedString("Delete", comment: "Delete button."))
    a.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel button."))
    a.buttons[1].keyEquivalent = "\u{1b}"
    return a
}
