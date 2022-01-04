const express = require('express');
const router = express.Router();

const UserController = require('../controllers/UserController');

router.route('/create').post(UserController.signUp);
router.route('/verify').post(UserController.signIn);


module.exports = router;