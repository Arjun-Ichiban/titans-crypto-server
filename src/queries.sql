-- Create User Table

CREATE TABLE users (
    user_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL
);


-- Create Balance Table

CREATE TABLE balance (
    user_id INT UNIQUE,
    coin_balance FLOAT NOT NULL,
    wallet_balance FLOAT NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- Sign Up 

INSERT INTO users (username, email, password) VALUES ('a', 'b', 'c') RETURNING user_id;


-- Sign In query - check the username and password are valid

SELECT user_id 
    FROM users
        WHERE email='a' and password='a';



-- Trigger function to create a row in balance table after a user has been created.

CREATE OR REPLACE FUNCTION balance_table_insert_row()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	INSERT INTO balance(user_id,coin_balance,wallet_balance)
	VALUES(new.user_id,0,0);

	RETURN NEW;
END;
$$

-- Trigger to add a row in the balance table when a new user is created.

CREATE TRIGGER balance_table_entry
  AFTER INSERT
  ON users
  FOR EACH ROW
  EXECUTE PROCEDURE balance_table_insert_row();