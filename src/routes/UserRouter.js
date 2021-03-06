const express = require('express');
const router = express.Router();

const UserController = require('../controllers/UserController');

router.route('/create').post(UserController.signUp);
router.route('/verify').post(UserController.signIn);
router.route('/:id/user-details').get(UserController.userDetails);
router.route('/:id/wallet-balance').get(UserController.walletBalance);
router.route('/:id/wallet-transaction').post(UserController.walletTransaction);
router.route('/:id/wallet-transaction-list').get(UserController.walletTransactionList);
router.route('/:id/coin-transaction').post(UserController.coinTransaction);
router.route('/:id/coin-transaction-list').get(UserController.coinTransactionList);
router.route('/:id/coin-holding').get(UserController.coinHolding);
router.route('/:id/transaction-report').get(UserController.transactionReport);


module.exports = router;