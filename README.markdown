This is a pure R ORM library. To get started using it, follow the steps below:

1. Download the code. Place the files you get into `~/r-ORM`.

2. Install the R YAML and MySQL packages if you don’t already have them on your system:
<pre>
install.packages('yaml')
install.packages('RMySQL')
</pre>

3. Create a test database in MySQL called `sample_database`:
<pre>
CREATE DATABASE `sample_database`;
</pre>

4. Give permissions on this test database to `sample_user`:
<pre>
GRANT ALL ON `sample_database`.* TO 'sample_user'@'localhost' IDENTIFIED BY 'sample_password';
FLUSH PRIVILEGES;
</pre>

5. Create a test table called `users` in `sample_database`:
<pre>
USE `sample_database`;
CREATE TABLE `users` (
  `user_id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
</pre>

6. Edit the `database.yml` file if you didn’t use the database name, user name or password I just suggested. You’ll also need to edit it if you’re not working on `localhost`.

7. Open up an R interpreter. Set your working directory and source `orm.R`:
<pre>
setwd('~/r-ORM')
source('orm.R')
</pre>

8. Build code for our user objects using `orm.build.model('user')`:
<pre>
code <- orm.build.model('user')
cat(code)
</pre>

At this point, you can review the code that’s been generated to see whether it should work on your system. If it will, you can eval it now:
<pre>
eval(parse(text = code))
</pre>

With that done, you should have a working set of functions that handle creating, finding, manipulating and deleting R objects that are serialized to the database. To test out the resulting model, let’s start by creating a user object. In general, an object of class `foo` will be created using an auto-generated function called `create.foo`:
<pre>
user <- create.user()
</pre>

Calling this functions builds a user object in memory. Nothing is in the database so far. To see the object, type `user` at the command line:
<pre>
user
</pre>

Now you can edit this user to make it a real piece of data. The columns of the database table are mapped onto object attributes with appropriate getter and setter methods, like so:
<pre>
name(user) <- 'test_user'
password(user) <- 'test_password'
</pre>

Once the user object is worth keeping, we store it in the database using store:
<pre>
user <- store(user)
</pre>

This stores the user object in the database. To get the ID’s edited correctly, you have to perform the assignment as indicated above. In the future I may change this.

After storing something, you might want to retrieve it later. Since we know that we just created the first user object, we can get it again by using a `find.user()` call:
<pre>
user <- find.user(1)
</pre>

In general, you can find objects of class `foo` by calling `find.foo()`. If you provide an integer as an input, you’ll get the object with that ID. If you provide the string `'all'`, you’ll get a list containing all of the objects in your database. Other inputs produce an error.

You can see that we got the correct object using the getter methods:
<pre>
user.id(user) == 1
name(user) == 'test_user'
password(user) == 'test_password'
</pre>

We can edit it again to see that updating rows of the database works as expected:
<pre>
name(user) <- 'new_user'
store(user)
</pre>

Finally, now that we’re done with it, we can delete it from the database:
<pre>
delete(user)
</pre>

That, in a nutshell, is the use of this ORM solution. If you have any questions, please let me know: I’ll be happy to answer them.
