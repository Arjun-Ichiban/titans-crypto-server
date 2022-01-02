const db = require('../db/index');

exports.createUser = async (req, res) => {
    console.log(req.body);
    const { username, email, password } = req.body;
    const { rows } = await db.query(
        `INSERT INTO users(username, email, password) VALUES ($1, $2, $3)`,
        [username, email, password]
    );

    res.status(201).send({
        message: "User added successfully!",
        body: {
            user: { username, email, password }
        },
    });
};