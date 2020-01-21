# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version
Rails 5.1.7
ruby 2.3.3p222 (2016-11-21 revision 56859) [i386-mingw32]

* System dependencies
No dependancies as such, below gems have been added and used
#Custom
gem 'faraday'

gem 'jwt'
gem 'dotenv-rails'

gem 'jquery-rails'

gem 'bootstrap'

* Configuration


* Database creation
API's used

* Database initialization

* How to run the test suite
NA
* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

* General

To run the app after installing dependant gems, do rails s
Application uses bootstrap for UI designing.

First page will be widget listing, public widget will be listed along with user name.
Click on user will bring to user details page.
All widget belonging to user will be listed on the page.
This will use partial from widget view to avoid duplication of code
User can Login through the login link at the top.
Login form will be provided in pop up.
On successful login user will be redirected to home page again and link will be changed to 'Log out'.
On login, widget tab will be visible to user
On this tab user can perform activities like udpate/delete for widget belonging to them.
Update method is not complete, unable to find API details for getting widget data.
CLIENT_ID & CLIENT_SECRET is saved in .env file so that can be used in any controller.
session management to track the login details.
faraday gem is used to connect to REST API.
View and controller data sharing could have been improve, if I had few more days:)

