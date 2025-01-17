//
//  BooksPresenter.swift
//  Books Library
//
//  Created by sally asiri on 18/04/1443 AH.
//

import Foundation
import CoreGraphics

protocol BooksView: class {
    func showProgress()
    func hideProgress()
    func refreshBooksView()
    func showError(_ title: String, message: String)
}

protocol BooksPresenter {
    var numberOfBooks: Int { get }
    var router: BooksViewRouter { get }
    func viewDidLoad()
    func configure(cell: BookCellView, for row: Int)
    func getCellSize(size: CGRect) -> CGSize
    func didSelect(row: Int)
}

class BooksPresenterImplementation: BooksPresenter {
    fileprivate weak var view: BooksView?
    fileprivate var booksGateway: BooksGateway
    internal var router: BooksViewRouter
    internal var books: [Book] = []
    
    var numberOfBooks: Int {
        return books.count
    }
    
    init(view: BooksView, booksGateway: BooksGateway, router: BooksViewRouter) {
        self.view = view
        self.booksGateway = booksGateway
        self.router = router
    }
    
    func viewDidLoad() {
        // display loading indicator
        self.view?.showProgress()
        
        self.booksGateway.fetchBooks { [weak self] (books, error) in
            // hide loading indicator
            self?.view?.hideProgress()
            
            // error
            guard error == nil else {
                self?.handleBooksError(error!)
                return
            }
            
            self?.handleBooksReceived(books)
        }
    }
    
    func configure(cell: BookCellView, for row: Int) {
        let book = books[row]
        cell.display(imageName: book.image)
        cell.formatCell()
    }
    
    func getCellSize(size: CGRect) -> CGSize {
        // we want 3 cells per row
        let width = size.width / 3
        let offset: CGFloat = 8
        return CGSize(width: width - offset, height: (width - offset) * 1.5)
    }
    
    func didSelect(row: Int) {
        let book = books[row]
        router.presentDetailsView(for: book)
    }
}

// MARK:- Fileprivate functions

fileprivate extension BooksPresenterImplementation {
    func handleBooksReceived(_ books: [Book]) {
        self.books = books
        view?.refreshBooksView()
    }
    
    func handleBooksError(_ error: Error) {
        view?.showError("Error", message: error.localizedDescription)
    }
}
