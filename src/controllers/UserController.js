const db = require('../db/index');

exports.createUser = async (req, res) => {
    try {
        const { username, email, password } = req.body;

        const { rows } = await db.query(
            `INSERT INTO users(username, email, password) VALUES ($1, $2, $3) RETURNING user_id`,
            [username, email, password]
        );

        res.status(201).send({
            message: "User added successfully!",
            body: {
                user: { username, email, password },
                user_id: rows[0].user_id
            },
        });
    }
    catch (error) {
        res.status(400).send({
            message: "Error occured"
        });
    }


};