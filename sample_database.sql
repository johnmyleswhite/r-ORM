CREATE DATABASE `sample_database`;

GRANT ALL ON `sample_database`.* TO 'sample_user'@'localhost' IDENTIFIED BY 'sample_password';

FLUSH PRIVILEGES;
