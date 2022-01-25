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


-- Create Wallet Transaction Table

CREATE TYPE trans_type AS ENUM ('deposit', 'withdraw');

CREATE TABLE wallet_transaction (
    user_id INT,
	  trans_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trans_amt FLOAT NOT NULL,
    trans_type trans_type NOT NULL,
	  trans_date TIMESTAMP NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Create Coin Table

CREATE TABLE coins (
	coin_id varchar(40) NOT NULL UNIQUE PRIMARY KEY,
	coin_name varchar(40) NOT NULL UNIQUE,
	coin_symbol varchar(20) NOT NULL,
	image_url varchar(200) NOT NULL	
);

-- Create Coin Transaction Table

CREATE TYPE coin_trans_type AS ENUM ('buy', 'sell');

CREATE TABLE coin_transaction (
 	user_id INT,
	trans_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	coin_id varchar(40) NOT NULL,
  trans_amt FLOAT NOT NULL,
	no_of_coins FLOAT NOT NULL, 
  trans_type coin_trans_type NOT NULL,
	trans_date TIMESTAMP NOT NULL,
	FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY(coin_id) REFERENCES coins(coin_id) ON DELETE CASCADE
);


-- Create Coin Holding Table

CREATE TABLE coin_holding (
	user_id INT,
	coin_id varchar(40) NOT NULL,
	no_of_coins FLOAT NOT NULL,
	PRIMARY KEY(user_id, coin_id),
	FOREIGN KEY(user_id) REFERENCES users(user_id) ON DELETE CASCADE,
	FOREIGN KEY(coin_id) REFERENCES coins(coin_id) ON DELETE CASCADE
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


-- Insert Into Wallet Transaction Table

INSERT INTO wallet_transaction (user_id, trans_amt, trans_type, trans_date) 
	VALUES (5, 500, 'deposit', CURRENT_TIMESTAMP);


-- Stored Procedure To Insert Into Wallet Transaction Table

create or replace procedure wallet_transaction(
	user_id int,
  	amount float,
	trans_type trans_type
)
language plpgsql    
as $$
begin
    INSERT INTO wallet_transaction (user_id, trans_amt, trans_type, trans_date) 
	    VALUES (user_id, amount, trans_type , CURRENT_TIMESTAMP);

    commit;
end;$$


-- To call a stored procedure
call wallet_transaction(5, 500, 'deposit');


 -- Trigger function to update the wallet balance of the user for both deposit and withdraw

CREATE OR REPLACE FUNCTION wallet_balance_update()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF new.trans_type ='deposit' THEN
		UPDATE balance	
			SET wallet_balance = wallet_balance + new.trans_amt
        where balance.user_id = new.user_id;
	ELSE
		UPDATE balance
    		SET wallet_balance = wallet_balance - new.trans_amt
          where balance.user_id = new.user_id;
 	END IF;

	RETURN NEW;
END;
$$

-- Trigger to update the wallet balance

CREATE TRIGGER wallet_balance_after_transaction
  AFTER INSERT
  ON wallet_transaction
  FOR EACH ROW
  EXECUTE PROCEDURE wallet_balance_update();


-- To Get a List of Wallet Transaction

select trans_amt, trans_type, to_char(trans_date,'DD-MM-YYYY HH24:MI') as trans_date 
	from wallet_transaction 
		where user_id=5
			ORDER BY trans_date DESC;


-- To Get User Details

select * from users where user_id = 5;



-- Stored Procedure to Insert Into Coin Transaction Table and Coin Table

create or replace procedure coin_transaction(
	user_id int,
	coin_id varchar(40),
 	trans_amt float,
	no_of_coins float,
	trans_type coin_trans_type,
	coin_name varchar(40),
	coin_symbol varchar(20),
	image_url varchar(200)
)
language plpgsql    
as $$
begin
	INSERT INTO coins (coin_id, coin_name, coin_symbol, image_url) 
		values (coin_id, coin_name, coin_symbol, image_url)
			ON CONFLICT DO NOTHING;
			
	INSERT INTO coin_transaction (user_id, coin_id, trans_amt, no_of_coins, trans_type, trans_date) 
	    VALUES (user_id, coin_id, trans_amt, no_of_coins, trans_type , CURRENT_TIMESTAMP);

    commit;
end;$$

-- To call a stored procedure
call coin_transaction(5, 'bitcoin', 100, 0.1, 'buy', 'Bitcoin', 'btc', 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579');


 -- Trigger function to update the wallet balance of the user for both buying and selling of coin

CREATE OR REPLACE FUNCTION balance_update_after_coin_transaction()
  RETURNS TRIGGER 
  LANGUAGE PLPGSQL
  AS
$$
BEGIN
	IF new.trans_type ='buy' THEN
		UPDATE balance
			SET wallet_balance = wallet_balance - new.trans_amt
        WHERE user_id = new.user_id;
	ELSE
		UPDATE balance
    		SET wallet_balance = wallet_balance + new.trans_amt
          WHERE user_id = new.user_id;
 	END IF;

  
  IF new.trans_type = 'buy' THEN
     INSERT INTO coin_holding (user_id, coin_id, no_of_coins) 
      VALUES(new.user_id, new.coin_id, new.no_of_coins)
      ON CONFLICT (user_id, coin_id) DO UPDATE 
      SET no_of_coins  = coin_holding.no_of_coins+new.no_of_coins;
  ELSE
  	UPDATE coin_holding 
		SET no_of_coins = coin_holding.no_of_coins-new.no_of_coins
			WHERE coin_holding.user_id = new.user_id and coin_holding.coin_id = new.coin_id;
	  DELETE FROM coin_holding
		  WHERE no_of_coins = 0;
  END IF;

	RETURN NEW;
END;
$$

-- Trigger to update the wallet balance and no_of_coins

CREATE TRIGGER wallet_balance_after_transaction
  AFTER INSERT
  ON coin_transaction
  FOR EACH ROW
  EXECUTE PROCEDURE balance_update_after_coin_transaction();


-- To get Coin Transaction List

SELECT
	ct.trans_id,
	ct.trans_amt,
	ct.no_of_coins,
	ct.trans_type,
	to_char(ct.trans_date,'DD-MM-YYYY HH24:MI') as trans_date,
	coins.coin_symbol,
	image_url
    FROM coin_transaction ct
        INNER JOIN coins 
            ON ct.coin_id = coins.coin_id
              WHERE ct.user_id = 5
                ORDER BY trans_date DESC;


SELECT coin_id, no_of_coins FROM coin_holding
	WHERE user_id=5;


-- Function to create report of total sum and count of each transaction type

create or replace function get_transaction_report (
	id_user int
) 
	returns table (
		trans_type varchar,
		total_sum float,
		total_count bigint
	) 
	language plpgsql
as $$
begin
	return query 
		select cast(wt.trans_type as varchar(10)), sum(wt.trans_amt) as total_sum, count(wt.trans_type) as total_count
			from wallet_transaction as wt
				where wt.user_id = id_user
					group by wt.trans_type
		Union
		select cast(ct.trans_type as varchar(10)), sum(ct.trans_amt) as total_sum, count(ct.trans_type) as total_count
			 from coin_transaction as ct 
			 	where ct.user_id = id_user
			 		group by ct.trans_type;
end;$$

SELECT * FROM get_transaction_report (8);


-- To grant table permission

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO arjun;



