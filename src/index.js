const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const cors = require('cors')

require('dotenv').config();

const userRoute = require('./routes/UserRouter');

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
    console.log(`Server listening on ${PORT}`);
});

// app.get('/', (req, res) => {
//     res.send("index")
// });

app.post('/', (req, res) => {
    console.log(req.body);
    res.status(200).send("yes");
});

app.use('/user', userRoute);
