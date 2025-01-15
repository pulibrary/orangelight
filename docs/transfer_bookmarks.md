# Transfer Bookmarks from one user to another

1. Find old user_id from the User table:  
    `user_old_identifier = User.where(username: "old_identifier")`
2. Find Bookmarks for the old user_id:  
    `user_old_identifier_bookmarks = Bookmark.where(user_id: user_old_identifier.ids[0])`
3. Find the count of Bookmarks in the old user's account:
    `user_old_identifier_bookmarks.count`
4. Find new user_id from the User table:
    `user_new_identifier = User.where(username: "new_identifier")` 
5. Update the Bookmarks from the old user_id to new user_id:  
    `user_old_identifier_bookmarks.each {|bookmark| bookmark.update(user_id: user_new_identifier.ids[0])}`
6. Confirm that the bookmarks were transferred from the old user account to the new user account:
   `user_old_identifier_bookmarks.count` should return 0
   `user_new_identifier_bookmarks = Bookmark.where(user_id: user_new_identifier.ids[0])`
   `user_new_identifier_bookmarks.count` should be equal to `user_old_identifier_bookmarks.count`
