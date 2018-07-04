require 'sqlite3'

begin
    
    db = SQLite3::Database.open "eurusraffle.sqlite"
    
    # Users
    db.execute "CREATE TABLE IF NOT EXISTS Users(
        user_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        name NVARCHAR(30) NOT NULL, 
        shoe_size NVARCHAR(10) NOT NULL REFERENCES Sizes(shoe_size),
        paypal_email NVARCHAR(260) NOT NULL UNIQUE, 
        instagram_handle NVARCHAR(31) NOT NULL UNIQUE)"

    # Shoe Sizes
    db.execute "CREATE TABLE IF NOT EXISTS Sizes(
        shoe_size NVARCHAR(10) NOT NULL UNIQUE)"

    # New Users
    db.execute "CREATE TABLE IF NOT EXISTS New_Users(
        new_user_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        name NVARCHAR(30) NOT NULL, 
        shoe_size NVARCHAR(10) NOT NULL REFERENCES Sizes(shoe_size),
        paypal_email NVARCHAR(260) NOT NULL UNIQUE, 
        instagram_handle NVARCHAR(31) NOT NULL UNIQUE,
        approved BIT)"
 
# exception handling   
rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e
ensure
    db.close if db
end