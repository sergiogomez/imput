# Imput #

## Measure your work easily, improve your productivity and stop wasting your time ##

### Where does imput come from? ###

The idea of this project came after wasting a lot of our time, tracking hours with old Enterprise ERP software. We decided we wanted a faster and easier way to track our working hours.

After a few months we launched a free single user version and a paid one for a multi-user account. Now, we have decided to open source it!!! Feel free to install it, use it and, why not?, improve it! :)

### Technologhies ###

* Our app uses Ruby 2.1.10 & Rails 4.1.11 
* We also use Redis 2.X or higher.
* Our Database is PostgreSQL 9.3 or higher

### Steps to create the database ###

* rake db:create
* rake db:schema:load

### How to test the app ###

* rake spec #to run all tests and see they are passing! :)

### Is there a free hosted version? ###

Yes! You can use it at [app.imput.io](https://app.imput.io/)

### Licensing

The source code is licensed under GPL v3. License is available [here](/LICENSE).

### Contributing ###

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
