-- Create User Table

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL
);


-- Sign Up 

INSERT INTO users (username, email, password) VALUES ('a', 'b', 'c') RETURNING user_id;


-- Sign In query - check the username and password are valid

SELECT user_id 
    FROM users
        WHERE email='a' and password='a';