const express = require('express');
const router = express.Router();

const UserController = require('../controllers/UserController');

router.route('/create').post(UserController.createUser);


module.exports = router;