//
//  WebApiClientTests.swift
//  CSCoreSDK
//
//  Created by Vratislav Kalenda on 17/12/15.
//  Copyright © 2015 Applifting. All rights reserved.
//

import Foundation
import XCTest
@testable import CSCoreSDK

//==============================================================================
class WebApiClientTests: XCTestCase
{
    var client : TestApiClient!
    var judgeSession : JudgeSession!
    
    override func setUp() {
        super.setUp()
        let config = WebApiConfiguration(webApiKey: "TEST_API_KEY", environment: Environment(apiContextBaseUrl: Judge.BaseURL, oAuth2ContextBaseUrl: ""), language: "cs-CZ", signingKey: nil)
        self.judgeSession = Judge.startNewSession()
        client = TestApiClient(config: config)
    }
    
    func testGet()
    {
        judgeSession.setNextCase("webapi.posts.get", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.posts.withId(1).get { (result) -> Void in
            switch(result){
            case .success(let post):
                XCTAssertEqual(1, post.id)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testSuccessToFailureTransformation()
    {
        judgeSession.setNextCase("webapi.users.detail.42", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.users.withId(42).get { (result) -> Void in
            switch(result){
            case .success:
                XCTFail()
            case .failure(let error):
                if error is CustomWebApiError {
                    let e = error as! CustomWebApiError
                    XCTAssertEqual("CustomErrorDomain", e.domain)
                    XCTAssertEqual(400, e.code)
                    XCTAssertEqual("THIS_IS_NOT_HUMAN", e.errorCode)
                    expectation.fulfill()
                }
                else {
                    XCTFail( "Error is not of type CustomWebApiError: \(error)" )
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testCreate()
    {
        judgeSession.setNextCase("webapi.users.create", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let request =  CreateUserRequest()
        request.name = "Iron Man"
        request.position = "Rich Scientist"
        request.fullProfileUrl = "https://en.wikipedia.org/wiki/Iron_Man"
        
        client.users.create(request) { (result) -> Void in
            switch(result){
            case .success(let user):
                XCTAssertEqual(5, user.id)
                XCTAssertEqual(5, user.userId)
                XCTAssertEqual("Iron Man", user.name)
                XCTAssertEqual("Rich Scientist", user.position)
                XCTAssertEqual("https://en.wikipedia.org/wiki/Iron_Man", user.fullProfileUrl)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testUpdate()
    {
        judgeSession.setNextCase("webapi.users.update", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let request =  UpdateUserRequest()
        request.name = "Iron Man"
        request.position = "Poor Scientist"
        request.fullProfileUrl = "https://en.wikipedia.org/wiki/Iron_Man"
        
        client.users.withId(5).update(request) { (result) -> Void in
            switch(result){
            case .success(let user):
                XCTAssertEqual(5, user.id)
                XCTAssertEqual(5, user.userId)
                XCTAssertEqual("Iron Man", user.name)
                XCTAssertEqual("Poor Scientist", user.position)
                XCTAssertEqual("https://en.wikipedia.org/wiki/Iron_Man", user.fullProfileUrl)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testList()
    {
        judgeSession.setNextCase("webapi.posts.list", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.posts.list { (result) -> Void in
            switch(result){
            case .success(let posts):
                let post = posts.items[0]
                XCTAssertEqual(1, post.id)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testNestedResourceWithNestedList()
    {
        judgeSession.setNextCase("webapi.users.list.queue", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.users.queue.list { (result) -> Void in
            switch(result){
            case .success(let users):
                let firstUser = users.items[0]
                XCTAssertEqual(3, firstUser.id)
                XCTAssertEqual("Captain America ", firstUser.name)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testFailureToSuccessTransformation()
    {
        judgeSession.setNextCase("webapi.posts.list.notFound", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.posts.list { (result) -> Void in
            switch(result){
            case .success(let posts):
                XCTAssertEqual(0, posts.items.count)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testFailureWithCustomError()
    {
        judgeSession.setNextCase("webapi.users.createFailed", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let request =  CreateUserRequest()
        request.name = "Prince Charles"
        request.position = "The Monarch"
        request.fullProfileUrl = "https://en.wikipedia.org/wiki/Charles,_Prince_of_Wales"
        
        client.users.create(request) { (result) -> Void in
            switch(result){
            case .success:
                XCTFail()
            case .failure(let error):
                if ( error is CustomWebApiError ) {
                    let e = error as! CustomWebApiError
                    XCTAssertEqual("CustomErrorDomain", e.domain)
                    XCTAssertEqual(400, e.code)
                    XCTAssertEqual("NAME_IS_NOT_PUNK_ENOUGH", e.errorCode)
                    XCTAssertEqual("User creation failed. Name does not have enough PUNK in it.", e.errorMessage)
                    expectation.fulfill()
                }
                else {
                    XCTFail("Unexpected error type: \(error).")
                }
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testDelete()
    {
        judgeSession.setNextCase("webapi.posts.delete", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        client.posts.withId(1).delete() { (result) -> Void in
            switch(result){
            case .success(_):
                //XCTAssertEqual(1, post.id)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testGetOnEntity()
    {
        judgeSession.setNextCase("webapi.users.list.paginated.1", xcTestCase: self)
        var expectation = self.expectation(description: "Response expectation")
        
        
        let params = UserListParameters(
            pagination: Pagination(pageNumber: 1, pageSize: 2),
            sortBy: Sort(by: [(UserSortableField.name,SortDirection.ascending),(UserSortableField.userId,SortDirection.descending)])
        )
        var user : User? = nil
        client.users.list(params) { (result) -> Void in
            switch(result){
            case .success(let users):
                user = users.items[0]
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
        
        
        judgeSession.setNextCase("webapi.users.detail.1", xcTestCase: self)
        
        expectation = self.expectation(description: "Response expectation")
        
        if let userFromList = user {
            userFromList.get { (result) -> Void in
                switch(result){
                case .success(let detail):
                    XCTAssertEqual("Gordon Freeman", detail.name)
                    XCTAssertEqual(1, detail.id)
                    XCTAssertEqual("Scientist", detail.position)
                    expectation.fulfill()
                case .failure(_):
                    XCTFail()
                }
            }
        }
        else {
            XCTFail( "User must not be nil." )
        }

        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    func testPaginatedList()
    {
        judgeSession.setNextCase("webapi.users.list.paginated.1", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let params = UserListParameters(
            pagination: Pagination(pageNumber: 1, pageSize: 2),
            sortBy: Sort(by: [(UserSortableField.name,SortDirection.ascending),(UserSortableField.userId,SortDirection.descending)])
        )
        var usersList : PaginatedListResponse<User>? = nil
        client.users.list(params) { (result) -> Void in
            switch(result){
            case .success(let users):
                usersList = users
                XCTAssertEqual("Gordon Freeman", users.items[0].name)
                XCTAssertEqual(1, users.items[0].id)
                //XCTAssertEqual(1, post.id)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
        
        
        judgeSession.setNextCase("webapi.users.list.paginated.2", xcTestCase: self)
        let expectation2 = self.expectation(description: "Response expectation")
        usersList?.nextPage({ (res) -> Void in
            switch(res){
            case .success(let users):
                XCTAssertEqual("Luke Skywalker", users.items[0].name)
                XCTAssertEqual(3, users.items[0].id)
                expectation2.fulfill()
            case .failure(_):
                XCTFail()
            }
        })
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    //MARK: - file
    func testFileUpload()
    {
        guard let path       = Bundle(for: type(of: self)).path(forResource: "test-file", ofType: "wtf"),
              let uploadData = try? Data.init(contentsOf: URL(fileURLWithPath: path)) else {
                XCTFail()
                return
        }
//        let path = NSBundle(forClass: self.dynamicType).pathForResource("test-file", ofType: "png")
//        let uploadData = NSData.dataWithContentsOfMappedFile(path!)
        let request = FileCreateRequest(fileName: "test-file.png", data: uploadData)
        judgeSession.setNextCase("webapi.file.upload", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
       
        self.client.files.upload(request) { (result) -> Void in
            switch(result){
            case .success(let file):
                XCTAssertEqual(file.id, "phREvNnb6rDadlCYGa5O")
                XCTAssertEqual(file.isOk, true)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("File upload finished with error: \(error)")
            }
        }
        waitForExpectations(timeout: 10.0, handler:nil)
    }
    
    //MARK: - primitives
    func testListOfPrimitives()
    {
        judgeSession.setNextCase("webapi.notes.list", xcTestCase: self)
        let expectation = self.expectation(description: "Response expectation")
        
        let expNotes = ["This is my first dog note",
                        "This is my second cat note",
                        "This is my third dog note",
                        "This is my fourth elephant note",
                        "This is my fifth dog note",
                        "This is my sixth snake note"]
        
        client.notes.list { (result) -> Void in
            switch(result){
            case .success(let notes):
                
                for (index,note) in notes.items.enumerated(){
                    XCTAssertEqual(note, expNotes[index])
                }
                expectation.fulfill()
                
            case .failure(_):
                XCTFail()
            }
        }
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testHasUrl(){
        let url = client.users.withId("123").url(UserDetailUrlParameters(format:"XML",pageSize: 23))
        XCTAssertTrue(url ==  "http://csas-judge.herokuapp.com/users/123?format=XML&pageSize=23" || url == "http://csas-judge.herokuapp.com/users/123?pageSize=23&format=XML")
    }
    
    func testDownload()
    {
        let documentUrl    = "http://box2d.org/manual.pdf"
        let dataToDownload = try? Data.init(contentsOf: URL(string: documentUrl)!)
        
        let expectation    = self.expectation(description: "Response expectation")
        
        let resource       = Resource(path: "http://box2d.org/manual.pdf", client: self.client)
        
        ResourceUtils.CallDownload(method: .GET, resource:resource, pathSuffix: nil, parameters: nil, contentType: nil, callback: { result in
            switch ( result ) {
            case .success(let downloadedFilePath):
                XCTAssertNotNil(downloadedFilePath)
                let manager = FileManager.default
                XCTAssertTrue( manager.fileExists(atPath: downloadedFilePath))
            
                if let downloadedData = NSData(contentsOfFile: downloadedFilePath ) {
                    XCTAssertTrue(downloadedData.isEqual(to: dataToDownload!))
                    expectation.fulfill()
                }
                else {
                    XCTFail()
                }
                
            case .failure(let error):
                XCTFail("Download error: \(error)")
            }
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
}
