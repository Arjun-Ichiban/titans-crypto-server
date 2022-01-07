const db = require("../db/index");

exports.signUp = async (req, res) => {
  try {
    const { username, email, password } = req.body;

    const { rows } = await db.query(
      `INSERT INTO users(username, email, password) VALUES ($1, $2, $3) RETURNING user_id`,
      [username, email, password]
    );

    res.status(200).send({
      message: "User added successfully!",
      body: {
        user: { username, email, password },
      },
      user_id: rows[0].user_id,
    });
  } catch (error) {
    res.status(400).send({
      message: "Error occured",
    });
  }
};

exports.signIn = async (req, res) => {
  try {
    const { email, password } = req.body;

    const { rows } = await db.query(
      `SELECT user_id 
          FROM users
              WHERE email=$1 and password=$2;`,
      [email, password]
    );

    if (rows == 0) {
      res.status(400).send({
        message: "Enter the right credentials",
      });
    } else {
      res.status(200).send({
        message: "User added successfully!",
        body: {
          user: { email, password },
        },
        user_id: rows[0].user_id,
      });
    }
  } catch (error) {
    res.status(400).send({
      message: "Error occured",
    });
  }
};

exports.walletBalance = async (req, res) => {
  try {
    const user_id = req.params.id;

    const { rows } = await db.query(
      `SELECT wallet_balance 
          FROM balance
              WHERE user_id=$1;`,
      [user_id]
    );

    if (rows == 0) {
      res.status(400).send({
        message: "Retrieval Failed",
      });
    } else {
      res.status(200).send({
        message: "Successful Retrieval",
        body: {
          user: { user_id },
        },
        wallet_balance: rows[0].wallet_balance,
      });
    }
  } catch (error) {
    res.status(400).send({
      message: "Error occured",
    });
  }
};

exports.walletTransaction = async (req, res) => {
  try {
    const user_id = req.params.id;
    const { amount, type } = req.body;

    const result = await db.query(
      `call wallet_transaction($1, $2, $3);`,
      [user_id, amount, type]
    );

    res.status(200).send({
      message: "Successful Transaction",
      body: {
        user: { user_id },
      }
    });
  } catch (error) {
    res.status(400).send({
      message: "Transaction Failed",
    });
  }
};


exports.walletTransactionList = async (req, res) => {
  try {
    const user_id = req.params.id;

    const { rows } = await db.query(
      `SELECT trans_amt, trans_type, trans_date 
          FROM wallet_transaction
              WHERE user_id=$1;`,
      [user_id]
    );
    if (rows == 0) {
      res.status(400).send({
        message: "Retrieval Failed",
      });
    } else {
      res.status(200).send(
        rows
      );
    }
  } catch (error) {
    res.status(400).send({
      message: "Error occured",
    });
  }
};
