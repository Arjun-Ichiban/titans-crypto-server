const express = require("express");
const bodyParser = require('body-parser')
const app = express();

app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

const PORT = process.env.PORT || 8080;

app.listen(PORT, () => {
    console.log(`App running on port ${PORT}`);
});

app.get('/', (req, res) => {
    res.send("index")
});