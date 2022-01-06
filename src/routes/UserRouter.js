const express = require('express');
const router = express.Router();

const UserController = require('../controllers/UserController');

router.route('/create').post(UserController.signUp);
router.route('/verify').post(UserController.signIn);
router.route('/:id/wallet-balance').get(UserController.walletBalance)


module.exports = router;